import 'package:flutter/material.dart';
import 'package:iskxpress/core/styles/app_theme.dart';
import 'package:iskxpress/presentation/pages/login/login_page.dart';
import 'package:iskxpress/presentation/pages/user_home/user_home_page.dart';
import 'package:iskxpress/presentation/pages/deliveries/deliveries_page.dart';
import 'package:iskxpress/presentation/pages/user_profile/user_profile_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: LoginPage.routeName,
      routes: {
        LoginPage.routeName: (context) => LoginPage(),
        UserHomePage.routeName: (context) => UserHomePage(),
        DeliveriesPage.routeName: (context) => DeliveriesPage(),
        UserProfilePage.routeName: (context) => UserProfilePage(),
      },
      theme: kAppTheme
    );
  }
}