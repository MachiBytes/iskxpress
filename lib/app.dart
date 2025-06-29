import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iskxpress/core/styles/app_theme.dart';
import 'package:iskxpress/presentation/pages/login/login_page.dart';
import 'package:iskxpress/presentation/pages/user_home/user_home_page.dart';
import 'package:iskxpress/presentation/pages/vendor_home/vendor_home_page.dart';
import 'package:iskxpress/core/services/user_state_service.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ISK Express',
      theme: kAppTheme,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (kDebugMode) {
            debugPrint('App: Auth state changed - hasData: ${snapshot.hasData}, user: ${snapshot.data?.email}');
          }

          // If no user is authenticated, show login page
          // All navigation after login is handled manually via NavHelper
          if (!snapshot.hasData || snapshot.data == null) {
            if (kDebugMode) debugPrint('App: No authenticated user, showing login page');
            return LoginPage();
          }
          
          // User is authenticated, check their role to determine home page
          return AnimatedBuilder(
            animation: UserStateService(),
            builder: (context, child) {
              final userStateService = UserStateService();
              final currentUser = userStateService.currentUser;
              
              if (currentUser == null) {
                if (kDebugMode) debugPrint('App: User authenticated but no user data yet, showing user home as default');
                // If user data hasn't loaded yet, show user home as default
                // The login process will handle proper navigation once user data loads
                return UserHomePage();
              }
              
              // Route based on user role from API
              if (currentUser.role == 1) {
                if (kDebugMode) debugPrint('App: User role is Vendor, showing VendorHomePage');
                return VendorHomePage();
              } else {
                if (kDebugMode) debugPrint('App: User role is User, showing UserHomePage');
                return UserHomePage();
              }
            },
          );
        },
      ),
    );
  }
}