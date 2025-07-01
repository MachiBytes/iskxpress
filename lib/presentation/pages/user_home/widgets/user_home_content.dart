import 'package:flutter/material.dart';
import 'package:iskxpress/core/models/stall_model.dart';
import 'package:iskxpress/presentation/pages/user_home/widgets/stall_filter_row.dart';
import 'package:iskxpress/presentation/pages/user_home/widgets/stall_list.dart';

class UserHomePageContent extends StatelessWidget {
  final List<StallModel> stalls;
  final bool isLoading;
  final ValueChanged<String>? onFilterSelected;
  
  const UserHomePageContent({
    super.key, 
    required this.stalls,
    this.isLoading = false,
    this.onFilterSelected,
  });

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
              child: StallFilterRow(onFilterSelected: onFilterSelected ?? (String value) {}),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : stalls.isEmpty
                        ? const Center(
                            child: Text(
                              'No stalls available',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : StallList(stalls: stalls),
              ),
            ),
          ],
        ),
      ),
    );
  }
}