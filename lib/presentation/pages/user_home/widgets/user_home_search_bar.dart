import 'package:flutter/material.dart';

class UserHomeSearchBar extends StatelessWidget {
  const UserHomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: SearchBar(
        leading: Icon(Icons.search, color: colorScheme.primary),
        backgroundColor: WidgetStatePropertyAll(colorScheme.surface),
        hintText: 'Search for a stall or product',
      ),
    );
  }
}