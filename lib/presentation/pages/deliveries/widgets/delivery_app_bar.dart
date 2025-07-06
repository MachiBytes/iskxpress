import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:iskxpress/core/constants/image_strings.dart';
import 'package:iskxpress/presentation/pages/user_cart/user_cart_page.dart';
import 'package:iskxpress/core/services/user_state_service.dart';
import 'package:iskxpress/core/helpers/navigation_helper.dart';

class DeliveryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DeliveryAppBar({super.key, required this.tabController});
  final TabController tabController;

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
            onPressed: () {
              final userId = UserStateService().currentUser?.id;
              if (kDebugMode) {
                debugPrint('DeliveryAppBar: Cart pressed, userId: $userId');
              }
              if (userId != null) {
                NavHelper.pushPageTo(context, UserCartPage(userId: userId));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User not found. Please log in again.')),
                );
              }
            },
            icon: Icon(Icons.shopping_cart, color: colorScheme.onPrimary),
          ),
        ],
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Delivery Requests'),
            Tab(text: 'Your Deliveries'),
          ],
          labelColor: Theme.of(context).colorScheme.onPrimary, // Color of selected tab text
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), // Color of unselected tab text
          indicatorColor: Theme.of(context).colorScheme.onPrimary, // Underline indicator color
          indicatorSize: TabBarIndicatorSize.tab, // Makes indicator span the tab width
        ),
      ),
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + kTextTabBarHeight);
}