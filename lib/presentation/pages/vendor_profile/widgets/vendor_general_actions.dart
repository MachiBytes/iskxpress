import 'package:flutter/material.dart';
import 'package:iskxpress/presentation/pages/feedback/feedback_page.dart';

class VendorGeneralActions extends StatelessWidget {
  const VendorGeneralActions({super.key});

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
            spacing: 12,
            children: [
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
              Row(
                children: [
                  Icon(Icons.help_outline),
                  const SizedBox(width: 8),
                  Text('Help & Support'),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.info_outline),
                  const SizedBox(width: 8),
                  Text('About'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
} 