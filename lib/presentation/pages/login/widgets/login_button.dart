import 'package:flutter/material.dart';
import 'package:iskxpress/presentation/pages/user_home/user_home_page.dart';
import 'package:iskxpress/core/constants/image_strings.dart';
import 'package:iskxpress/core/helpers/navigation_helper.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({
    super.key,
    required this.authProvider,
    required this.context,
  });

  final String authProvider;
  final BuildContext context;

  void signIn() {
    print(authProvider);
    NavHelper.navigateTo(context, UserHomePage());
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    String label = authProvider == 'Google' ? 'For vendors' : 'For users';
    String iconPath =
        authProvider == 'Google'
            ? TImages.googleIcon
            : TImages.microsoftIcon;

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: textTheme.labelSmall),
          SizedBox(height: 4,),
          ElevatedButton(
            onPressed: () => signIn(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 15),
                    child: Image.asset(iconPath),
                  ),
                  Text(
                    'Sign in with $authProvider',
                    style: textTheme.labelLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
