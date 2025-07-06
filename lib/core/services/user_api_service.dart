import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'base_api_service.dart';

class UserApiService {
  // Sync users endpoint
  static Future<bool> syncUsers() async {
    try {
      if (kDebugMode) debugPrint('USER_API: Calling sync users endpoint');
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrl}/api/users/sync'),
        headers: BaseApiService.jsonHeaders,
      );
      if (kDebugMode) debugPrint('USER_API: Sync users response - Status: ${response.statusCode}, Body: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) debugPrint('USER_API: Error syncing users: $e');
      return false;
    }
  }

  // Check if user exists by email
  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      if (kDebugMode) debugPrint('USER_API: Getting user by email: $email');
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrl}/api/users/email/$email'),
        headers: BaseApiService.jsonHeaders,
      );
      
      if (kDebugMode) debugPrint('USER_API: Get user by email response - Status: ${response.statusCode}, Body: ${response.body}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        if (kDebugMode) debugPrint('USER_API: User not found (404)');
        return null; // User not found
      } else {
        throw Exception('Failed to get user: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('USER_API: Error getting user by email: $e');
      return null;
    }
  }

  // Create new user
  static Future<Map<String, dynamic>?> createUser({
    required String name,
    required String email,
    required int authProvider,
  }) async {
    try {
      final body = json.encode({
        'name': name,
        'email': email,
        'authProvider': authProvider,
      });

      if (kDebugMode) debugPrint('USER_API: Creating user with body: $body');

      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrl}/api/users'),
        headers: BaseApiService.jsonHeaders,
        body: body,
      );

      if (kDebugMode) debugPrint('USER_API: Create user response - Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = json.decode(response.body);
          if (kDebugMode) debugPrint('USER_API: Successfully parsed user data: $responseData');
          return responseData;
        } catch (parseError) {
          if (kDebugMode) debugPrint('USER_API: Error parsing response JSON: $parseError');
          return null;
        }
      } else {
        if (kDebugMode) debugPrint('USER_API: Create user failed with status ${response.statusCode}: ${response.body}');
        throw Exception('Failed to create user: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('USER_API: Error creating user: $e');
      return null;
    }
  }

  // Get user by ID
  static Future<Map<String, dynamic>?> getUserById(int userId) async {
    try {
      if (kDebugMode) debugPrint('USER_API: Getting user by ID: $userId');
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrl}/api/users/$userId'),
        headers: BaseApiService.jsonHeaders,
      );

      if (kDebugMode) debugPrint('USER_API: Get user by ID response - Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          if (kDebugMode) debugPrint('USER_API: Successfully parsed user data: $responseData');
          return responseData;
        } catch (parseError) {
          if (kDebugMode) debugPrint('USER_API: Error parsing response JSON: $parseError');
          return null;
        }
      } else {
        throw Exception('Failed to get user: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('USER_API: Error getting user by ID: $e');
      return null;
    }
  }

  // Get Google users (list of emails)
  static Future<List<String>> getGoogleUsers() async {
    try {
      if (kDebugMode) debugPrint('USER_API: Getting Google users');
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrl}/api/users/google'),
        headers: BaseApiService.jsonHeaders,
      );

      if (kDebugMode) debugPrint('USER_API: Get Google users response - Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final List<dynamic> responseData = json.decode(response.body);
          // Extract email addresses from the user objects
          final List<String> googleEmails = responseData
              .map((user) => user['email'] as String)
              .where((email) => email.isNotEmpty)
              .toList();
          
          if (kDebugMode) debugPrint('USER_API: Successfully extracted ${googleEmails.length} Google emails from ${responseData.length} users');
          return googleEmails;
        } catch (parseError) {
          if (kDebugMode) debugPrint('USER_API: Error parsing Google users response JSON: $parseError');
          return [];
        }
      } else {
        if (kDebugMode) debugPrint('USER_API: Get Google users failed with status ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      if (kDebugMode) debugPrint('USER_API: Error getting Google users: $e');
      return [];
    }
  }

  // Toggle premium status for user
  static Future<bool> togglePremium(int userId) async {
    try {
      if (kDebugMode) debugPrint('USER_API: Toggling premium for user: $userId');
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrl}/api/users/$userId/toggle-premium'),
        headers: BaseApiService.jsonHeaders,
      );

      if (kDebugMode) debugPrint('USER_API: Toggle premium response - Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        if (kDebugMode) debugPrint('USER_API: Successfully toggled premium status');
        return true;
      } else {
        if (kDebugMode) debugPrint('USER_API: Toggle premium failed with status ${response.statusCode}: ${response.body}');
        throw Exception('Failed to toggle premium: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('USER_API: Error toggling premium: $e');
      return false;
    }
  }
} 