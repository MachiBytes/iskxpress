import 'package:flutter/material.dart';

/// A card widget to display an assigned delivery with fixed action buttons.
class YourDeliveryCard extends StatelessWidget {
  const YourDeliveryCard({
    super.key,
    required this.stallName,
    required this.itemCount,
    required this.address,
    required this.orderedAt,
    required this.orderId,
    required this.totalFee,
    required this.deliveryFee,
    this.statusText, // Keeping statusText as optional, as it provides useful info
    this.onManageDelivery, // New callback for "Manage Delivery"
    this.onCancelDelivery, // New callback for "Cancel Delivery"
  });

  final String stallName;
  final int itemCount;
  final String address;
  final String orderedAt;
  final String orderId;
  final double totalFee;
  final double deliveryFee;
  final String? statusText; // e.g., 'Preparing', 'Items Delivered'
  final VoidCallback? onManageDelivery; // Action for managing the delivery (e.g., view details)
  final VoidCallback? onCancelDelivery; // Action for canceling the delivery

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      color: colorScheme.surface,

      // The entire card is no longer wrapped in InkWell, making only buttons clickable.
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Stall/Order Info & Timestamp/ID & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stallName,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$itemCount items',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        address,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Ordered At $orderedAt',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      'Order Id: $orderId',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4), // Added space before fees for consistency
                    Text(
                      'Total: P ${totalFee.toStringAsFixed(2)}',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Fee: P ${deliveryFee.toStringAsFixed(2)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8), // Space before the button row

            // Bottom Row: Status and Action Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (statusText != null)
                  Text(
                    statusText!,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary, // Highlight status
                    ),
                  )
                else
                  const SizedBox.shrink(),
                ElevatedButton(
                  onPressed: onManageDelivery,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary, // Primary action color
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: textTheme.labelSmall,
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Manage Delivery'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}