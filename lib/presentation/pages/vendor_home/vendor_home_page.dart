import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:iskxpress/core/widgets/vendor_app_bar.dart';
import 'package:iskxpress/core/widgets/vendor_bottom_nav_bar.dart';
import 'package:iskxpress/presentation/pages/vendor_home/widgets/vendor_header.dart';
import 'package:iskxpress/presentation/pages/vendor_home/widgets/product_section.dart';
import 'package:iskxpress/presentation/pages/vendor_home/widgets/add_section_button.dart';
import 'package:iskxpress/presentation/pages/vendor_home/widgets/product_form_dialog.dart';
import 'package:iskxpress/presentation/pages/vendor_home/widgets/section_form_dialog.dart';
import '../../../core/services/user_state_service.dart';
import '../../../core/services/stall_state_service.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/product_model.dart';
import '../../../core/models/section_model.dart';
import '../../../core/models/category_model.dart';

class VendorHomePage extends StatefulWidget {
  const VendorHomePage({super.key});

  static const String routeName = 'vendor_home_page';

  @override
  State<VendorHomePage> createState() => _VendorHomePageState();
}

class _VendorHomePageState extends State<VendorHomePage> {
  final StallStateService _stallStateService = StallStateService();
  final UserStateService _userStateService = UserStateService();

  List<SectionModel> _sections = [];
  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  bool _isInitialLoading = true;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isInitialLoading = true;
      _errorMessage = null;
    });

    try {
      final currentUser = _userStateService.currentUser;
      if (currentUser != null) {
        await _stallStateService.loadStallForVendor(currentUser.id);
        final stall = _stallStateService.currentStall;
        
        if (stall != null) {
          if (kDebugMode) debugPrint('VENDOR_HOME: Loading data for stall ${stall.id}');
          
          // Load sections and products together, categories separately
          List<SectionModel> sections = [];
          List<ProductModel> products = [];
          List<CategoryModel> categories = [];
          
          try {
            final stallDataResults = await Future.wait([
              ApiService.getStallSections(stall.id),
              ApiService.getStallProducts(stall.id),
            ]);
            
            sections = stallDataResults[0] as List<SectionModel>;
            products = stallDataResults[1] as List<ProductModel>;
            
            if (kDebugMode) {
              debugPrint('VENDOR_HOME: Loaded ${sections.length} sections');
              debugPrint('VENDOR_HOME: Loaded ${products.length} products');
            }
          } catch (e) {
            if (kDebugMode) debugPrint('VENDOR_HOME: Error loading stall data: $e');
          }
          
          // Load categories separately with individual error handling
          try {
            if (kDebugMode) debugPrint('VENDOR_HOME: Loading categories separately...');
            categories = await ApiService.getCategories();
            
            if (kDebugMode) {
              debugPrint('VENDOR_HOME: Loaded ${categories.length} categories');
              if (categories.isNotEmpty) {
                debugPrint('VENDOR_HOME: Categories: ${categories.map((c) => '${c.id}: ${c.name}').join(', ')}');
              } else {
                debugPrint('VENDOR_HOME: WARNING - No categories loaded!');
              }
            }
          } catch (e) {
            if (kDebugMode) debugPrint('VENDOR_HOME: Error loading categories: $e');
            // Don't fail the entire load if categories fail
            categories = [];
          }
          
          setState(() {
            _sections = sections;
            _products = products;
            _categories = categories;
          });
        } else {
          if (kDebugMode) debugPrint('VENDOR_HOME: No stall found for vendor');
        }
      } else {
        if (kDebugMode) debugPrint('VENDOR_HOME: No current user found');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('VENDOR_HOME: Error loading data: $e');
      setState(() {
        _errorMessage = 'Failed to load data: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  List<ProductModel> _getProductsForSection(int sectionId) {
    return _products.where((product) => product.sectionId == sectionId).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const VendorAppBar(title: 'Vendor Home'),
      bottomNavigationBar: const VendorBottomNavBar(currentIndex: 0),
      body: Stack(
        children: [
          _isInitialLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? _buildErrorWidget()
                  : _buildContent(),
          
          // Loading overlay for product operations
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Processing...',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Vendor Header
            const VendorHeader(),
            
            // Sections and Products
            if (_sections.isEmpty)
              _buildEmptyState()
            else
              ..._sections.map((section) => ProductSectionWidget(
                section: SectionWithProducts(
                  section: section,
                  products: _getProductsForSection(section.id),
                ),
                categories: _categories,
                onEditProduct: _editProduct,
                onDeleteProduct: _deleteProduct,
                onAddProduct: _addProduct,
                onEditSection: _editSection,
                onDeleteSection: _deleteSection,
              )),
            
            // Add Section Button
            AddSectionButton(onAddSection: _addSection),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.store_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No sections yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding your first section to organize your products',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addSection() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const SectionFormDialog(),
    );

    if (result != null) {
      final stall = _stallStateService.currentStall;
      if (stall != null) {
        final newSection = await ApiService.createSection(
          stallId: stall.id,
          name: result['name'],
        );

        if (newSection != null) {
          setState(() {
            _sections.add(newSection);
          });
          _showSuccessSnackBar('Section added successfully');
        } else {
          _showErrorSnackBar('Failed to add section');
        }
      }
    }
  }

  Future<void> _editSection(SectionModel section) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => SectionFormDialog(section: section),
    );

    if (result != null) {
      final updatedSection = await ApiService.updateSection(
        sectionId: section.id,
        name: result['name'],
      );

      if (updatedSection != null) {
        setState(() {
          final index = _sections.indexWhere((s) => s.id == section.id);
          if (index != -1) {
            _sections[index] = updatedSection;
          }
        });
        _showSuccessSnackBar('Section updated successfully');
      } else {
        _showErrorSnackBar('Failed to update section');
      }
    }
  }

  Future<void> _deleteSection(SectionModel section) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Section'),
        content: Text('Are you sure you want to delete "${section.name}"? This will also delete all products in this section.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      final success = await ApiService.deleteSection(section.id);

      if (success) {
        setState(() {
          _sections.removeWhere((s) => s.id == section.id);
          _products.removeWhere((p) => p.sectionId == section.id);
        });
        _showSuccessSnackBar('Section deleted successfully');
      } else {
        _showErrorSnackBar('Failed to delete section');
      }
    }
  }

  Future<void> _addProduct(SectionModel section) async {
    if (kDebugMode) {
      debugPrint('VENDOR_HOME: Opening add product dialog');
      debugPrint('VENDOR_HOME: Available categories: ${_categories.length}');
      for (var category in _categories) {
        debugPrint('VENDOR_HOME: Category: ${category.id} - ${category.name}');
      }
    }
    
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => ProductFormPage(
          sections: _sections,
          categories: _categories,
        ),
      ),
    );

    if (result != null) {
      final stall = _stallStateService.currentStall;
      if (stall != null) {
        if (kDebugMode) debugPrint('VENDOR_HOME: Creating product: ${result}');
        
        setState(() {
          _isProcessing = true;
        });

        try {
          final newProduct = await ApiService.createProduct(
            stallId: stall.id,
            name: result['name'],
            basePrice: result['basePrice'],
            sectionId: result['sectionId'],
            categoryId: result['categoryId'],
          );

          if (newProduct != null) {
            // Upload image if provided
            if (result['imageFile'] != null) {
              if (kDebugMode) debugPrint('VENDOR_HOME: Uploading image for new product ${newProduct.id}');
              
              final uploadSuccess = await ApiService.uploadProductPicture(
                productId: newProduct.id,
                imageFile: result['imageFile'],
              );

              if (!uploadSuccess) {
                if (kDebugMode) debugPrint('VENDOR_HOME: Image upload failed for product ${newProduct.id}');
                _showErrorSnackBar('Product created but image upload failed');
              } else {
                if (kDebugMode) debugPrint('VENDOR_HOME: Image uploaded successfully for product ${newProduct.id}');
              }
            }

            // Reload the product data to get the updated image URL
            await _reloadProducts();
            _showSuccessSnackBar('Product added successfully');
          } else {
            _showErrorSnackBar('Failed to add product');
          }
        } catch (e) {
          if (kDebugMode) debugPrint('VENDOR_HOME: Error adding product: $e');
          _showErrorSnackBar('Failed to add product: ${e.toString()}');
        } finally {
          setState(() {
            _isProcessing = false;
          });
        }
      }
    }
  }

  Future<void> _editProduct(ProductModel product) async {
    if (kDebugMode) {
      debugPrint('VENDOR_HOME: Opening edit product dialog');
      debugPrint('VENDOR_HOME: Available categories: ${_categories.length}');
    }
    
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => ProductFormPage(
          product: product,
          sections: _sections,
          categories: _categories,
        ),
      ),
    );

    if (result != null) {
      if (kDebugMode) debugPrint('VENDOR_HOME: Updating product: ${result}');
      
      setState(() {
        _isProcessing = true;
      });

      try {
        final updatedProduct = await ApiService.updateProduct(
          productId: product.id,
          name: result['name'],
          basePrice: result['basePrice'],
          sectionId: result['sectionId'],
          categoryId: result['categoryId'],
        );

        if (updatedProduct != null) {
          // Upload new image if provided
          if (result['imageFile'] != null) {
            if (kDebugMode) debugPrint('VENDOR_HOME: Uploading new image for product ${product.id}');
            
            final uploadSuccess = await ApiService.uploadProductPicture(
              productId: product.id,
              imageFile: result['imageFile'],
            );

            if (!uploadSuccess) {
              if (kDebugMode) debugPrint('VENDOR_HOME: Image upload failed for product ${product.id}');
              _showErrorSnackBar('Product updated but image upload failed');
            } else {
              if (kDebugMode) debugPrint('VENDOR_HOME: Image uploaded successfully for product ${product.id}');
            }
          }

          // Reload the product data to get the updated image URL
          await _reloadProducts();
          _showSuccessSnackBar('Product updated successfully');
        } else {
          _showErrorSnackBar('Failed to update product');
        }
      } catch (e) {
        if (kDebugMode) debugPrint('VENDOR_HOME: Error updating product: $e');
        _showErrorSnackBar('Failed to update product: ${e.toString()}');
      } finally {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _deleteProduct(ProductModel product) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      final success = await ApiService.deleteProduct(product.id);

      if (success) {
        setState(() {
          _products.removeWhere((p) => p.id == product.id);
        });
        _showSuccessSnackBar('Product deleted successfully');
      } else {
        _showErrorSnackBar('Failed to delete product');
      }
    }
  }

  // Helper method to reload products after image upload
  Future<void> _reloadProducts() async {
    try {
      final stall = _stallStateService.currentStall;
      if (stall != null) {
        if (kDebugMode) debugPrint('VENDOR_HOME: Reloading products to get updated image URLs');
        
        final products = await ApiService.getStallProducts(stall.id);
        setState(() {
          _products = products;
        });
        
        if (kDebugMode) debugPrint('VENDOR_HOME: Products reloaded successfully');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('VENDOR_HOME: Error reloading products: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// Data models for organizing sections with their products
class SectionWithProducts {
  final SectionModel section;
  final List<ProductModel> products;

  SectionWithProducts({
    required this.section,
    required this.products,
  });
} 