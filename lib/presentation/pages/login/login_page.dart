import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:iskxpress/presentation/pages/login/widgets/login_page_form.dart';
import 'package:iskxpress/presentation/pages/user_home/user_home_page.dart';
import 'package:iskxpress/core/services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const String routeName = 'login_screen';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    // Call sync in the background without blocking the UI
    _syncUsersInBackground();
  }

  Future<void> _syncUsersInBackground() async {
    try {
      if (kDebugMode) debugPrint('LoginPage: Starting background user sync...');
      await ApiService.syncUsers();
      if (kDebugMode) debugPrint('LoginPage: Background user sync completed successfully');
    } catch (e) {
      if (kDebugMode) debugPrint('LoginPage: Background user sync failed: $e');
      // Sync failure is not critical for login flow - users can still authenticate
      // This is likely a server-side configuration issue (missing firebase-key.json)
    }
  }

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