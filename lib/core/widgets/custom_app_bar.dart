import 'package:flutter/material.dart';
import 'package:iskxpress/core/constants/image_strings.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme  = Theme.of(context).colorScheme;

    return Material(
      elevation: 4, // Adjust for stronger/weaker shadow
      shadowColor: Theme.of(context).shadowColor,
      child: AppBar(
        actionsPadding: const EdgeInsets.only(right: 8),
        backgroundColor: colorScheme.primary,
        elevation: 0, // Prevents double shadow
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(
            top: 8.0,
            bottom: 8,
            left: 16,
            right: 8,
          ),
          child: Image.asset(TImages.appIcon, height: 38, width: 38),
        ),
        title: Text(
          'Welcome back, Iskx!',
          style: textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary, fontSize: 16),
        ),
        actions: [
          IconButton(
            onPressed: null,
            icon: Icon(Icons.favorite, color: colorScheme.onPrimary),
          ),
          IconButton(
            onPressed: null,
            icon: Icon(Icons.shopping_cart, color: colorScheme.onPrimary),
          ),
        ],
      ),
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}