import 'package:flutter/material.dart';
import 'package:iskxpress/core/models/order_model.dart';
import 'package:iskxpress/core/services/order_api_service.dart';
import 'package:iskxpress/core/widgets/loading_screen.dart';

class OrderDetailsPage extends StatefulWidget {
  final int orderId;
  const OrderDetailsPage({super.key, required this.orderId});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  OrderModel? _order;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrder();
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
                  : Padding(
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
          'Date: ${_order!.createdAtString}',
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          'Subtotal: ₱${_order!.totalPrice.toStringAsFixed(2)}',
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        ),
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
        if (_order!.status == 5 && _order!.rejectionReason != null && _order!.rejectionReason!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.cancel_outlined,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rejection Reason',
                      style: textTheme.titleSmall?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _order!.rejectionReason!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
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
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
} 