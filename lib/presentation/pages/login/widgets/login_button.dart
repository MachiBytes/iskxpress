import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iskxpress/presentation/pages/user_home/user_home_page.dart';
import 'package:iskxpress/core/constants/image_strings.dart';
import 'package:iskxpress/core/helpers/navigation_helper.dart';
import 'package:iskxpress/core/services/auth_service.dart';

class LoginButton extends StatefulWidget {
  const LoginButton({
    super.key,
    required this.authProvider,
    required this.context,
  });

  final String authProvider;
  final BuildContext context;

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final UserCredential? result = await _authService.signInWithGoogle();
      
      if (result != null && mounted) {
        // Sign in successful, navigate to home
        NavHelper.replacePageTo(context, UserHomePage());
      }
    } catch (e) {
      if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithMicrosoft() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final UserCredential? result = await _authService.signInWithMicrosoft();
      
      if (result != null && mounted) {
        // Sign in successful, navigate to home
        NavHelper.replacePageTo(context, UserHomePage());
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Sign in failed: ${e.toString()}';
        
        // Check if it's a domain restriction error
        if (e.toString().contains('DOMAIN_NOT_ALLOWED')) {
          errorMessage = 'Access Denied: Only @iskolarngbayan.pup.edu.ph and @pup.edu.ph email addresses are allowed to sign in.';
        }
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5), // Longer duration for domain error
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _signIn() {
    if (widget.authProvider == 'Google') {
      _signInWithGoogle();
    } else if (widget.authProvider == 'Microsoft') {
      _signInWithMicrosoft();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    String label = widget.authProvider == 'Google' ? 'For vendors' : 'For users';
    String iconPath = widget.authProvider == 'Google'
        ? TImages.googleIcon
        : TImages.microsoftIcon;

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: textTheme.labelSmall),
          SizedBox(height: 4),
          ElevatedButton(
            onPressed: _isLoading ? null : _signIn,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 15),
                                      child: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        )
                      : Image.asset(iconPath),
                ),
                Text(
                  _isLoading
                      ? 'Signing in...'
                      : 'Sign in with ${widget.authProvider}',
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
