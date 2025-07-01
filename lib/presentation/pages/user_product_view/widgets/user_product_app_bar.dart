import 'package:flutter/material.dart';

class UserProductAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String stallName;
  
  const UserProductAppBar({
    super.key,
    required this.stallName,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      backgroundColor: colorScheme.primary,
      toolbarHeight: kToolbarHeight,
      iconTheme: IconThemeData(color: colorScheme.onPrimary),
      title: Text(
        stallName,
        style: textTheme.titleLarge?.copyWith(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      centerTitle: true,
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}