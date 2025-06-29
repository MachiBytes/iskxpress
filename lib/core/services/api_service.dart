import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static const String _baseUrl = 'http://54.255.209.101:5000';
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  // Sync users endpoint
  static Future<bool> syncUsers() async {
    try {
      if (kDebugMode) debugPrint('API: Calling sync users endpoint');
      final response = await http.get(
        Uri.parse('$_baseUrl/api/users/sync'),
        headers: _headers,
      );
      if (kDebugMode) debugPrint('API: Sync users response - Status: ${response.statusCode}, Body: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) debugPrint('Error syncing users: $e');
      return false;
    }
  }

  // Check if user exists by email
  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      if (kDebugMode) debugPrint('API: Getting user by email: $email');
      final response = await http.get(
        Uri.parse('$_baseUrl/api/users/email/$email'),
        headers: _headers,
      );
      
      if (kDebugMode) debugPrint('API: Get user by email response - Status: ${response.statusCode}, Body: ${response.body}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        if (kDebugMode) debugPrint('API: User not found (404)');
        return null; // User not found
      } else {
        throw Exception('Failed to get user: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting user by email: $e');
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

      if (kDebugMode) debugPrint('API: Creating user with body: $body');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/users'),
        headers: _headers,
        body: body,
      );

      if (kDebugMode) debugPrint('API: Create user response - Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = json.decode(response.body);
          if (kDebugMode) debugPrint('API: Successfully parsed user data: $responseData');
          return responseData;
        } catch (parseError) {
          if (kDebugMode) debugPrint('API: Error parsing response JSON: $parseError');
          return null;
        }
      } else {
        if (kDebugMode) debugPrint('API: Create user failed with status ${response.statusCode}: ${response.body}');
        throw Exception('Failed to create user: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error creating user: $e');
      return null;
    }
  }

  // Get user by ID
  static Future<Map<String, dynamic>?> getUserById(int userId) async {
    try {
      if (kDebugMode) debugPrint('API: Getting user by ID: $userId');
      final response = await http.get(
        Uri.parse('$_baseUrl/api/users/$userId'),
        headers: _headers,
      );

      if (kDebugMode) debugPrint('API: Get user by ID response - Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          if (kDebugMode) debugPrint('API: Successfully parsed user data: $responseData');
          return responseData;
        } catch (parseError) {
          if (kDebugMode) debugPrint('API: Error parsing response JSON: $parseError');
          return null;
        }
      } else {
        throw Exception('Failed to get user: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting user by ID: $e');
      return null;
    }
  }
} 