import 'package:flutter/material.dart';
import '../vendor_home_page.dart';
import '../../../../core/models/product_model.dart';
import '../../../../core/models/section_model.dart';
import '../../../../core/models/category_model.dart';
import '../../../../core/services/product_api_service.dart';

class ProductSectionWidget extends StatelessWidget {
  final SectionWithProducts section;
  final Function(ProductModel) onEditProduct;
  final Function(ProductModel) onDeleteProduct;
  final Function(SectionModel) onAddProduct;
  final Function(SectionModel) onEditSection;
  final Function(SectionModel) onDeleteSection;
  final List<CategoryModel> categories;

  const ProductSectionWidget({
    super.key,
    required this.section,
    required this.onEditProduct,
    required this.onDeleteProduct,
    required this.onAddProduct,
    required this.onEditSection,
    required this.onDeleteSection,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title with Edit/Delete options
          Row(
            children: [
              Expanded(
                child: Text(
                  section.section.name,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEditSection(section.section);
                      break;
                    case 'delete':
                      onDeleteSection(section.section);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Edit Section'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete Section', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: Icon(
                  Icons.more_vert,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Products List
          if (section.products.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 40,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No products in this section',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          else
            ...section.products.map((product) => ProductTile(
              product: product,
              categories: categories,
              onEdit: () => onEditProduct(product),
              onDelete: () => onDeleteProduct(product),
            )),

          // Add Item Button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 12),
            child: ElevatedButton(
              onPressed: () => onAddProduct(section.section),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Add Item',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductTile extends StatefulWidget {
  final ProductModel product;
  final List<CategoryModel> categories;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductTile({
    super.key,
    required this.product,
    required this.categories,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile> {
  bool _isLoading = false;
  late int _availability;

  @override
  void initState() {
    super.initState();
    _availability = widget.product.availability;
  }

  String? _getCategoryName() {
    if (widget.product.categoryId == null) return null;
    try {
      final category = widget.categories.firstWhere(
        (cat) => cat.id == widget.product.categoryId,
      );
      return category.name;
    } catch (e) {
      return null;
    }
  }

  Future<void> _toggleAvailability(bool value) async {
    setState(() {
      _isLoading = true;
    });
    final newAvailability = value ? 0 : 1; // true = available, false = sold out
    final success = await ProductApiService.updateProductAvailability(
      productId: widget.product.id,
      availability: newAvailability,
    );
    if (success) {
      setState(() {
        _availability = newAvailability;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newAvailability == 0 ? 'Product marked as available' : 'Product marked as sold out'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update product availability'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final categoryName = _getCategoryName();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: widget.product.imageUrl != null
                  ? Image.network(
                      widget.product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.coffee,
                          color: Colors.brown[300],
                          size: 30,
                        );
                      },
                    )
                  : Icon(
                      Icons.coffee,
                      color: Colors.brown[300],
                      size: 30,
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                // Base Price
                Text(
                  'Base: ₱ ${widget.product.basePrice.toStringAsFixed(2)}',
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                // Selling Price with Markup
                Text(
                  'Sell: ₱ ${widget.product.sellingPrice.toStringAsFixed(2)}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (categoryName != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Text(
                      categoryName,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.blue[700],
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      _availability == 0 ? 'Available' : 'Sold Out',
                      style: textTheme.bodySmall?.copyWith(
                        color: _availability == 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: _availability == 0,
                      onChanged: _isLoading ? null : _toggleAvailability,
                      activeColor: Colors.green,
                      inactiveThumbColor: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: widget.onEdit,
                icon: const Icon(
                  Icons.edit,
                  color: Colors.grey,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.all(8),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: widget.onDelete,
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 