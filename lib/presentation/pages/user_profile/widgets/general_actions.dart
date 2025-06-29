import 'package:flutter/material.dart';
import 'package:iskxpress/presentation/pages/feedback/feedback_page.dart';

class GeneralActions extends StatelessWidget {
  const GeneralActions({super.key});

  void _navigateToFeedback(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FeedbackPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('General', style: textTheme.titleMedium),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Column(
            spacing: 8,
            children: [
              Row(
                children: [
                  Icon(Icons.shopping_cart),
                  const SizedBox(width: 8),
                  Text('Cart'),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.history),
                  const SizedBox(width: 8),
                  Text('Delivery History'),
                ],
              ),
              GestureDetector(
                onTap: () => _navigateToFeedback(context),
                child: Row(
                  children: [
                    Icon(Icons.feedback_rounded),
                    const SizedBox(width: 8),
                    Text('Send your feedback'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}