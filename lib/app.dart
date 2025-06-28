import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iskxpress/core/styles/app_theme.dart';
import 'package:iskxpress/presentation/pages/login/login_page.dart';
import 'package:iskxpress/presentation/pages/user_home/user_home_page.dart';
import 'package:iskxpress/presentation/pages/vendor_home/vendor_home_page.dart';
import 'package:iskxpress/presentation/pages/deliveries/deliveries_page.dart';
import 'package:iskxpress/presentation/pages/user_product_view/user_product_page.dart';
import 'package:iskxpress/presentation/pages/user_profile/user_profile_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Show loading while checking auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // If user is signed in, route based on provider
          if (snapshot.hasData) {
            final user = snapshot.data!;
            // Check if user signed in with Google (vendor) or Microsoft (user)
            final providerData = user.providerData;
            
            // Debug: Print provider information
            print('User email: ${user.email}');
            print('Provider data count: ${providerData.length}');
            for (var provider in providerData) {
              print('Provider ID: ${provider.providerId}');
              print('Provider UID: ${provider.uid}');
            }
            
            // Check if user signed in with Google
            bool isGoogleUser = providerData.any((provider) => 
              provider.providerId == 'google.com');
            
            print('Is Google user: $isGoogleUser');
            
            // Route to appropriate homepage
            if (isGoogleUser) {
              print('Routing to VendorHomePage');
              return VendorHomePage(); // Google users are vendors
            } else {
              print('Routing to UserHomePage');
              return UserHomePage(); // Microsoft users are regular users
            }
          }

          // If user is not signed in, show login page
          return LoginPage();
        },
      ),
      routes: {
        LoginPage.routeName: (context) => LoginPage(),
        UserHomePage.routeName: (context) => UserHomePage(),
        VendorHomePage.routeName: (context) => VendorHomePage(),
        DeliveriesPage.routeName: (context) => DeliveriesPage(),
        UserProfilePage.routeName: (context) => UserProfilePage(),
        UserProductPage.routeName: (context) => UserProductPage(),
      },
      theme: kAppTheme,
    );
  }
}