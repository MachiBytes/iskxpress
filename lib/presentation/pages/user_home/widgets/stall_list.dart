import 'package:flutter/material.dart';
import 'package:iskxpress/core/helpers/navigation_helper.dart';
import 'package:iskxpress/core/models/stall_model.dart';
import 'package:iskxpress/presentation/pages/user_home/widgets/stall_card.dart';
import 'package:iskxpress/presentation/pages/user_product_view/user_product_page.dart';

class StallList extends StatelessWidget {
  final List<StallModel> stalls;

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
              imagePath: stall.pictureUrl,
              stallName: stall.name,
              stallNumber: 'Stall ${stall.id}',
              stallDescription: stall.shortDescription,
              onPressed: () => NavHelper.pushPageTo(
                context, 
                UserProductPage(stall: stall),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
