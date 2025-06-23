import 'package:flutter/material.dart';
import 'package:iskxpress/presentation/pages/user_home/widgets/stall_filter_row.dart';
import 'package:iskxpress/presentation/pages/user_home/widgets/stall_list.dart';

class UserHomePageContent extends StatelessWidget {
  final List<Map<String, dynamic>> stalls;
  const UserHomePageContent({super.key, required this.stalls});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: StallFilterRow(onFilterSelected: (String value) {  },),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: stalls.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : StallList(stalls: stalls),
              ),
            ),
          ],
        ),
      ),
    );
  }
}