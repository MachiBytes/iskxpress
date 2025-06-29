import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iskxpress/core/services/auth_service.dart';
import 'package:iskxpress/core/helpers/navigation_helper.dart';
import 'package:iskxpress/presentation/pages/login/login_page.dart';

class LogoutButton extends StatefulWidget {
  const LogoutButton({super.key});

  @override
  State<LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<LogoutButton> {
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _signOut() async {
    if (_isLoading) {
      if (kDebugMode) debugPrint('LogoutButton: Sign out already in progress');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (kDebugMode) debugPrint('LogoutButton: Starting manual logout process');
      
      // Step 1: Sign out from Firebase and clear user state
      await _authService.signOut();
      if (kDebugMode) debugPrint('LogoutButton: Auth service signOut completed');
      
      // Step 2: Wait a moment for Firebase to process the sign out
      await Future.delayed(Duration(milliseconds: 300));
      
      // Step 3: Verify we're actually signed out
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        if (kDebugMode) debugPrint('LogoutButton: Warning - User still appears to be signed in: ${currentUser.email}');
        throw Exception('Logout may not have completed properly');
      }
      
      if (kDebugMode) debugPrint('LogoutButton: Logout verification passed - user is signed out');
      
      // Step 4: Navigate manually using NavHelper
      if (mounted) {
        if (kDebugMode) debugPrint('LogoutButton: Navigating to login page using NavHelper');
        NavHelper.replacePageTo(context, LoginPage());
      }
      
    } catch (e) {
      if (kDebugMode) debugPrint('LogoutButton: Sign out error: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign out failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signOut,
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
        child: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                ),
              )
            : Text(
                'Log out', 
                style: textTheme.labelLarge?.copyWith(color: colorScheme.onPrimary)
              ),
      ),
    );
  }
}