import 'package:flutter/material.dart';
import 'package:iskxpress/core/constants/image_strings.dart';

class VendorAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  const VendorAppBar({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme  = Theme.of(context).colorScheme;

    return Material(
      elevation: 4,
      shadowColor: Theme.of(context).shadowColor,
      child: AppBar(
        actions: [],
        backgroundColor: colorScheme.primary,
        elevation: 0,
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
          title ?? 'Vendor',
          style: textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary, fontSize: 16),
        ),
      ),
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 