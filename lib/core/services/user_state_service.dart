import 'package:flutter/foundation.dart';
import 'package:iskxpress/core/models/user_model.dart';
import 'package:iskxpress/core/services/api_service.dart';

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
} 