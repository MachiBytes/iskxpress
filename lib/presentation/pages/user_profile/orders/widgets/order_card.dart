import 'package:flutter/material.dart';
import 'package:iskxpress/core/models/order_model.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onViewDetails;
  final String statusText;
  final Color statusColor;
  final String? additionalInfo;

  const OrderCard({
    super.key,
    required this.order,
    required this.onViewDetails,
    required this.statusText,
    required this.statusColor,
    this.additionalInfo,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id}',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.stallName,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      if (additionalInfo != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          additionalInfo!,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    statusText,
                    style: textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total: ₱${order.totalPrice.ceil()}',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      '${order.items.length} items',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: onViewDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('View Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 