import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:iskxpress/core/widgets/custom_bottom_nav_bar.dart';
import 'package:iskxpress/presentation/pages/deliveries/widgets/delivery_app_bar.dart';
import 'package:iskxpress/presentation/pages/deliveries/widgets/delivery_request_card.dart';
import 'package:iskxpress/presentation/pages/deliveries/widgets/your_delivery_card.dart';
import 'package:iskxpress/presentation/pages/deliveries/widgets/empty_delivery_state.dart';
import 'package:iskxpress/presentation/pages/deliveries/widgets/delivery_order_details_page.dart';
import 'package:iskxpress/core/services/order_api_service.dart';
import 'package:iskxpress/core/models/order_model.dart';
import 'package:iskxpress/core/utils/date_formatter.dart';
import 'package:iskxpress/core/services/user_state_service.dart';

class DeliveriesPage extends StatefulWidget {
  const DeliveriesPage({super.key});

  static const String routeName = 'deliveries_page';

  @override
  State<DeliveriesPage> createState() => _DeliveriesPageState();
}

class _DeliveriesPageState extends State<DeliveriesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<OrderModel> _deliveryRequests = [];
  List<OrderModel> _yourDeliveries = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDeliveryRequests();
    _loadActiveDeliveries();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDeliveryRequests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orders = await OrderApiService.getOrdersWithoutDeliveryPartner();
      if (mounted) {
        setState(() {
          _deliveryRequests = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DeliveriesPage: Error loading delivery requests: $e');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load delivery requests: $e')),
        );
      }
    }
  }

  Future<void> _loadActiveDeliveries() async {
    final userId = UserStateService().currentUser?.id;
    if (userId == null) {
      if (kDebugMode) {
        debugPrint('DeliveriesPage: No user found for loading active deliveries');
      }
      return;
    }

    try {
      if (kDebugMode) {
        debugPrint('DeliveriesPage: Loading active deliveries for userId: $userId');
      }
      
      final orders = await OrderApiService.getActiveDeliveriesForPartner(userId);
      if (mounted) {
        setState(() {
          _yourDeliveries = orders;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DeliveriesPage: Error loading active deliveries: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load active deliveries: $e')),
        );
      }
    }
  }

  Future<void> _acceptDelivery(OrderModel order) async {
    final userId = UserStateService().currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found. Please log in again.')),
      );
      return;
    }

    try {
      if (kDebugMode) {
        debugPrint('DeliveriesPage: Accepting delivery for order ${order.id} with userId: $userId');
      }
      
      final success = await OrderApiService.assignDeliveryPartner(order.id, userId);
      
      if (success && mounted) {
        // Remove the accepted order from the list
        setState(() {
          _deliveryRequests.removeWhere((o) => o.id == order.id);
        });
        
        // Refresh active deliveries to show the newly accepted order
        await _loadActiveDeliveries();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully accepted delivery for order #${order.id}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DeliveriesPage: Error accepting delivery: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept delivery: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DeliveryAppBar(tabController: _tabController),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 1),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Content for 'Delivery Requests' tab
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _deliveryRequests.isEmpty
                          ? const EmptyDeliveryState(
                              title: 'No Delivery Requests',
                              subtitle: 'There are currently no orders waiting for delivery partners.',
                              icon: Icons.local_shipping_outlined,
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              itemCount: _deliveryRequests.length,
                              itemBuilder: (context, index) {
                                final request = _deliveryRequests[index];
                                return DeliveryRequestCard(
                                  stallName: request.stallName,
                                  itemCount: request.items.length,
                                  address: DateFormatter.truncateAddress(request.deliveryAddress ?? 'No address'),
                                  orderedAt: DateFormatter.formatOrderTime(request.createdAt),
                                  orderId: request.id.toString(),
                                  totalFee: request.totalSellingPrice,
                                  deliveryFee: request.deliveryFee,
                                  onAcceptDelivery: () => _acceptDelivery(request),
                                  onViewDetails: () {
                                    if (kDebugMode) {
                                      debugPrint('View Details for request ${request.id}');
                                    }
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => DeliveryOrderDetailsPage(orderId: request.id),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),

                  // Content for 'Your Deliveries' tab
                  _yourDeliveries.isEmpty
                      ? const EmptyDeliveryState(
                          title: 'No Active Deliveries',
                          subtitle: 'You don\'t have any active deliveries at the moment.',
                          icon: Icons.delivery_dining_outlined,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          itemCount: _yourDeliveries.length,
                          itemBuilder: (context, index) {
                            final delivery = _yourDeliveries[index];
                            return YourDeliveryCard(
                              stallName: delivery.stallName,
                              itemCount: delivery.items.length,
                              address: DateFormatter.truncateAddress(delivery.deliveryAddress ?? 'No address'),
                              orderedAt: DateFormatter.formatOrderTime(delivery.createdAt),
                              orderId: delivery.id.toString(),
                              totalFee: delivery.totalSellingPrice,
                              deliveryFee: delivery.deliveryFee,
                              statusText: delivery.statusText,
                              onManageDelivery: () {
                                if (kDebugMode) {
                                  debugPrint('Manage Delivery for ${delivery.id}');
                                }
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => DeliveryOrderDetailsPage(orderId: delivery.id),
                                  ),
                                );
                              },
                            );
                          },
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