import 'package:flutter/material.dart';
import 'package:iskxpress/core/helpers/navigation_helper.dart';
import 'package:iskxpress/presentation/pages/user_home/widgets/stall_card.dart';
import 'package:iskxpress/presentation/pages/user_product_view/user_product_page.dart';

class StallList extends StatelessWidget {
  final List<Map<String, dynamic>> stalls;

  const StallList({super.key, required this.stalls});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Wrap(
          runSpacing: 8,
          children: stalls.map((stall) {
            return StallCard(
              imagePath: stall['imagePath'],
              stallName: stall['name'],
              stallNumber: stall['number'],
              stallDescription: stall['description'],
              onPressed: () => NavHelper.pushPageTo(context, const UserProductPage()),
            );
          }).toList(),
        ),
      ),
    );
  }
}
