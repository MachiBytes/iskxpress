import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:iskxpress/core/widgets/custom_bottom_nav_bar.dart';
import 'package:iskxpress/core/services/order_api_service.dart';
import 'package:iskxpress/core/models/order_model.dart';
import 'package:iskxpress/core/utils/date_formatter.dart';
import 'package:iskxpress/core/services/user_state_service.dart';
import 'package:iskxpress/presentation/pages/user_profile/widgets/order_details_page.dart';

class DeliveryHistoryPage extends StatefulWidget {
  const DeliveryHistoryPage({super.key});

  static const String routeName = 'delivery_history_page';

  @override
  State<DeliveryHistoryPage> createState() => _DeliveryHistoryPageState();
}

class _DeliveryHistoryPageState extends State<DeliveryHistoryPage> {
  List<OrderModel> _deliveryHistory = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDeliveryHistory();
  }

  Future<void> _loadDeliveryHistory() async {
    setState(() {
      _isLoading = true;
    });

    final userId = UserStateService().currentUser?.id;
    if (userId == null) {
      if (kDebugMode) {
        debugPrint('DeliveryHistoryPage: No user found for loading delivery history');
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      if (kDebugMode) {
        debugPrint('DeliveryHistoryPage: Loading delivery history for userId: $userId');
      }
      
      final orders = await OrderApiService.getFinishedDeliveriesForPartner(userId);
      if (mounted) {
        setState(() {
          _deliveryHistory = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DeliveryHistoryPage: Error loading delivery history: $e');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load delivery history: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        title: const Text('Delivery History'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          IconButton(
            onPressed: () {
              final userId = UserStateService().currentUser?.id;
              if (kDebugMode) {
                debugPrint('DeliveryHistoryPage: Cart pressed, userId: $userId');
              }
              if (userId != null) {
                Navigator.of(context).pushNamed('/user_cart', arguments: userId);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User not found. Please log in again.')),
                );
              }
            },
            icon: Icon(Icons.shopping_cart, color: colorScheme.onPrimary),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _deliveryHistory.isEmpty
                  ? _buildEmptyState()
                  : _buildDeliveryHistoryList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Delivery History',
            style: textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You haven\'t completed any deliveries yet.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryHistoryList() {
    return RefreshIndicator(
      onRefresh: _loadDeliveryHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _deliveryHistory.length,
        itemBuilder: (context, index) {
          final delivery = _deliveryHistory[index];
          return _DeliveryHistoryCard(
            delivery: delivery,
            onViewDetails: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OrderDetailsPage(orderId: delivery.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _DeliveryHistoryCard extends StatelessWidget {
  final OrderModel delivery;
  final VoidCallback onViewDetails;

  const _DeliveryHistoryCard({
    required this.delivery,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

        return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    delivery.stallName,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    'Completed',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 16,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  '${delivery.items.length} item${delivery.items.length != 1 ? 's' : ''}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    DateFormatter.truncateAddress(delivery.deliveryAddress ?? 'No address'),
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Delivered on ${delivery.createdAtString}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Earned',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      '₱${delivery.deliveryFee.toStringAsFixed(2)}',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onViewDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.visibility, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'View Details',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 