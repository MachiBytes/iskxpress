import 'package:flutter/material.dart';
import 'package:iskxpress/core/models/order_model.dart';
import 'package:iskxpress/core/services/order_api_service.dart';
import 'package:iskxpress/core/widgets/loading_screen.dart';
import 'package:iskxpress/core/utils/date_formatter.dart';
import 'package:iskxpress/core/services/user_state_service.dart';

class VendorOrderDetailsPage extends StatefulWidget {
  final int orderId;
  const VendorOrderDetailsPage({super.key, required this.orderId});

  @override
  State<VendorOrderDetailsPage> createState() => _VendorOrderDetailsPageState();
}

class _VendorOrderDetailsPageState extends State<VendorOrderDetailsPage> {
  OrderModel? _order;
  bool _isLoading = true;
  String? _error;
  bool _isUpdatingStatus = false;
  final TextEditingController _rejectionReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final order = await OrderApiService.getOrderById(widget.orderId);
      setState(() {
        _order = order;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load order: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateOrderStatus(int newStatus) async {
    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      await OrderApiService.updateOrderStatus(widget.orderId, newStatus);
      // Reload the order to get updated data
      await _loadOrder();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update order status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUpdatingStatus = false;
      });
    }
  }

  Future<void> _showRejectionDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reject Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please provide a reason for rejecting this order:'),
              const SizedBox(height: 16),
              TextField(
                controller: _rejectionReasonController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Rejection Reason',
                  hintText: 'Enter reason for rejection...',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Reject'),
              onPressed: () async {
                if (_rejectionReasonController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop();
                  
                  setState(() {
                    _isUpdatingStatus = true;
                  });

                  try {
                    await OrderApiService.rejectOrder(widget.orderId, _rejectionReasonController.text.trim());
                    // Reload the order to get updated data
                    await _loadOrder();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to reject order: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } finally {
                    setState(() {
                      _isUpdatingStatus = false;
                    });
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please provide a rejection reason'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons(ColorScheme colorScheme, TextTheme textTheme) {
    if (_order == null) return const SizedBox.shrink();

    final currentUserId = UserStateService().currentUser?.id;
    final isVendorOrder = _order!.deliveryPartnerId == currentUserId;
    final isDelivery = _order!.fulfillmentMethod == 1;

    // Status 0: Pending - Show Accept/Reject buttons
    if (_order!.status == 0) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _isUpdatingStatus ? null : () => _updateOrderStatus(1),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isUpdatingStatus
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Accept Order',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isUpdatingStatus ? null : _showRejectionDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Text(
                'Reject Order',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Status 2: Product picked up
    if (_order!.status == 2) {
      return ElevatedButton(
        onPressed: _isUpdatingStatus ? null : () => _updateOrderStatus(3),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isUpdatingStatus
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Product picked up',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
      );
    }

    // Case 1: Vendor is the delivery partner
    if (isVendorOrder) {
      if (_order!.status == 1) {
        return ElevatedButton(
          onPressed: _isUpdatingStatus ? null : () => _updateOrderStatus(3),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: _isUpdatingStatus
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  isDelivery ? 'Ready to receive' : 'Ready to pickup',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary,
                  ),
                ),
        );
      } else if (_order!.status == 3) {
        return ElevatedButton(
          onPressed: _isUpdatingStatus ? null : () => _updateOrderStatus(4),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: _isUpdatingStatus
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Order Received!',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary,
                  ),
                ),
        );
      }
    }

    // Case 2: Vendor is not the delivery partner but fulfillment is delivery
    if (!isVendorOrder && isDelivery) {
      if (_order!.status == 1) {
        return ElevatedButton(
          onPressed: _isUpdatingStatus ? null : () => _updateOrderStatus(2),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: _isUpdatingStatus
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Ready for delivery',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary,
                  ),
                ),
        );
      } else if (_order!.status == 2) {
        return ElevatedButton(
          onPressed: null, // Disabled
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            'Waiting for delivery',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      } else if (_order!.status == 3) {
        return ElevatedButton(
          onPressed: null, // Disabled
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            'Waiting to be received',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      } else if (_order!.status == 4) {
        return ElevatedButton(
          onPressed: null, // Disabled
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            'Order Finished!',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }
    }

    // Default case: no action buttons
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        titleTextStyle: textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary),
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const LoadingScreen()
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadOrder,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _order == null
                  ? const Center(child: Text('Order not found'))
                  : Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Order header information
                                _buildOrderHeader(colorScheme, textTheme),
                                const SizedBox(height: 16),
                                
                                // Order details
                                _buildOrderDetails(colorScheme, textTheme),
                                const SizedBox(height: 16),
                                
                                // Products section
                                Text('Products', style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface)),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: _buildProductsList(colorScheme, textTheme),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Action Buttons
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          child: _buildActionButtons(colorScheme, textTheme),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildOrderHeader(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _order!.stallName,
          style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(_order!.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor(_order!.status),
                  width: 1,
                ),
              ),
              child: Text(
                _order!.statusText,
                style: textTheme.bodySmall?.copyWith(
                  color: _getStatusColor(_order!.status),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.onPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.onPrimary,
                  width: 1,
                ),
              ),
              child: Text(
                _order!.fulfillmentMethodText,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderDetails(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order #${_order!.id}',
          style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          'Date: ${DateFormatter.formatOrderTime(_order!.createdAt)}',
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          'Subtotal: ₱${_order!.totalPrice.toStringAsFixed(2)}',
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        ),
        if (_order!.totalCommissionFee > 0) ...[
          const SizedBox(height: 8),
          Text(
            'Commission Fee: ₱${_order!.totalCommissionFee.toStringAsFixed(2)}',
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
          ),
        ],
        if (_order!.deliveryFee > 0) ...[
          const SizedBox(height: 8),
          Text(
            'Delivery Fee: ₱${_order!.deliveryFee.toStringAsFixed(2)}',
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          'Total: ₱${_order!.finalTotal.toStringAsFixed(2)}',
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (_order!.deliveryAddress != null) ...[
          const SizedBox(height: 8),
          Text(
            'Delivery Address: ${_order!.deliveryAddress}',
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
          ),
        ],
        if (_order!.notes != null && _order!.notes!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Notes: ${_order!.notes}',
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
          ),
        ],
      ],
    );
  }

  Widget _buildProductsList(ColorScheme colorScheme, TextTheme textTheme) {
    return ListView.builder(
      itemCount: _order!.items.length,
      itemBuilder: (context, idx) {
        final item = _order!.items[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 3,
          shadowColor: colorScheme.shadow,
          child: ListTile(
            leading: item.productPictureUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.productPictureUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.fastfood,
                          size: 24,
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                  )
                : Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.fastfood,
                      size: 24,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
            title: Text(
              item.productName,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.productDescription != null) ...[
                  Text(
                    item.productDescription!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  '₱${item.priceEach.toStringAsFixed(2)} each × ${item.quantity}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            trailing: Text(
              '₱${item.totalPrice.ceil()}',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.green;
      case 4:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
} 