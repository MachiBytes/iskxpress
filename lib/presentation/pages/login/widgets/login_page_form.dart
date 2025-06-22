import 'package:flutter/material.dart';
import 'package:iskxpress/core/constants/image_strings.dart';
import 'package:iskxpress/presentation/pages/login/widgets/login_button.dart';

class LoginPageForm extends StatelessWidget {
  const LoginPageForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(TImages.appLogo),
            SizedBox(height: 100),
            LoginButton(authProvider: 'Microsoft', context: context,),
            SizedBox(height: 16,),
            LoginButton(authProvider: 'Google', context: context,),
          ],
        ),
      ),
    );
  }
}