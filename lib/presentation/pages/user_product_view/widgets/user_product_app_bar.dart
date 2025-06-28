import 'package:flutter/material.dart';

class UserProductAppBar extends StatelessWidget implements PreferredSizeWidget {
  const UserProductAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      backgroundColor: colorScheme.primary,
      toolbarHeight: kToolbarHeight,
      iconTheme: IconThemeData(color: colorScheme.onPrimary),
      title: SizedBox(
        height: 40, // keeps the search bar neat inside the AppBar
        child: SearchBar(
          leading: Icon(Icons.search, color: colorScheme.primary),
          hintText: 'Search in Bento Express',
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
          onChanged: (value) {},
        ),
      ),
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}