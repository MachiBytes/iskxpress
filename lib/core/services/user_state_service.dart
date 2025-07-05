import 'package:flutter/foundation.dart';
import 'package:iskxpress/core/models/user_model.dart';
import 'package:iskxpress/core/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserStateService extends ChangeNotifier {
  static final UserStateService _instance = UserStateService._internal();
  factory UserStateService() => _instance;
  UserStateService._internal();

  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  void setCurrentUser(UserModel? user) {
    _currentUser = user;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Initialize or create user based on Firebase auth data
  Future<bool> initializeUser({
    required String email,
    required String name,
    required int authProvider, // 0 for Google, 1 for Microsoft
  }) async {
    if (kDebugMode) debugPrint('UserState: Initializing user - Email: $email, Name: $name, AuthProvider: $authProvider');
    
    setLoading(true);
    
    try {
      // Check if user exists
      if (kDebugMode) debugPrint('UserState: Checking if user exists...');
      Map<String, dynamic>? userData = await ApiService.getUserByEmail(email);
      
      if (userData != null) {
        // User exists, load their data
        if (kDebugMode) debugPrint('UserState: User exists, loading data: $userData');
        try {
          _currentUser = UserModel.fromJson(userData);
          if (kDebugMode) debugPrint('UserState: Successfully created UserModel from existing data');
        } catch (parseError) {
          if (kDebugMode) debugPrint('UserState: Error parsing existing user data: $parseError');
          setLoading(false);
          return false;
        }
      } else {
        // User doesn't exist, create new user
        if (kDebugMode) debugPrint('UserState: User does not exist, creating new user...');
        userData = await ApiService.createUser(
          name: name,
          email: email,
          authProvider: authProvider,
        );
        
        if (userData != null) {
          if (kDebugMode) debugPrint('UserState: User created successfully, parsing data: $userData');
          try {
            _currentUser = UserModel.fromJson(userData);
            if (kDebugMode) debugPrint('UserState: Successfully created UserModel from new user data');
          } catch (parseError) {
            if (kDebugMode) debugPrint('UserState: Error parsing new user data: $parseError');
            setLoading(false);
            return false;
          }
        } else {
          if (kDebugMode) debugPrint('UserState: Failed to create user - API returned null');
          setLoading(false);
          return false;
        }
      }
      
      setLoading(false);
      notifyListeners();
      if (kDebugMode) debugPrint('UserState: User initialization completed successfully. User ID: ${_currentUser?.id}');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('UserState: Error initializing user: $e');
      setLoading(false);
      return false;
    }
  }

  // Refresh user data from API
  Future<bool> refreshUserData() async {
    if (_currentUser == null) {
      if (kDebugMode) debugPrint('UserState: Cannot refresh - no current user');
      return false;
    }
    
    if (kDebugMode) debugPrint('UserState: Refreshing user data for ID: ${_currentUser!.id}');
    setLoading(true);
    
    try {
      Map<String, dynamic>? userData = await ApiService.getUserById(_currentUser!.id);
      
      if (userData != null) {
        _currentUser = UserModel.fromJson(userData);
        setLoading(false);
        notifyListeners();
        if (kDebugMode) debugPrint('UserState: User data refreshed successfully');
        return true;
      } else {
        if (kDebugMode) debugPrint('UserState: Failed to refresh user data - API returned null');
        setLoading(false);
        return false;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('UserState: Error refreshing user data: $e');
      setLoading(false);
      return false;
    }
  }

  void clearUser() {
    if (kDebugMode) debugPrint('UserState: Clearing user data');
    _currentUser = null;
    notifyListeners();
  }

  // Handle authentication state changes
  void handleAuthStateChange(User? user) {
    if (user == null) {
      // User signed out, clear user data
      if (kDebugMode) debugPrint('UserState: User signed out, clearing user data');
      clearUser();
    } else {
      // User signed in, but we don't automatically load data here
      // The app.dart will handle loading user data for authenticated users
      if (kDebugMode) debugPrint('UserState: User signed in: ${user.email}');
    }
  }

  // Auto-load user data for authenticated Firebase user
  Future<bool> autoLoadUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser == null || currentUser.email == null) {
      if (kDebugMode) debugPrint('UserState: No authenticated Firebase user for auto-load');
      return false;
    }

    if (_currentUser != null) {
      if (kDebugMode) debugPrint('UserState: User data already loaded, skipping auto-load');
      return true;
    }

    if (kDebugMode) debugPrint('UserState: Auto-loading user data for: ${currentUser.email}');
    return await loadUserDataForAuthenticatedUser(currentUser.email!);
  }

  // Load user data for an authenticated Firebase user
  Future<bool> loadUserDataForAuthenticatedUser(String email) async {
    if (kDebugMode) debugPrint('UserState: Loading user data for authenticated user: $email');
    
    setLoading(true);
    
    try {
      // Check if user exists in our system
      Map<String, dynamic>? userData = await ApiService.getUserByEmail(email);
      
      if (userData != null) {
        // User exists, load their data
        if (kDebugMode) debugPrint('UserState: User exists, loading data: $userData');
        try {
          _currentUser = UserModel.fromJson(userData);
          setLoading(false);
          notifyListeners();
          if (kDebugMode) debugPrint('UserState: Successfully loaded user data for authenticated user');
          return true;
        } catch (parseError) {
          if (kDebugMode) debugPrint('UserState: Error parsing user data: $parseError');
          setLoading(false);
          return false;
        }
      } else {
        // User doesn't exist in our system - this should not happen for authenticated users
        if (kDebugMode) debugPrint('UserState: Authenticated user not found in our system - this should not happen');
        setLoading(false);
        return false;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('UserState: Error loading user data for authenticated user: $e');
      setLoading(false);
      return false;
    }
  }
} 