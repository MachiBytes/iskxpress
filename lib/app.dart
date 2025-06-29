import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iskxpress/core/styles/app_theme.dart';
import 'package:iskxpress/presentation/pages/login/login_page.dart';
import 'package:iskxpress/presentation/pages/user_home/user_home_page.dart';
import 'package:iskxpress/presentation/pages/vendor_home/vendor_home_page.dart';

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
          
          if (kDebugMode) debugPrint('App: User authenticated, showing default home page (manual navigation will handle routing)');
          // User is authenticated, but we let manual navigation handle the specific routing
          // Show a default page while manual navigation takes over
          return UserHomePage(); // This will be overridden by manual navigation
        },
      ),
    );
  }
}