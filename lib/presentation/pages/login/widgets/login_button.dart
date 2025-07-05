import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iskxpress/core/constants/image_strings.dart';
import 'package:iskxpress/core/services/auth_service.dart';
import 'package:iskxpress/core/services/user_state_service.dart';
import 'package:iskxpress/presentation/pages/user_home/user_home_page.dart';
import 'package:iskxpress/presentation/pages/vendor_home/vendor_home_page.dart';

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
  final UserStateService _userStateService = UserStateService();

  Future<void> _handleUserInitialization(User user, int authProvider) async {
    final email = user.email;
    final name = user.displayName;

    if (kDebugMode) debugPrint('LoginButton: Starting user initialization for ${widget.authProvider}');
    if (kDebugMode) debugPrint('LoginButton: User email: $email, name: $name, authProvider: $authProvider');

    if (email == null || name == null) {
      if (kDebugMode) debugPrint('LoginButton: User email or name not available - Email: $email, Name: $name');
      throw Exception('User email or name not available from ${widget.authProvider} authentication');
    }

    if (kDebugMode) debugPrint('LoginButton: Calling initializeUser...');
    try {
      // Initialize user in the API
      final success = await _userStateService.initializeUser(
        email: email,
        name: name,
        authProvider: authProvider,
      );

      if (kDebugMode) debugPrint('LoginButton: initializeUser returned: $success');

      if (!success) {
        if (kDebugMode) debugPrint('LoginButton: User initialization failed');
        throw Exception('Failed to initialize user in the system. Please check your internet connection and try again.');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('LoginButton: User initialization error: $e');
      if (mounted) {
        String errorMessage = 'Could not connect to the server. Please check your internet connection or try again later.';
        if (e.toString().contains('SocketException') || e.toString().contains('ClientException') || e.toString().contains('Connection refused')) {
          errorMessage = 'Cannot connect to the server. Please check your internet connection or try again later.';
        } else {
          errorMessage = 'Login failed: ${e.toString()}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 8),
          ),
        );
      }
      rethrow;
    }

    if (kDebugMode) debugPrint('LoginButton: User initialization completed successfully');
    
    // Get the current user data to determine routing
    final currentUser = _userStateService.currentUser;
    if (currentUser == null) {
      if (kDebugMode) debugPrint('LoginButton: User data not available after initialization');
      throw Exception('User data not available after initialization');
    }

    if (kDebugMode) debugPrint('LoginButton: User role: ${currentUser.role} (${currentUser.roleString})');
    
    // Manual navigation after user initialization
    if (mounted) {
      if (authProvider == 1) {
        // Microsoft: always go to UserHomePage
        if (kDebugMode) debugPrint('LoginButton: Microsoft user, navigating to UserHomePage');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => UserHomePage()),
          (route) => false,
        );
      } else {
        // Google: Vendor role goes to VendorHomePage, else UserHomePage
        if (currentUser.role == 1) {
          if (kDebugMode) debugPrint('LoginButton: Google user with Vendor role, navigating to VendorHomePage');
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => VendorHomePage()),
            (route) => false,
          );
        } else {
          if (kDebugMode) debugPrint('LoginButton: Google user with User role, navigating to UserHomePage');
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => UserHomePage()),
            (route) => false,
          );
        }
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (kDebugMode) debugPrint('LoginButton: Starting Google sign-in');
      final UserCredential? result = await _authService.signInWithGoogle();
      
      if (result != null && result.user != null && mounted) {
        if (kDebugMode) debugPrint('LoginButton: Google sign-in successful, initializing user...');
        // Initialize user in the API (0 = Google) and navigate manually
        await _handleUserInitialization(result.user!, 0);
      } else {
        if (kDebugMode) debugPrint('LoginButton: Google sign-in result was null or user was null');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Google sign-in was cancelled or failed. Please try again.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('LoginButton: Google sign-in error: $e');
      if (mounted) {
        String errorMessage = 'Google sign-in failed. Please try again.';
        
        // Provide more specific error messages based on the error type
        if (e.toString().contains('network')) {
          errorMessage = 'Network error. Please check your internet connection and try again.';
        } else if (e.toString().contains('cancelled')) {
          errorMessage = 'Sign-in was cancelled. Please try again.';
        } else if (e.toString().contains('popup')) {
          errorMessage = 'Sign-in popup was blocked. Please allow popups and try again.';
        } else if (e.toString().contains('GOOGLE_EMAIL_NOT_AUTHORIZED')) {
          errorMessage = 'Access Denied: This Google account is not authorized to sign in.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 6),
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
      if (kDebugMode) debugPrint('LoginButton: Starting Microsoft sign-in');
      final UserCredential? result = await _authService.signInWithMicrosoft();
      
      if (result != null && result.user != null && mounted) {
        if (kDebugMode) debugPrint('LoginButton: Microsoft sign-in successful, initializing user...');
        // Initialize user in the API (1 = Microsoft) and navigate manually
        await _handleUserInitialization(result.user!, 1);
      } else {
        if (kDebugMode) debugPrint('LoginButton: Microsoft sign-in result was null or user was null');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Microsoft sign-in was cancelled or failed. Please try again.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('LoginButton: Microsoft sign-in error: $e');
      if (mounted) {
        String errorMessage = 'Microsoft sign-in failed. Please try again.';
        
        // Check if it's a domain restriction error
        if (e.toString().contains('DOMAIN_NOT_ALLOWED')) {
          errorMessage = 'Access Denied: Only @iskolarngbayan.pup.edu.ph and @pup.edu.ph email addresses are allowed to sign in.';
        } else if (e.toString().contains('network')) {
          errorMessage = 'Network error. Please check your internet connection and try again.';
        } else if (e.toString().contains('cancelled')) {
          errorMessage = 'Sign-in was cancelled. Please try again.';
        } else if (e.toString().contains('popup')) {
          errorMessage = 'Sign-in popup was blocked. Please allow popups and try again.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 8), // Longer duration for domain error
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
