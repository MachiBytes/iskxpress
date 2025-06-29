import 'package:flutter/material.dart';
import 'package:iskxpress/core/widgets/custom_app_bar.dart';
import 'package:iskxpress/core/widgets/vendor_bottom_nav_bar.dart';
import 'package:iskxpress/presentation/pages/vendor_profile/widgets/vendor_profile_bottom_section.dart';
import 'package:iskxpress/presentation/pages/vendor_profile/widgets/vendor_profile_top_section.dart';

class VendorProfilePage extends StatefulWidget {
  const VendorProfilePage({super.key});

  static const String routeName = 'vendor_profile_page';

  @override
  State<VendorProfilePage> createState() => _VendorProfilePageState();
}

class _VendorProfilePageState extends State<VendorProfilePage> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: const CustomAppBar(),
      bottomNavigationBar: const VendorBottomNavBar(currentIndex: 2),
      body: SafeArea(
        child: Column(
          children: [
            VendorProfileTopSection(),
            VendorProfileBottomSection(),
          ],
        ),
      ),
    );
  }
} 