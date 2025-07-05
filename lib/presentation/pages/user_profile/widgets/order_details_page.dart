import 'package:flutter/material.dart';
import 'package:iskxpress/core/models/order_model.dart';

class OrderDetailsPage extends StatelessWidget {
  final OrderModel order;
  const OrderDetailsPage({super.key, required this.order});

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
      backgroundColor: colorScheme.primary,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(order.stallName, style: textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary)),
            const SizedBox(height: 8),
            Text('Date: ${order.createdAtString}', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary)),
            const SizedBox(height: 8),
            Text('Total: ₱${order.totalPrice.toStringAsFixed(2)}', style: textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary)),
            const SizedBox(height: 16),
            Text('Products', style: textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: order.items.length,
                itemBuilder: (context, idx) {
                  final item = order.items[idx];
                  return Card(
                    child: ListTile(
                      title: Text(item.productName, style: textTheme.titleMedium),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Base Price: ₱${item.basePrice.toStringAsFixed(2)}'),
                          Text('Quantity: ${item.quantity}'),
                        ],
                      ),
                      trailing: Text('₱${item.totalPrice.toStringAsFixed(2)}', style: textTheme.titleMedium),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 