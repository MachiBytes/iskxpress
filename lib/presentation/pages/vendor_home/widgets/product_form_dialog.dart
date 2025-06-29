import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/models/product_model.dart';
import '../../../../core/models/section_model.dart';
import '../../../../core/models/category_model.dart';

class ProductFormPage extends StatefulWidget {
  final ProductModel? product; // null for adding, provided for editing
  final List<SectionModel> sections;
  final List<CategoryModel> categories;

  const ProductFormPage({
    super.key,
    this.product,
    required this.sections,
    required this.categories,
  });

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  
  int? _selectedSectionId;
  int? _selectedCategoryId;
  bool _isLoading = false;
  File? _selectedImage;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    
    if (kDebugMode) {
      debugPrint('PRODUCT_FORM: Initializing page');
      debugPrint('PRODUCT_FORM: Sections count: ${widget.sections.length}');
      debugPrint('PRODUCT_FORM: Categories count: ${widget.categories.length}');
      for (var category in widget.categories) {
        debugPrint('PRODUCT_FORM: Category: ${category.id} - ${category.name}');
      }
    }
    
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.basePrice.toString();
      _selectedSectionId = widget.product!.sectionId;
      _selectedCategoryId = widget.product!.categoryId;
      _currentImageUrl = widget.product!.imageUrl;
      
      if (kDebugMode) {
        debugPrint('PRODUCT_FORM: Editing product: ${widget.product!.name}');
        debugPrint('PRODUCT_FORM: Selected category ID: $_selectedCategoryId');
        debugPrint('PRODUCT_FORM: Current image URL: $_currentImageUrl');
      }
    } else {
      if (widget.sections.isNotEmpty) {
        _selectedSectionId = widget.sections.first.id;
      }
      if (widget.categories.isNotEmpty) {
        _selectedCategoryId = widget.categories.first.id;
      }
      
      if (kDebugMode) {
        debugPrint('PRODUCT_FORM: Adding new product');
        debugPrint('PRODUCT_FORM: Default section ID: $_selectedSectionId');
        debugPrint('PRODUCT_FORM: Default category ID: $_selectedCategoryId');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        if (kDebugMode) debugPrint('PRODUCT_FORM: Image selected: ${image.path}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('PRODUCT_FORM: Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        if (kDebugMode) debugPrint('PRODUCT_FORM: Photo taken: ${image.path}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('PRODUCT_FORM: Error taking photo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error taking photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Image Source',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _pickImage();
                      },
                      icon: const Icon(Icons.photo_library, size: 30),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue[50],
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Gallery'),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _takePhoto();
                      },
                      icon: const Icon(Icons.camera_alt, size: 30),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.green[50],
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Camera'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Image',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _selectedImage != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImage = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : _currentImageUrl != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _currentImageUrl!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 200,
                                color: Colors.grey[100],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      color: Colors.grey[400],
                                      size: 48,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Failed to load image',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _currentImageUrl = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red.shade600,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : GestureDetector(
                      onTap: _showImageSourceBottomSheet,
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              color: Colors.grey[400],
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tap to add image',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
        ),
        if (_selectedImage == null && _currentImageUrl == null)
          const SizedBox(height: 16),
        if (_selectedImage == null && _currentImageUrl == null)
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library, size: 20),
                  label: const Text('Gallery'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt, size: 20),
                  label: const Text('Camera'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;
    final textTheme = Theme.of(context).textTheme;

    if (kDebugMode) {
      debugPrint('PRODUCT_FORM: Building page');
      debugPrint('PRODUCT_FORM: Categories available for dropdown: ${widget.categories.length}');
      if (widget.categories.isEmpty) {
        debugPrint('PRODUCT_FORM: WARNING - No categories available for dropdown!');
      } else {
        debugPrint('PRODUCT_FORM: Categories: ${widget.categories.map((c) => '${c.id}:${c.name}').join(', ')}');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add Product'),
        centerTitle: true,
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _handleSubmit,
              child: Text(
                isEditing ? 'Update' : 'Save',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Name
              Text(
                'Product Information',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  hintText: 'Enter product name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.shopping_bag),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Price
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Base Price',
                  hintText: 'Enter base price',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.attach_money),
                  prefixText: '₱ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a price';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Section Dropdown
              DropdownButtonFormField<int>(
                value: _selectedSectionId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Section',
                  hintText: 'Select a section',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: widget.sections.map((section) {
                  return DropdownMenuItem<int>(
                    value: section.id,
                    child: Text(section.name, style: textTheme.bodyMedium,),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSectionId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a section';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Category Dropdown
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Category',
                  hintText: widget.categories.isEmpty 
                      ? 'No categories available' 
                      : 'Select a category (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.label),
                ),
                items: [
                  DropdownMenuItem<int>(
                    value: null,
                    child: Text(
                      widget.categories.isEmpty ? 'No categories available' : 'No Category', 
                      style: textTheme.bodyMedium,
                    ),
                  ),
                  if (widget.categories.isNotEmpty)
                    ...widget.categories.map((category) {
                      if (kDebugMode) {
                        debugPrint('PRODUCT_FORM: Creating dropdown item for category: ${category.id} - ${category.name}');
                      }
                      return DropdownMenuItem<int>(
                        value: category.id,
                        child: Text(category.name, style: textTheme.bodyMedium,),
                      );
                    }),
                ],
                onChanged: (value) {
                  if (kDebugMode) {
                    debugPrint('PRODUCT_FORM: Category selection changed to: $value');
                  }
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              
              // Image Section
              _buildImageSection(),
              
              // Bottom spacing for better scrolling
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final productData = {
      'name': _nameController.text.trim(),
      'basePrice': double.parse(_priceController.text),
      'sectionId': _selectedSectionId!,
      'categoryId': _selectedCategoryId,
      'imageFile': _selectedImage,
      'removeCurrentImage': _currentImageUrl == null && widget.product?.imageUrl != null,
    };

    if (kDebugMode) {
      debugPrint('PRODUCT_FORM: Submitting product data: ${productData.toString().replaceAll('imageFile: File:', 'imageFile: [File]')}');
    }

    Navigator.of(context).pop(productData);
  }
} 