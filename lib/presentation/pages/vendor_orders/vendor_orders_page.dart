import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:iskxpress/core/widgets/vendor_bottom_nav_bar.dart';
import 'package:iskxpress/presentation/pages/vendor_orders/widgets/vendor_orders_app_bar.dart';
import 'package:iskxpress/presentation/pages/vendor_orders/widgets/vendor_order_card.dart';
import 'package:iskxpress/presentation/pages/vendor_orders/widgets/empty_orders_state.dart';
import 'package:iskxpress/core/services/order_api_service.dart';
import 'package:iskxpress/core/services/stall_api_service.dart';
import 'package:iskxpress/core/services/stall_state_service.dart';
import 'package:iskxpress/core/services/user_state_service.dart';
import 'package:iskxpress/core/models/order_model.dart';
import 'package:iskxpress/core/utils/date_formatter.dart';
import 'package:iskxpress/presentation/pages/vendor_orders/widgets/vendor_order_details_page.dart';
import 'package:iskxpress/presentation/pages/vendor_payments/vendor_payment_page.dart';

class VendorOrdersPage extends StatefulWidget {
  const VendorOrdersPage({super.key});

  static const String routeName = 'vendor_orders_page';

  @override
  State<VendorOrdersPage> createState() => _VendorOrdersPageState();
}

class _VendorOrdersPageState extends State<VendorOrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<OrderModel> _pendingOrders = [];
  List<OrderModel> _accomplishedOrders = [];
  bool _isLoading = false;
  double _pendingFees = 0.0;
  final StallStateService _stallStateService = StallStateService();
  final UserStateService _userStateService = UserStateService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    final currentUser = _userStateService.currentUser;
    if (currentUser == null) {
      if (kDebugMode) {
        debugPrint('VendorOrdersPage: No current user found');
      }
      return;
    }

    // Load stall for the current vendor
    await _stallStateService.loadStallForVendor(currentUser.id);
    final stall = _stallStateService.currentStall;
    
    if (stall == null) {
      if (kDebugMode) {
        debugPrint('VendorOrdersPage: No stall found for vendor');
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (kDebugMode) {
        debugPrint('VendorOrdersPage: Loading orders for stall ${stall.id}');
      }
      
      // Load orders and pending fees in parallel
      final orders = await OrderApiService.getOrdersForStall(stall.id);
      final pendingFees = await StallApiService.getPendingFees(stall.id);
      
      if (mounted) {
        setState(() {
          // Filter orders by status
          _pendingOrders = orders.where((order) => order.status < 4).toList();
          _accomplishedOrders = orders.where((order) => order.status == 4).toList();
          _pendingFees = pendingFees;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('VendorOrdersPage: Error loading orders: $e');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load orders: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: VendorOrdersAppBar(tabController: _tabController),
      bottomNavigationBar: const VendorBottomNavBar(currentIndex: 1),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Content for 'Pending Orders' tab
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _pendingOrders.isEmpty
                          ? const EmptyOrdersState(
                              title: 'No Pending Orders',
                              subtitle: 'You don\'t have any pending orders at the moment.',
                              icon: Icons.receipt_long,
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              itemCount: _pendingOrders.length,
                              itemBuilder: (context, index) {
                                final order = _pendingOrders[index];
                                return VendorOrderCard(
                                  orderId: order.id.toString(),
                                  customerName: 'Customer ${order.userId}', // You might want to get actual customer name
                                  itemCount: order.items.length,
                                  address: DateFormatter.truncateAddress(order.deliveryAddress ?? 'No address'),
                                  orderedAt: DateFormatter.formatOrderTime(order.createdAt),
                                  totalFee: order.totalPrice,
                                  deliveryFee: order.deliveryFee,
                                  statusText: order.statusText,
                                  fulfillmentMethod: order.fulfillmentMethodText,
                                  onViewDetails: () {
                                    if (kDebugMode) {
                                      debugPrint('View Details for order \\${order.id}');
                                    }
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => VendorOrderDetailsPage(orderId: order.id),
                                      ),
                                    );
                                  },
                                  onUpdateStatus: () {
                                    if (kDebugMode) {
                                      debugPrint('Update Status for order ${order.id}');
                                    }
                                    // TODO: Implement status update logic
                                  },
                                );
                              },
                            ),

                  // Content for 'Accomplished Orders' tab
                  _accomplishedOrders.isEmpty
                      ? const EmptyOrdersState(
                          title: 'No Accomplished Orders',
                          subtitle: 'You don\'t have any accomplished orders yet.',
                          icon: Icons.check_circle_outline,
                        )
                      : Column(
                          children: [
                            // Unpaid Fees Section
                            Container(
                              margin: const EdgeInsets.all(16.0),
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Unpaid Fees',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '₱${_pendingFees.toStringAsFixed(2)}',
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      final stall = _stallStateService.currentStall;
                                      if (stall != null) {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => VendorPaymentPage(stallId: stall.id),
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Pay Fees',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Accomplished Orders List
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                itemCount: _accomplishedOrders.length,
                                itemBuilder: (context, index) {
                                  final order = _accomplishedOrders[index];
                                  return VendorOrderCard(
                                    orderId: order.id.toString(),
                                    customerName: 'Customer ${order.userId}', // You might want to get actual customer name
                                    itemCount: order.items.length,
                                    address: DateFormatter.truncateAddress(order.deliveryAddress ?? 'No address'),
                                    orderedAt: DateFormatter.formatOrderTime(order.createdAt),
                                    totalFee: order.totalPrice,
                                    deliveryFee: order.deliveryFee,
                                    statusText: order.statusText,
                                    fulfillmentMethod: order.fulfillmentMethodText,
                                    onViewDetails: () {
                                      if (kDebugMode) {
                                        debugPrint('View Details for accomplished order \\${order.id}');
                                      }
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => VendorOrderDetailsPage(orderId: order.id),
                                        ),
                                      );
                                    },
                                    onUpdateStatus: null, // Disabled for accomplished orders
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 