import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Allowed email domains for Microsoft Sign-In
  static const List<String> _allowedDomains = [
    'iskolarngbayan.pup.edu.ph',
    'pup.edu.ph',
  ];

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if email domain is allowed
  bool _isEmailDomainAllowed(String email) {
    return _allowedDomains.any((domain) => email.toLowerCase().endsWith('@$domain'));
  }

  // Generate a cryptographically secure random string for PKCE
  String _generateRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();
    return String.fromCharCodes(Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      return userCredential;
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }

  // Microsoft Sign In with domain restriction - optimized to prevent app redirects
  Future<UserCredential?> signInWithMicrosoft() async {
    try {
      final microsoftProvider = MicrosoftAuthProvider();
      
      // Configure scopes
      microsoftProvider.addScope('email');
      microsoftProvider.addScope('profile');
      
      // Use parameters that prevent app redirects on mobile
      microsoftProvider.setCustomParameters({
        'prompt': 'select_account',
        'login_hint': 'pup.edu.ph',
        'display': 'page', // Use page display to prevent popup/app redirects
        'response_mode': 'query', // Use query mode instead of fragment to prevent issues
        'max_age': '0', // Force fresh authentication
      });

      // Use signInWithProvider which works better on mobile than popup/redirect
      final UserCredential userCredential = await _auth.signInWithProvider(microsoftProvider);
      
      // Validate domain
      final userEmail = userCredential.user?.email;
      if (userEmail == null || !_isEmailDomainAllowed(userEmail)) {
        await _auth.signOut();
        throw Exception('DOMAIN_NOT_ALLOWED: Only @iskolarngbayan.pup.edu.ph and @pup.edu.ph emails are allowed.');
      }
      
      return userCredential;
    } catch (e) {
      if (e.toString().contains('DOMAIN_NOT_ALLOWED')) {
        rethrow; // Re-throw domain error as is
      }
      throw Exception('Microsoft Sign-In failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Sign out from Firebase (this handles Microsoft sign-out as well)
      await _auth.signOut();
      
      // Also sign out from Google if user was signed in with Google
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        // Ignore Google sign-out errors if user wasn't signed in with Google
        print('Google sign-out error (can be ignored): $e');
      }
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final User? user = currentUser;
      if (user != null) {
        await _googleSignIn.disconnect();
        await user.delete();
      }
    } catch (e) {
      throw Exception('Account deletion failed: $e');
    }
  }
} 