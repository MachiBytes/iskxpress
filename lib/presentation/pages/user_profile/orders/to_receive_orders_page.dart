import 'package:flutter/material.dart';
import 'package:iskxpress/core/models/order_model.dart';
import 'package:iskxpress/core/services/order_api_service.dart';
import 'package:iskxpress/core/services/user_state_service.dart';
import 'package:iskxpress/core/widgets/loading_screen.dart';
import 'package:iskxpress/presentation/pages/user_profile/widgets/order_details_page.dart';
import 'package:iskxpress/presentation/pages/user_profile/orders/widgets/order_card.dart';

class ToReceiveOrdersPage extends StatefulWidget {
  const ToReceiveOrdersPage({super.key});

  static const String routeName = 'to_receive_orders_page';

  @override
  State<ToReceiveOrdersPage> createState() => _ToReceiveOrdersPageState();
}

class _ToReceiveOrdersPageState extends State<ToReceiveOrdersPage> {
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userState = UserStateService();
      final currentUser = userState.currentUser;
      
      if (currentUser == null) {
        setState(() {
          _error = 'User not found';
          _isLoading = false;
        });
        return;
      }

      // Load orders with status 3 (ToReceive)
      final orders = await OrderApiService.getUserOrders(currentUser.id, status: 3);
      
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load orders: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('To Receive'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
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
                        onPressed: _loadOrders,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _orders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delivery_dining,
                            size: 64,
                            color: colorScheme.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No orders to receive',
                            style: textTheme.headlineSmall?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Orders that are out for delivery will appear here',
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadOrders,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          return OrderCard(
                            order: order,
                            statusText: 'To Receive',
                            statusColor: Colors.green,
                            onViewDetails: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderDetailsPage(orderId: order.id),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
    );
  }
} 