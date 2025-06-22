import 'package:flutter/material.dart';
import 'package:iskxpress/core/widgets/custom_bottom_nav_bar.dart';
import 'package:iskxpress/presentation/pages/deliveries/widgets/delivery_app_bar.dart';
import 'package:iskxpress/presentation/pages/deliveries/widgets/delivery_request_card.dart';
import 'package:iskxpress/presentation/pages/deliveries/widgets/your_delivery_card.dart';

class DeliveriesPage extends StatefulWidget {
  const DeliveriesPage({super.key});

  static const String routeName = 'deliveries_page';

  @override
  State<DeliveriesPage> createState() => _DeliveriesPageState();
}

class _DeliveriesPageState extends State<DeliveriesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock Data for demonstration
  final List<Map<String, dynamic>> _deliveryRequests = [
    {
      'stallName': 'Fudbook Kitchen',
      'itemCount': 4,
      'address': 'Main Building, N512',
      'orderedAt': '4:05 PM',
      'orderId': '2364',
      'totalFee': 315.00,
      'deliveryFee': 25.00,
    },
    {
      'stallName': 'Trinas',
      'itemCount': 3,
      'address': 'Main Building, E207',
      'orderedAt': '4:12 PM',
      'orderId': '112',
      'totalFee': 205.00,
      'deliveryFee': 20.00,
    },
    {
      'stallName': 'Kape Kuripot',
      'itemCount': 2,
      'address': 'Main Building, W308',
      'orderedAt': '4:12 PM',
      'orderId': '4009',
      'totalFee': 78.00,
      'deliveryFee': 15.00,
    },
  ];

  final List<Map<String, dynamic>> _yourDeliveries = [
    {
      'stallName': 'Kape Kuripot',
      'itemCount': 8,
      'address': 'Main Building, S506',
      'orderedAt': '4:06 PM',
      'orderId': '3998',
      'totalFee': 80.00,
      'deliveryFee': 15.00,
      'statusText': 'Preparing',
    },
    {
      'stallName': 'Go Healthy',
      'itemCount': 1,
      'address': 'Main Building, G008',
      'orderedAt': '4:06 PM',
      'orderId': '214',
      'totalFee': 70.00,
      'deliveryFee': 10.00,
      'statusText': 'Items Delivered',
    },
    {
      'stallName': 'Chick N\' Rice',
      'itemCount': 5,
      'address': 'Main Building, L101',
      'orderedAt': '4:30 PM',
      'orderId': '5001',
      'totalFee': 120.00,
      'deliveryFee': 18.00,
      'statusText': 'For Pickup',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                  _deliveryRequests.isEmpty
                      ? const Center(child: Text('No delivery requests available.'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          itemCount: _deliveryRequests.length,
                          itemBuilder: (context, index) {
                            final request = _deliveryRequests[index];
                            return DeliveryRequestCard(
                              stallName: request['stallName'],
                              itemCount: request['itemCount'],
                              address: request['address'],
                              orderedAt: request['orderedAt'],
                              orderId: request['orderId'],
                              totalFee: request['totalFee'],
                              deliveryFee: request['deliveryFee'],
                              onAcceptDelivery: () {
                                print('Accepted ${request['orderId']}');
                                // TODO: Implement accept delivery logic
                              },
                              onViewDetails: () {
                                print('View Details for request ${request['orderId']}');
                                // TODO: Navigate to Order Details Page
                              },
                            );
                          },
                        ),

                  // Content for 'Your Deliveries' tab
                  _yourDeliveries.isEmpty
                      ? const Center(child: Text('You have no active deliveries.'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          itemCount: _yourDeliveries.length,
                          itemBuilder: (context, index) {
                            final delivery = _yourDeliveries[index];
                            return YourDeliveryCard(
                              stallName: delivery['stallName'],
                              itemCount: delivery['itemCount'],
                              address: delivery['address'],
                              orderedAt: delivery['orderedAt'],
                              orderId: delivery['orderId'],
                              totalFee: delivery['totalFee'],
                              deliveryFee: delivery['deliveryFee'],
                              statusText: delivery['statusText'],
                              // Assigning the new callbacks
                              onManageDelivery: () {
                                print('Manage Delivery for ${delivery['orderId']}');
                                // TODO: Navigate to a detailed management page for this delivery
                              },
                              onCancelDelivery: () {
                                print('Cancel Delivery for ${delivery['orderId']}');
                                // TODO: Implement cancel delivery logic (e.g., show confirmation dialog)
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