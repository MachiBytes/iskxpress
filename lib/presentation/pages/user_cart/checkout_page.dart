import 'package:flutter/material.dart';
import 'package:iskxpress/core/models/cart_item_model.dart';
import 'package:iskxpress/core/services/cart_api_service.dart';
import 'package:iskxpress/presentation/pages/user_home/user_home_page.dart';

class CheckoutPage extends StatefulWidget {
  final int userId;
  final List<CartItemModel> cartItems;

  const CheckoutPage({super.key, required this.userId, required this.cartItems});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int _fulfillmentMethod = 0; // 0 = Pickup, 1 = Delivery
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  double get _totalPrice {
    double total = 0;
    Set<int> uniqueStalls = {};
    
    for (final item in widget.cartItems) {
      // Use priceWithMarkup for all items
      final price = item.product.priceWithMarkup ?? item.product.sellingPrice;
      total += price * item.quantity;
      
      // Track unique stalls for delivery fee calculation
      uniqueStalls.add(item.stallId);
    }
    
    // Add delivery fee: ₱10 per unique stall
    if (_fulfillmentMethod == 1) {
      total += uniqueStalls.length * 10;
    }
    
    return total;
  }

  Future<void> _handleCheckout() async {
    if (_fulfillmentMethod == 1 && _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a delivery address.')),
      );
      return;
    }
    setState(() { _isLoading = true; });
    try {
      final response = await CartApiService.multiCheckout(
        userId: widget.userId,
        cartItemIds: widget.cartItems.map((e) => e.id).toList(),
        fulfillmentMethod: _fulfillmentMethod,
        deliveryAddress: _fulfillmentMethod == 1 ? _addressController.text.trim() : null,
        notes: _notesController.text.trim(),
      );
      if (response) {
        // Remove checked cart items (handled by backend, but refresh cart on home)
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const UserHomePage()),
            (route) => false,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Checkout failed. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout error: $e')),
      );
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        title: const Text('Checkout'),
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        titleTextStyle: textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fulfillment Method', style: textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary)),
                Row(
                  children: [
                    Radio<int>(
                      value: 0,
                      groupValue: _fulfillmentMethod,
                      onChanged: (val) => setState(() => _fulfillmentMethod = val ?? 0),
                      activeColor: colorScheme.onPrimary,
                    ),
                    Text('Pickup', style: textTheme.bodyLarge?.copyWith(color: colorScheme.onPrimary)),
                    const SizedBox(width: 24),
                    Radio<int>(
                      value: 1,
                      groupValue: _fulfillmentMethod,
                      onChanged: (val) => setState(() => _fulfillmentMethod = val ?? 0),
                      activeColor: colorScheme.onPrimary,
                    ),
                    Text('Delivery', style: textTheme.bodyLarge?.copyWith(color: colorScheme.onPrimary)),
                  ],
                ),
                if (_fulfillmentMethod == 1) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Delivery fee: ₱10 per stall',
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.orange[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Delivery', style: textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      hintText: 'Address (Building / Floor / Room)',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Notes for Delivery', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Notes for Delivery',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary)),
                    Text('₱${_totalPrice.toStringAsFixed(2)}', style: textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.surface,
                      foregroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : Text('Checkout', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 