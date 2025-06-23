import 'package:flutter/material.dart';
import 'package:iskxpress/core/widgets/custom_app_bar.dart';
import 'package:iskxpress/core/widgets/custom_bottom_nav_bar.dart';
import 'package:iskxpress/presentation/pages/user_profile/widgets/user_profile_bottom_section.dart';
import 'package:iskxpress/presentation/pages/user_profile/widgets/user_profile_top_section.dart';

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
      appBar: const CustomAppBar(),
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