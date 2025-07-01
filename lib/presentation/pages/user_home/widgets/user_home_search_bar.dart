import 'package:flutter/material.dart';

class UserHomeSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  const UserHomeSearchBar({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SearchBar(
        leading: Icon(Icons.search, color: colorScheme.primary),
        hintText: 'Search for stalls...',
        elevation: WidgetStateProperty.all(0),
        backgroundColor: WidgetStatePropertyAll(colorScheme.surface),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        ),
        hintStyle: WidgetStatePropertyAll(textTheme.bodySmall),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 16),
        ),
        textStyle: WidgetStatePropertyAll(textTheme.bodySmall),
        onChanged: onChanged,
      ),
    );
  }
}