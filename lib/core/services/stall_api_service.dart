import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import '../models/stall_model.dart';
import 'base_api_service.dart';

class StallApiService {
  // Get stalls for a vendor
  static Future<StallModel?> getStallByVendorId(int vendorId) async {
    try {
      if (kDebugMode) debugPrint('STALL_API: Getting stall for vendor ID: $vendorId');
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrl}/api/stalls/vendor/$vendorId'),
        headers: BaseApiService.jsonHeaders,
      );

      if (kDebugMode) debugPrint('STALL_API: Get stall by vendor ID response - Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          if (kDebugMode) debugPrint('STALL_API: Successfully parsed stall data: $responseData');
          return StallModel.fromJson(responseData);
        } catch (parseError) {
          if (kDebugMode) debugPrint('STALL_API: Error parsing stall JSON: $parseError');
          return null;
        }
      } else if (response.statusCode == 404) {
        if (kDebugMode) debugPrint('STALL_API: Stall not found for vendor (404)');
        return null;
      } else {
        throw Exception('Failed to get stall: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('STALL_API: Error getting stall by vendor ID: $e');
      return null;
    }
  }

  // Create new stall (correct request body format)
  static Future<StallModel?> createStall({
    required int vendorId,
    required String name,
    required String shortDescription,
  }) async {
    try {
      final body = json.encode({
        'name': name,
        'shortDescription': shortDescription,
      });

      if (kDebugMode) debugPrint('STALL_API: Creating stall for vendor $vendorId with body: $body');

      // Vendor ID is passed in the URL path instead of body
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrl}/api/stalls/vendor/$vendorId'),
        headers: BaseApiService.jsonHeaders,
        body: body,
      );

      if (kDebugMode) debugPrint('STALL_API: Create stall response - Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = json.decode(response.body);
          if (kDebugMode) debugPrint('STALL_API: Successfully parsed created stall data: $responseData');
          return StallModel.fromJson(responseData);
        } catch (parseError) {
          if (kDebugMode) debugPrint('STALL_API: Error parsing created stall JSON: $parseError');
          return null;
        }
      } else {
        throw Exception('Failed to create stall: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('STALL_API: Error creating stall: $e');
      return null;
    }
  }

  // Update stall information (correct request body format)
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

      if (kDebugMode) debugPrint('STALL_API: Updating stall $stallId with body: $body');

      final response = await http.put(
        Uri.parse('${BaseApiService.baseUrl}/api/stalls/$stallId'),
        headers: BaseApiService.jsonHeaders,
        body: body,
      );

      if (kDebugMode) debugPrint('STALL_API: Update stall response - Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          if (kDebugMode) debugPrint('STALL_API: Successfully parsed updated stall data: $responseData');
          return StallModel.fromJson(responseData);
        } catch (parseError) {
          if (kDebugMode) debugPrint('STALL_API: Error parsing updated stall JSON: $parseError');
          return null;
        }
      } else {
        throw Exception('Failed to update stall: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('STALL_API: Error updating stall: $e');
      return null;
    }
  }

  // Upload stall picture
  static Future<bool> uploadStallPicture({
    required int stallId,
    required File imageFile,
  }) async {
    try {
      if (kDebugMode) debugPrint('STALL_API: Uploading picture for stall $stallId');
      
      // Check if file exists
      if (!await BaseApiService.fileExists(imageFile)) {
        if (kDebugMode) debugPrint('STALL_API: Image file does not exist at path: ${imageFile.path}');
        return false;
      }

      // Get file size for logging
      final fileSize = await BaseApiService.getFileSize(imageFile);
      if (kDebugMode) debugPrint('STALL_API: Image file size: $fileSize bytes');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${BaseApiService.baseUrl}/api/stalls/$stallId/upload-picture'),
      );

      // Determine the correct MIME type based on file extension
      String? mimeType = BaseApiService.getMimeType(imageFile.path);
      if (kDebugMode) debugPrint('STALL_API: Detected MIME type: $mimeType');

      // Add the file to the request with proper MIME type
      final multipartFile = await http.MultipartFile.fromPath(
        'file', // This should match the field name expected by the API
        imageFile.path,
        contentType: mimeType != null ? 
          http_parser.MediaType.parse(mimeType) : null,
      );
      
      request.files.add(multipartFile);

      if (kDebugMode) {
        debugPrint('STALL_API: Sending multipart request for stall picture');
        debugPrint('STALL_API: File name: ${path.basename(imageFile.path)}');
        debugPrint('STALL_API: Content type: ${multipartFile.contentType}');
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) debugPrint('STALL_API: Upload stall picture response - Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        if (kDebugMode) debugPrint('STALL_API: Upload failed with status ${response.statusCode}');
        return false;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('STALL_API: Error uploading stall picture: $e');
      return false;
    }
  }
} 