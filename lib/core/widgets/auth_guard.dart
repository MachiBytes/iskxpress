import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iskxpress/core/services/user_state_service.dart';
import 'package:iskxpress/presentation/pages/login/login_page.dart';
import 'package:iskxpress/core/widgets/loading_screen.dart';

class AuthGuard extends StatefulWidget {
  final Widget child;
  final bool requireVendorRole;

  const AuthGuard({
    super.key,
    required this.child,
    this.requireVendorRole = false,
  });

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  final UserStateService _userStateService = UserStateService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // Check Firebase authentication
        if (!authSnapshot.hasData || authSnapshot.data == null) {
          if (kDebugMode) debugPrint('AuthGuard: No Firebase user, redirecting to login');
          return const LoginPage();
        }

        // Check user data from our system
        return AnimatedBuilder(
          animation: _userStateService,
          builder: (context, child) {
            final currentUser = _userStateService.currentUser;
            final isLoading = _userStateService.isLoading;

            // Show loading while user data is being fetched
            if (isLoading) {
              if (kDebugMode) debugPrint('AuthGuard: User data loading, showing loading screen');
              return const LoadingScreen();
            }

            // If no user data available, redirect to login
            if (currentUser == null) {
              if (kDebugMode) debugPrint('AuthGuard: No user data available, redirecting to login');
              // Clear user state and sign out to force re-authentication
              _userStateService.clearUser();
              FirebaseAuth.instance.signOut();
              return const LoginPage();
            }

            // Check role requirement if specified
            if (widget.requireVendorRole && currentUser.role != 1) {
              if (kDebugMode) debugPrint('AuthGuard: User is not a vendor, redirecting to login');
              // Clear user state and sign out for unauthorized access
              _userStateService.clearUser();
              FirebaseAuth.instance.signOut();
              return const LoginPage();
            }

            // User is authenticated and authorized, show the protected content
            if (kDebugMode) debugPrint('AuthGuard: User authenticated and authorized, showing protected content');
            return widget.child;
          },
        );
      },
    );
  }
} 