import 'package:flutter/material.dart';
import 'package:iskxpress/presentation/pages/vendor_home/vendor_home_page.dart';
import 'package:iskxpress/presentation/pages/vendor_orders/vendor_orders_page.dart';
import 'package:iskxpress/presentation/pages/vendor_profile/vendor_profile_page.dart';
import 'package:iskxpress/core/helpers/navigation_helper.dart';

class VendorBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const VendorBottomNavBar({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        NavHelper.replacePageTo(context, const VendorHomePage());
        break;
      case 1:
        NavHelper.replacePageTo(context, const VendorOrdersPage());
        break;
      case 2:
        NavHelper.replacePageTo(context, const VendorProfilePage());
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
            blurRadius: 10,
            offset: const Offset(0, -1)
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Orders'),
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