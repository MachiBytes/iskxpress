import 'package:flutter/material.dart';
import 'package:iskxpress/presentation/pages/user_home/user_home_page.dart';
import 'package:iskxpress/presentation/pages/deliveries/deliveries_page.dart';
import 'package:iskxpress/presentation/pages/user_profile/user_profile_page.dart';
import 'package:iskxpress/core/helpers/navigation_helper.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        NavHelper.navigateTo(context, const UserHomePage());
        break;
      case 1:
        NavHelper.navigateTo(context, const DeliveriesPage());
        break;
      case 2:
        NavHelper.navigateTo(context, const UserProfilePage());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 10, // Adjust blur for desired softness
            offset: const Offset(0, -1)
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.trolley), label: 'Deliveries'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.secondary,
      ),
    );
  }
}
