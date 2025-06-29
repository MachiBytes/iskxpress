import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:flutter/foundation.dart';
import '../models/stall_model.dart';
import 'package:path/path.dart' as path;

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

  // Get stalls for a vendor
  static Future<StallModel?> getStallByVendorId(int vendorId) async {
    try {
      if (kDebugMode) debugPrint('API: Getting stall for vendor ID: $vendorId');
      final response = await http.get(
        Uri.parse('$_baseUrl/api/stalls/vendor/$vendorId'),
        headers: _headers,
      );

      if (kDebugMode) debugPrint('API: Get stall by vendor ID response - Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          if (kDebugMode) debugPrint('API: Successfully parsed stall data: $responseData');
          return StallModel.fromJson(responseData);
        } catch (parseError) {
          if (kDebugMode) debugPrint('API: Error parsing stall JSON: $parseError');
          return null;
        }
      } else if (response.statusCode == 404) {
        if (kDebugMode) debugPrint('API: Stall not found for vendor (404)');
        return null;
      } else {
        throw Exception('Failed to get stall: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting stall by vendor ID: $e');
      return null;
    }
  }

  // Update stall information
  static Future<StallModel?> updateStall({
    required int stallId,
    required String name,
    required String shortDescription,
  }) async {
    try {
      final body = json.encode({
        'name': name,
        'shortDescription': shortDescription,
      });

      if (kDebugMode) debugPrint('API: Updating stall $stallId with body: $body');

      final response = await http.put(
        Uri.parse('$_baseUrl/api/stalls/$stallId'),
        headers: _headers,
        body: body,
      );

      if (kDebugMode) debugPrint('API: Update stall response - Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          if (kDebugMode) debugPrint('API: Successfully parsed updated stall data: $responseData');
          return StallModel.fromJson(responseData);
        } catch (parseError) {
          if (kDebugMode) debugPrint('API: Error parsing updated stall JSON: $parseError');
          return null;
        }
      } else {
        throw Exception('Failed to update stall: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error updating stall: $e');
      return null;
    }
  }

  // Upload stall picture
  static Future<bool> uploadStallPicture({
    required int stallId,
    required File imageFile,
  }) async {
    try {
      if (kDebugMode) debugPrint('API: Uploading picture for stall $stallId');
      
      // Check if file exists
      if (!await imageFile.exists()) {
        if (kDebugMode) debugPrint('API: Image file does not exist at path: ${imageFile.path}');
        return false;
      }

      // Get file size for logging
      final fileSize = await imageFile.length();
      if (kDebugMode) debugPrint('API: Image file size: ${fileSize} bytes');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/stalls/$stallId/upload-picture'),
      );

      // Determine the correct MIME type based on file extension
      String? mimeType = _getMimeType(imageFile.path);
      if (kDebugMode) debugPrint('API: Detected MIME type: $mimeType');

      // Add the file to the request with proper MIME type
      final multipartFile = await http.MultipartFile.fromPath(
        'file', // This should match the field name expected by the API
        imageFile.path,
        contentType: mimeType != null ? 
          http_parser.MediaType.parse(mimeType) : null,
      );
      
      request.files.add(multipartFile);

      if (kDebugMode) {
        debugPrint('API: Sending multipart request for stall picture');
        debugPrint('API: File name: ${path.basename(imageFile.path)}');
        debugPrint('API: Content type: ${multipartFile.contentType}');
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) debugPrint('API: Upload stall picture response - Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        if (kDebugMode) debugPrint('API: Upload failed with status ${response.statusCode}');
        return false;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error uploading stall picture: $e');
      return false;
    }
  }

  // Helper method to get MIME type based on file extension
  static String? _getMimeType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.bmp':
        return 'image/bmp';
      case '.webp':
        return 'image/webp';
      case '.heic':
        return 'image/heic';
      case '.heif':
        return 'image/heif';
      case '.tiff':
      case '.tif':
        return 'image/tiff';
      default:
        return 'image/jpeg'; // Default fallback
    }
  }

  // Create new stall
  static Future<StallModel?> createStall({
    required int vendorId,
    required String name,
    required String shortDescription,
  }) async {
    try {
      final body = json.encode({
        'vendorId': vendorId,
        'name': name,
        'shortDescription': shortDescription,
      });

      if (kDebugMode) debugPrint('API: Creating stall with body: $body');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/stalls'),
        headers: _headers,
        body: body,
      );

      if (kDebugMode) debugPrint('API: Create stall response - Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = json.decode(response.body);
          if (kDebugMode) debugPrint('API: Successfully parsed created stall data: $responseData');
          return StallModel.fromJson(responseData);
        } catch (parseError) {
          if (kDebugMode) debugPrint('API: Error parsing created stall JSON: $parseError');
          return null;
        }
      } else {
        throw Exception('Failed to create stall: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error creating stall: $e');
      return null;
    }
  }
} 