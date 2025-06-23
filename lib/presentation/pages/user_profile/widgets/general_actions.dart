import 'package:flutter/material.dart';

class GeneralActions extends StatelessWidget {
  const GeneralActions({super.key});

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
              Row(
                children: [
                  Icon(Icons.question_mark_rounded),
                  const SizedBox(width: 8),
                  Text('Help'),
                ],
              ),
              Row(children: [
                Icon(Icons.lock),
                const SizedBox(width: 8),
                Text('Security')
              ]),
            ],
          ),
        ),
      ],
    );
  }
}