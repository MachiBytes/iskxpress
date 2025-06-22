import 'package:flutter/material.dart';
import 'package:iskxpress/presentation/pages/login/widgets/login_page_form.dart';
import 'package:iskxpress/presentation/pages/user_home/user_home_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const String routeName = 'login_screen';

  void googleSignin(BuildContext context) {
    Navigator.pushNamed(context, UserHomePage.routeName);
  }

  void microsoftSignin(BuildContext context) {
    Navigator.pushNamed(context, UserHomePage.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: Center(
        child: LoginPageForm(),
      ),
    );
  }
}