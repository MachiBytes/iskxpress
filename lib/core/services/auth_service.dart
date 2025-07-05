import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:iskxpress/core/services/user_state_service.dart';
import 'package:iskxpress/core/services/stall_state_service.dart';
import 'package:iskxpress/core/services/api_service.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserStateService _userStateService = UserStateService();
  final StallStateService _stallStateService = StallStateService();

  // Allowed email domains for Microsoft Sign-In
  static const List<String> _allowedDomains = [
    'iskolarngbayan.pup.edu.ph',
    'pup.edu.ph',
  ];

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();



  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kDebugMode) debugPrint('AuthService: Starting Google sign-in process...');
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        if (kDebugMode) debugPrint('AuthService: Google sign-in was cancelled by user');
        return null;
      }

      if (kDebugMode) debugPrint('AuthService: Google user obtained: ${googleUser.email}');

      // Validate Google email against allowed list from API
      if (kDebugMode) debugPrint('AuthService: Validating Google email against allowed list...');
      final List<String> allowedGoogleEmails = await ApiService.getGoogleUsers();
      
      if (kDebugMode) debugPrint('AuthService: Allowed Google emails: ${allowedGoogleEmails.join(", ")}');
      
      if (!allowedGoogleEmails.contains(googleUser.email)) {
        if (kDebugMode) debugPrint('AuthService: Google email not in allowed list, denying login');
        await _googleSignIn.signOut();
        throw Exception('GOOGLE_EMAIL_NOT_AUTHORIZED: This Google account is not authorized to sign in.');
      }

      if (kDebugMode) debugPrint('AuthService: Google email validation passed');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      if (kDebugMode) debugPrint('AuthService: Signing in to Firebase with Google credentials...');

      // Once signed in, return the UserCredential
      final UserCredential result = await _auth.signInWithCredential(credential);
      
      if (kDebugMode) debugPrint('AuthService: Google sign-in completed successfully. User: ${result.user?.email}');
      
      return result;
    } catch (e) {
      if (kDebugMode) debugPrint('AuthService: Google sign-in error: $e');
      rethrow;
    }
  }

  // Microsoft Sign In with domain restriction - optimized to prevent app redirects
  Future<UserCredential?> signInWithMicrosoft() async {
    try {
      if (kDebugMode) debugPrint('AuthService: Starting Microsoft sign-in process...');
      
      // Create Microsoft provider
      final microsoftProvider = MicrosoftAuthProvider();
      
      // Set custom parameters for domain restriction
      microsoftProvider.setCustomParameters({
        'prompt': 'select_account',
        'tenant': 'common', // You might want to use a specific tenant ID
      });

      if (kDebugMode) debugPrint('AuthService: Triggering Microsoft sign-in...');

      // Sign in with provider (works on mobile)
      final UserCredential result = await _auth.signInWithProvider(microsoftProvider);
      
      if (result.user == null) {
        if (kDebugMode) debugPrint('AuthService: Microsoft sign-in returned null user');
        return null;
      }

      final user = result.user!;
      if (kDebugMode) debugPrint('AuthService: Microsoft sign-in completed successfully. User: ${user.email}');

      // Check domain restriction
      if (user.email != null && !_isAllowedDomain(user.email!)) {
        if (kDebugMode) debugPrint('AuthService: Domain not allowed: ${user.email}');
        await signOut(); // Sign out immediately
        throw Exception('DOMAIN_NOT_ALLOWED: Only @iskolarngbayan.pup.edu.ph and @pup.edu.ph email addresses are allowed.');
      }
      
      if (kDebugMode) debugPrint('AuthService: Domain check passed for: ${user.email}');
      
      return result;
    } catch (e) {
      if (kDebugMode) debugPrint('AuthService: Microsoft sign-in error: $e');
      // If it's a domain restriction error, rethrow it
      if (e.toString().contains('DOMAIN_NOT_ALLOWED')) {
        rethrow;
      }
      // For other errors, provide a more user-friendly message
      throw Exception('Microsoft sign-in failed. Please try again or contact support if the problem persists.');
    }
  }

  bool _isAllowedDomain(String email) {
    return _allowedDomains.any((domain) => email.toLowerCase().endsWith('@$domain'));
  }

  // Sign out
  Future<void> signOut() async {
    try {
      if (kDebugMode) debugPrint('AuthService: Starting sign out process...');
      
      // Clear user and stall state first
      _userStateService.clearUser();
      _stallStateService.clearStall();
      if (kDebugMode) debugPrint('AuthService: User and stall state cleared');
      
      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        if (kDebugMode) debugPrint('AuthService: Signing out from Google...');
        await _googleSignIn.signOut();
      }
      
      // Sign out from Firebase
      if (kDebugMode) debugPrint('AuthService: Signing out from Firebase...');
      await _auth.signOut();
      
      if (kDebugMode) debugPrint('AuthService: Sign out completed successfully');
    } catch (e) {
      if (kDebugMode) debugPrint('AuthService: Sign out error: $e');
      rethrow;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final User? user = currentUser;
      if (user != null) {
        // Clear user and stall state first
        _userStateService.clearUser();
        _stallStateService.clearStall();
        
        await _googleSignIn.disconnect();
        await user.delete();
      }
    } catch (e) {
      throw Exception('Account deletion failed: $e');
    }
  }
} 