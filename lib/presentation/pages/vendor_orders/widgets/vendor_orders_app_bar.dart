import 'package:flutter/material.dart';
import 'package:iskxpress/core/constants/image_strings.dart';

class VendorOrdersAppBar extends StatelessWidget implements PreferredSizeWidget {
  const VendorOrdersAppBar({super.key, required this.tabController});
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 4,
      shadowColor: Theme.of(context).shadowColor,
      child: AppBar(
        actionsPadding: const EdgeInsets.only(right: 8),
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
          'Orders',
          style: textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary, fontSize: 16),
        ),
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Pending Orders'),
            Tab(text: 'Accomplished Orders'),
          ],
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          indicatorColor: Theme.of(context).colorScheme.onPrimary,
          indicatorSize: TabBarIndicatorSize.tab,
        ),
      ),
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + kTextTabBarHeight);
} 