import 'package:flutter/material.dart';
// import 'package:gap/gap.dart'; // Optional: for cleaner spacing in the Row

class StallFilterRow extends StatefulWidget {
  const StallFilterRow({
    super.key,
    required this.onFilterSelected,
  });

  final ValueChanged<String> onFilterSelected;

  @override
  State<StallFilterRow> createState() => _StallFilterRowState();
}

class _StallFilterRowState extends State<StallFilterRow> {
  String? _selectedFilter;

  final List<String> _labels = [
    'All', 'Food', 'Drinks', 'Snacks', 'Desserts', 'Meals', 'Vegan', 'Rice Meals'
  ];

  @override
  void initState() {
    super.initState();
    _selectedFilter = _labels.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onFilterSelected(_selectedFilter!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: _labels.map((label) {
          final isSelected = _selectedFilter == label;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                label,
                style: textTheme.labelMedium?.copyWith(
                  color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = label;
                  });
                  widget.onFilterSelected(label);
                }
              },
              selectedColor: colorScheme.primary,
              backgroundColor: colorScheme.surface,
              labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50), // Adjust this value for desired roundness
                side: BorderSide( // Move the BorderSide here
                  color: isSelected ? Colors.transparent : colorScheme.outline,
                  width: .5,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}