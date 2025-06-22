import 'package:flutter/material.dart';
import 'package:iskxpress/core/widgets/custom_app_bar.dart';
import 'package:iskxpress/core/widgets/custom_bottom_nav_bar.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  static const String routeName = 'user_profile_page';

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 2),
    );
  }
} 