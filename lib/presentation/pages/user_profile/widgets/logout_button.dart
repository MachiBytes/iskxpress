import 'package:flutter/material.dart';
import 'package:iskxpress/core/helpers/navigation_helper.dart';
import 'package:iskxpress/presentation/pages/login/login_page.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  void logOut(BuildContext context) {
    NavHelper.navigateTo(context, const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => logOut(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.error,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text('Log out', style: textTheme.labelLarge?.copyWith(color: colorScheme.onPrimary),),
      ),
    );
  }
}