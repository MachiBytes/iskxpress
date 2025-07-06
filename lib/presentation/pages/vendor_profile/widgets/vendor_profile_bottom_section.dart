import 'package:flutter/material.dart';
import 'package:iskxpress/presentation/pages/user_profile/widgets/app_logo.dart';
import 'package:iskxpress/presentation/pages/user_profile/widgets/logout_button.dart';
import 'package:iskxpress/presentation/pages/vendor_profile/widgets/vendor_general_actions.dart';

class VendorProfileBottomSection extends StatelessWidget {
  const VendorProfileBottomSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VendorGeneralActions(),
                const SizedBox(height: 32),
                LogoutButton(),
                const SizedBox(height: 16),
                Center(child: AppLogo()),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 