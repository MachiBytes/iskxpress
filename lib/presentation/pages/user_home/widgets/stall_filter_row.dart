import 'package:flutter/material.dart';
import 'package:iskxpress/core/services/category_api_service.dart';
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
  List<String> _labels = ['All'];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedFilter = 'All';
    _fetchCategories();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onFilterSelected(_selectedFilter!);
    });
  }

  Future<void> _fetchCategories() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final categories = await CategoryApiService.getCategories();
      
      setState(() {
        _labels = ['All', ...categories.map((category) => category.name)];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error - keep default 'All' option
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load categories: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

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