import 'package:flutter/material.dart';
import 'package:iskxpress/core/models/stall_model.dart';
import 'package:iskxpress/core/models/section_model.dart';
import 'package:iskxpress/core/models/product_model.dart';
import 'package:iskxpress/core/models/user_model.dart';
import 'package:iskxpress/core/services/section_api_service.dart';
import 'package:iskxpress/core/services/product_api_service.dart';
import 'package:iskxpress/core/services/cart_api_service.dart';
import 'package:iskxpress/core/services/user_state_service.dart';
import 'package:iskxpress/core/utils/pricing_utils.dart';
import 'package:iskxpress/presentation/pages/user_product_view/widgets/user_product_app_bar.dart';
import 'package:iskxpress/presentation/pages/user_cart/user_cart_page.dart';
import 'package:iskxpress/core/helpers/navigation_helper.dart';
import 'package:flutter/foundation.dart';

class UserProductPage extends StatefulWidget {
  final StallModel stall;
  
  const UserProductPage({
    super.key,
    required this.stall,
  });

  static const String routeName = 'user_product_page';

  @override
  State<UserProductPage> createState() => _UserProductPageState();
}

class _UserProductPageState extends State<UserProductPage>
    with SingleTickerProviderStateMixin {
  
  TabController? _tabController;
  List<SectionModel> sections = [];
  List<ProductModel> products = [];
  bool isLoading = true;
  String? errorMessage;

  // Map to store products by section ID
  Map<int, List<ProductModel>> productsBySection = {};

  @override
  void initState() {
    super.initState();
    _loadStallData();
  }

  Future<void> _loadStallData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Load sections and products in parallel
      final sectionsResult = SectionApiService.getStallSections(widget.stall.id);
      final productsResult = ProductApiService.getStallProducts(widget.stall.id);

      final results = await Future.wait([sectionsResult, productsResult]);
      final loadedSections = results[0] as List<SectionModel>;
      final loadedProducts = results[1] as List<ProductModel>;

      // Organize products by section
      final Map<int, List<ProductModel>> organizedProducts = {};
      for (final section in loadedSections) {
        organizedProducts[section.id] = [];
      }
      
      for (final product in loadedProducts) {
        if (organizedProducts.containsKey(product.sectionId)) {
          organizedProducts[product.sectionId]!.add(product);
        }
      }

      setState(() {
        sections = loadedSections;
        products = loadedProducts;
        productsBySection = organizedProducts;
        isLoading = false;
        
        // Initialize TabController after sections are loaded
        if (sections.isNotEmpty) {
          _tabController = TabController(
            length: sections.length,
            vsync: this,
          );
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load stall data: $e';
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: UserProductAppBar(stallName: widget.stall.name),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                        const SizedBox(height: 16),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colorScheme.error),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadStallData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : sections.isEmpty
                  ? const Center(
                      child: Text(
                        'No sections available for this stall',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : Column(
                      children: [
                        // TabBar
                        Container(
                          color: colorScheme.surface,
                          child: TabBar(
                            controller: _tabController,
                            isScrollable: true,
                            labelColor: colorScheme.primary,
                            unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.6),
                            indicatorColor: colorScheme.primary,
                            tabs: sections.map((section) {
                              return Tab(
                                text: section.name,
                              );
                            }).toList(),
                          ),
                        ),
                        
                        // TabBarView with products
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: sections.map((section) {
                              final sectionProducts = productsBySection[section.id] ?? [];
                              return _buildProductList(sectionProducts);
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildProductList(List<ProductModel> sectionProducts) {
    if (sectionProducts.isEmpty) {
      return const Center(
        child: Text(
          'No products available in this section',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.75, // Adjust to accommodate image + labels
      ),
      itemCount: sectionProducts.length,
      itemBuilder: (context, index) {
        final product = sectionProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isSoldOut = product.availability == 1;
    final userStateService = UserStateService();
    final user = userStateService.currentUser;
    final price = PricingUtils.getPriceForUser(product, user);
    final regularPrice = PricingUtils.getRegularPrice(product);
    final isPremium = user?.premium == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image with stacked add button (1:1 aspect ratio)
        Expanded(
          child: Stack(
            children: [
              // Main image container with gray-out if sold out
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: colorScheme.surfaceContainerHighest,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 1.0, // Perfect 1:1 ratio
                    child: ColorFiltered(
                      colorFilter: isSoldOut
                          ? const ColorFilter.mode(
                              Colors.grey, BlendMode.saturation)
                          : const ColorFilter.mode(
                              Colors.transparent, BlendMode.multiply),
                      child: product.imageUrl != null
                          ? Image.network(
                              product.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.fastfood,
                                size: 48,
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            )
                          : Icon(
                              Icons.fastfood,
                              size: 48,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                    ),
                  ),
                ),
              ),
              // Sold out watermark
              if (isSoldOut)
                Positioned.fill(
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Sold out',
                      style: textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // Add button positioned on bottom-right of image
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSoldOut ? Colors.grey : colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: isSoldOut
                        ? null
                        : () async {
                            final userId = UserStateService().currentUser?.id;
                            if (kDebugMode) {
                              debugPrint('UserProductPage: Add to cart pressed, userId: $userId');
                              debugPrint('UserProductPage: Product: ${product.name} (ID: ${product.id})');
                            }
                            if (userId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('User not found. Please log in again.')),
                              );
                              return;
                            }
                            try {
                              if (kDebugMode) {
                                debugPrint('UserProductPage: Calling addToCart API...');
                              }
                              await CartApiService.addToCart(userId: userId, productId: product.id, quantity: 1);
                              if (!mounted) return;
                              if (kDebugMode) {
                                debugPrint('UserProductPage: Add to cart successful, navigating to cart page');
                              }
                              NavHelper.pushPageTo(context, UserCartPage(userId: userId));
                            } catch (e) {
                              if (kDebugMode) {
                                debugPrint('UserProductPage: Add to cart failed: $e');
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to add to cart: $e')),
                              );
                            }
                          },
                    icon: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 16,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Product name
        Text(
          product.name,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isSoldOut ? Colors.grey : null,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        // Price with premium indicator
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '₱${price.toStringAsFixed(2)}',
              style: textTheme.titleSmall?.copyWith(
                color: isSoldOut ? Colors.grey : colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isPremium && !isSoldOut) ...[
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Text(
                  'Premium',
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
