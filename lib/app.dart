import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iskxpress/core/styles/app_theme.dart';
import 'package:iskxpress/presentation/pages/login/login_page.dart';
import 'package:iskxpress/presentation/pages/user_home/user_home_page.dart';
import 'package:iskxpress/presentation/pages/vendor_home/vendor_home_page.dart';
import 'package:iskxpress/core/services/user_state_service.dart';
import 'package:iskxpress/core/widgets/loading_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final UserStateService _userStateService = UserStateService();
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
    
    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _userStateService.handleAuthStateChange(user);
    });
  }

  Future<void> _initializeUserData() async {
    if (kDebugMode) debugPrint('App: Starting user data initialization...');
    
    // Try to auto-load user data for any authenticated Firebase user
    final success = await _userStateService.autoLoadUserData();
    
    if (!success) {
      if (kDebugMode) debugPrint('App: Failed to auto-load user data, but not clearing user state yet');
      // Don't immediately clear user state - let the login flow handle it
      // This prevents conflicts with the login button's user initialization
    }
    
    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

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

          // If still initializing, show loading screen
          if (_isInitializing) {
            if (kDebugMode) debugPrint('App: Still initializing, showing loading screen');
            return const LoadingScreen();
          }

          // If no user is authenticated, show login page
          if (!snapshot.hasData || snapshot.data == null) {
            if (kDebugMode) debugPrint('App: No authenticated user, showing login page');
            return const LoginPage();
          }
          
          // User is authenticated, check their user data
          return AnimatedBuilder(
            animation: _userStateService,
            builder: (context, child) {
              final currentUser = _userStateService.currentUser;
              final isLoading = _userStateService.isLoading;
              
              // If user data is loading, show loading screen
              if (isLoading) {
                if (kDebugMode) debugPrint('App: User data is loading, showing loading screen');
                return const LoadingScreen();
              }
              
              // If no user data is available, show login page (hard enforcement)
              if (currentUser == null) {
                if (kDebugMode) debugPrint('App: User authenticated but no user data available, showing login page (hard enforcement)');
                // Only clear user state and sign out if we're not in the middle of a login flow
                // This prevents conflicts with the login button's user initialization
                if (!_isInitializing) {
                  _userStateService.clearUser();
                  FirebaseAuth.instance.signOut();
                }
                return const LoginPage();
              }
              
              // Route based on auth provider: Microsoft users always go to UserHomePage, Google users based on role
              if (currentUser.authProvider == 1) {
                // Microsoft users always go to UserHomePage
                if (kDebugMode) debugPrint('App: Microsoft user, showing UserHomePage');
                return UserHomePage();
              } else {
                // Google users route based on their role
                if (currentUser.role == 1) {
                  if (kDebugMode) debugPrint('App: Google user with Vendor role, showing VendorHomePage');
                  return VendorHomePage();
                } else {
                  if (kDebugMode) debugPrint('App: Google user with User role, showing UserHomePage');
                  return UserHomePage();
                }
              }
            },
          );
        },
      ),
    );
  }
}