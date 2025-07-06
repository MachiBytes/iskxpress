import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:iskxpress/core/widgets/custom_app_bar.dart';
import 'package:iskxpress/core/widgets/custom_bottom_nav_bar.dart';
import 'package:iskxpress/presentation/pages/user_profile/widgets/user_profile_bottom_section.dart';
import 'package:iskxpress/presentation/pages/user_profile/widgets/user_profile_top_section.dart';
import 'package:iskxpress/presentation/pages/user_cart/user_cart_page.dart';
import 'package:iskxpress/core/services/user_state_service.dart';
import 'package:iskxpress/core/helpers/navigation_helper.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  static const String routeName = 'user_profile_page';

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: CustomAppBar(
        onCartPressed: () {
          final userId = UserStateService().currentUser?.id;
          if (kDebugMode) {
            debugPrint('UserProfilePage: Cart pressed, userId: $userId');
          }
          if (userId != null) {
            NavHelper.pushPageTo(context, UserCartPage(userId: userId));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User not found. Please log in again.')),
            );
          }
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      body: SafeArea(
        child: Column(
          children: [
            UserProfileTopSection(),
            UserProfileBottomSection(),
          ],
        ),
      ),
    );
  }
}