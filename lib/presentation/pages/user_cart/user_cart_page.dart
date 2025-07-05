import 'package:flutter/material.dart';
import 'package:iskxpress/core/models/user_cart_model.dart';
import 'package:iskxpress/core/models/cart_item_model.dart';
import 'package:iskxpress/core/services/cart_api_service.dart';
import 'package:iskxpress/core/widgets/custom_app_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:iskxpress/presentation/pages/user_cart/checkout_page.dart';

class UserCartPage extends StatefulWidget {
  final int userId;
  const UserCartPage({super.key, required this.userId});

  @override
  State<UserCartPage> createState() => _UserCartPageState();
}

class _UserCartPageState extends State<UserCartPage> {
  late Future<UserCartModel> _cartFuture;
  final Map<int, bool> _stallSelection = {};
  final bool _isLoading = false;
  UserCartModel? _currentCart; // Cache the current cart data
  final Map<int, bool> _updatingItems = {}; // Track which items are being updated

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      debugPrint('UserCartPage: Initializing with userId: ${widget.userId}');
    }
    _cartFuture = CartApiService.getUserCart(widget.userId);
  }

  Future<void> _refreshCart() async {
    if (kDebugMode) {
      debugPrint('UserCartPage: Refreshing cart for userId: ${widget.userId}');
    }
    setState(() {
      _cartFuture = CartApiService.getUserCart(widget.userId);
    });
  }

  Future<void> _updateQuantity(int cartItemId, int quantity) async {
    // Optimistic update - update UI immediately
    if (_currentCart != null) {
      final updatedItems = _currentCart!.items.map((item) {
        if (item.id == cartItemId) {
          return CartItemModel(
            id: item.id,
            productId: item.productId,
            stallId: item.stallId,
            stallName: item.stallName,
            stallPictureUrl: item.stallPictureUrl,
            product: item.product,
            quantity: quantity,
          );
        }
        return item;
      }).toList();

      setState(() {
        _currentCart = UserCartModel(items: updatedItems);
        _updatingItems[cartItemId] = true;
      });
    }

    // Call API in background
    try {
      await CartApiService.updateCartItemQuantity(userId: widget.userId, cartItemId: cartItemId, quantity: quantity);
      if (kDebugMode) {
        debugPrint('UserCartPage: Quantity updated successfully for item $cartItemId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('UserCartPage: Failed to update quantity for item $cartItemId: $e');
      }
      // Revert optimistic update on error
      if (_currentCart != null) {
        await _refreshCart();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update quantity: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _updatingItems[cartItemId] = false;
        });
      }
    }
  }

  Future<void> _removeItem(int cartItemId) async {
    // Optimistic update - remove item immediately from UI
    if (_currentCart != null) {
      final updatedItems = _currentCart!.items.where((item) => item.id != cartItemId).toList();
      
      setState(() {
        _currentCart = UserCartModel(items: updatedItems);
        _updatingItems[cartItemId] = true;
      });
    }

    // Call API in background
    try {
      await CartApiService.removeCartItem(userId: widget.userId, cartItemId: cartItemId);
      if (kDebugMode) {
        debugPrint('UserCartPage: Item removed successfully: $cartItemId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('UserCartPage: Failed to remove item $cartItemId: $e');
      }
      // Revert optimistic update on error
      if (_currentCart != null) {
        await _refreshCart();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove item: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _updatingItems[cartItemId] = false;
        });
      }
    }
  }

  double _calculateTotal(UserCartModel cart) {
    double total = 0;
    for (final item in cart.items) {
      final price = item.product.priceWithDelivery ?? item.product.sellingPrice;
      total += price * item.quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: CustomAppBar(
        onCartPressed: null,
      ),
      body: FutureBuilder<UserCartModel>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.onPrimary),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading cart: ${snapshot.error}',
                    style: textTheme.bodyLarge?.copyWith(color: colorScheme.onPrimary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshCart,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Cache the cart data for optimistic updates
          if (snapshot.hasData && _currentCart == null) {
            _currentCart = snapshot.data!;
          }

          // Use cached cart data if available, otherwise use snapshot data
          final cart = _currentCart ?? snapshot.data;
          
          if (cart == null || cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: colorScheme.onPrimary.withOpacity(0.7)),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add some items to get started',
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary.withOpacity(0.7)),
                  ),
                ],
              ),
            );
          }

          final itemsByStall = cart.itemsByStall;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ...itemsByStall.entries.map((entry) {
                      final stallId = entry.key;
                      final items = entry.value;
                      final stallName = items.first.stallName;
                      final isChecked = _stallSelection[stallId] ?? false;
                      
                      return Container(
                        width: double.infinity,
                        margin: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Stall header
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isChecked,
                                    onChanged: (val) {
                                      setState(() {
                                        _stallSelection[stallId] = val ?? false;
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: Text(
                                      stallName,
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Cart items
                            ...items.map((item) => _buildCartItem(item, colorScheme, textTheme)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              // Bottom section with total and checkout
              Container(
                color: colorScheme.surface,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '₱${_calculateTotal(cart).toStringAsFixed(2)}',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: cart.items.isNotEmpty ? () {
                          // Collect checked stall groups
                          final checkedStallIds = _stallSelection.entries
                              .where((e) => e.value)
                              .map((e) => e.key)
                              .toList();
                          if (checkedStallIds.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select at least one stall group to checkout.')),
                            );
                            return;
                          }
                          // Collect cart items from checked stall groups
                          final selectedCartItems = cart.items
                              .where((item) => checkedStallIds.contains(item.stallId))
                              .toList();
                          if (selectedCartItems.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No items found for selected stall groups.')),
                            );
                            return;
                          }
                          // Navigate to CheckoutPage
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CheckoutPage(
                                userId: widget.userId,
                                cartItems: selectedCartItems,
                              ),
                            ),
                          );
                        } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'Proceed to Checkout',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(CartItemModel item, ColorScheme colorScheme, TextTheme textTheme) {
    final price = item.product.priceWithDelivery ?? item.product.sellingPrice;
    final totalPrice = price * item.quantity;
    final isUpdating = _updatingItems[item.id] ?? false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.product.imageUrl != null
                ? Image.network(
                    item.product.imageUrl!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 64,
                      height: 64,
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.fastfood, size: 32, color: colorScheme.onSurface.withOpacity(0.5)),
                    ),
                  )
                : Container(
                    width: 64,
                    height: 64,
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.fastfood, size: 32, color: colorScheme.onSurface.withOpacity(0.5)),
                  ),
          ),
          const SizedBox(width: 16),
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '₱${price.toStringAsFixed(2)}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                // Quantity controls
                Row(
                  children: [
                    // Remove button
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline, 
                        size: 18, 
                        color: isUpdating ? colorScheme.onSurface.withOpacity(0.3) : Colors.red,
                      ),
                      onPressed: isUpdating ? null : () => _removeItem(item.id),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    const SizedBox(width: 8),
                    // Quantity controls
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.remove,
                            size: 18,
                            color: isUpdating || _isLoading || item.quantity <= 1 
                                ? colorScheme.onSurface.withOpacity(0.3)
                                : colorScheme.primary,
                          ),
                          onPressed: isUpdating || _isLoading || item.quantity <= 1
                              ? null
                              : () => _updateQuantity(item.id, item.quantity - 1),
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: isUpdating 
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                                  ),
                                )
                              : Text(
                                  '${item.quantity}',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.add,
                            size: 18,
                            color: isUpdating || _isLoading || item.quantity >= 99
                                ? colorScheme.onSurface.withOpacity(0.3)
                                : colorScheme.primary,
                          ),
                          onPressed: isUpdating || _isLoading || item.quantity >= 99
                              ? null
                              : () => _updateQuantity(item.id, item.quantity + 1),
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Total price for this item
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₱${totalPrice.toStringAsFixed(2)}',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              if (item.quantity > 1)
                Text(
                  '${item.quantity} × ₱${price.toStringAsFixed(2)}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
} 