import 'package:flutter/material.dart';

class MyOrders extends StatelessWidget {
  const MyOrders({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Orders', style: textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildClickableColumn(
              context,
              icon: Icons.timer,
              label: 'To Prepare',
              onTap: () => _navigateToOrdersPage(context, 'to_prepare'),
            ),
            _buildClickableColumn(
              context,
              icon: Icons.shopping_bag,
              label: 'To Deliver',
              onTap: () => _navigateToOrdersPage(context, 'to_deliver'),
            ),
            _buildClickableColumn(
              context,
              icon: Icons.delivery_dining,
              label: 'To Receive',
              onTap: () => _navigateToOrdersPage(context, 'to_receive'),
            ),
            _buildClickableColumn(
              context,
              icon: Icons.history,
              label: 'Past Orders',
              onTap: () => _navigateToOrdersPage(context, 'past_orders'),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildClickableColumn(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 36),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToOrdersPage(BuildContext context, String orderType) {
    // TODO: Navigate to specific order pages when implemented
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$orderType orders page coming soon!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}