import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import '../models/stall_model.dart';
import 'base_api_service.dart';

class StallApiService {
  // Get all stalls
  static Future<List<StallModel>> getStalls() async {
    try {
      if (kDebugMode) debugPrint('STALL_API: Getting all stalls from ${BaseApiService.baseUrl}/api/stalls');
      
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrl}/api/stalls'),
        headers: BaseApiService.jsonHeaders,
      );

      if (kDebugMode) {
        debugPrint('STALL_API: Get stalls response - Status: ${response.statusCode}');
        debugPrint('STALL_API: Get stalls response - Headers: ${response.headers}');
        debugPrint('STALL_API: Get stalls response - Body length: ${response.body.length}');
        debugPrint('STALL_API: Get stalls response - Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        try {
          if (response.body.trim().isEmpty) {
            if (kDebugMode) debugPrint('STALL_API: Stalls response body is empty');
            return [];
          }
          
          final dynamic rawData = json.decode(response.body);
          if (kDebugMode) debugPrint('STALL_API: Parsed JSON type: ${rawData.runtimeType}');
          
          if (rawData is! List) {
            if (kDebugMode) debugPrint('STALL_API: Expected List but got ${rawData.runtimeType}: $rawData');
            return [];
          }
          
          final List<dynamic> responseData = rawData;
          if (kDebugMode) debugPrint('STALL_API: Found ${responseData.length} stall items in response');
          
          final stalls = <StallModel>[];
          for (int i = 0; i < responseData.length; i++) {
            try {
              final stallJson = responseData[i];
              if (kDebugMode) debugPrint('STALL_API: Processing stall $i: $stallJson');
              
              final stall = StallModel.fromJson(stallJson);
              stalls.add(stall);
              
              if (kDebugMode) debugPrint('STALL_API: Successfully parsed stall: ${stall.id} - ${stall.name}');
            } catch (e) {
              if (kDebugMode) debugPrint('STALL_API: Error parsing stall $i: $e');
            }
          }
          
          if (kDebugMode) debugPrint('STALL_API: Successfully parsed ${stalls.length} stalls total');
          return stalls;
        } catch (parseError) {
          if (kDebugMode) debugPrint('STALL_API: Error parsing stalls JSON: $parseError');
          if (kDebugMode) debugPrint('STALL_API: Raw response body: ${response.body}');
          return [];
        }
      } else {
        if (kDebugMode) debugPrint('STALL_API: Stalls request failed with status ${response.statusCode}');
        if (kDebugMode) debugPrint('STALL_API: Error response body: ${response.body}');
        throw Exception('Failed to get stalls: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('STALL_API: Error getting stalls: $e');
      return [];
    }
  }

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
    bool hasDelivery = false,
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

  // Update stall delivery availability
  static Future<StallModel?> updateStallDeliveryAvailability({
    required int stallId,
    required bool hasDelivery,
  }) async {
    try {
      if (kDebugMode) debugPrint('STALL_API: Updating delivery availability for stall $stallId to $hasDelivery');

      final response = await http.put(
        Uri.parse('${BaseApiService.baseUrl}/api/stalls/$stallId/delivery-availability?deliveryAvailable=$hasDelivery'),
        headers: BaseApiService.jsonHeaders,
      );

      if (kDebugMode) debugPrint('STALL_API: Update delivery availability response - Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          if (kDebugMode) debugPrint('STALL_API: Successfully parsed updated delivery availability data: $responseData');
          return StallModel.fromJson(responseData);
        } catch (parseError) {
          if (kDebugMode) debugPrint('STALL_API: Error parsing updated delivery availability JSON: $parseError');
          return null;
        }
      } else {
        throw Exception('Failed to update delivery availability: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('STALL_API: Error updating delivery availability: $e');
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

  // Search stalls by query
  static Future<List<StallModel>> searchStalls(String query) async {
    try {
      if (kDebugMode) debugPrint('STALL_API: Searching stalls with query: $query');
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrl}/api/stalls/search?query=$query'),
        headers: BaseApiService.jsonHeaders,
      );
      if (kDebugMode) debugPrint('STALL_API: Search stalls response - Status: ${response.statusCode}, Body: ${response.body}');
      if (response.statusCode == 200) {
        try {
          final List<dynamic> responseData = json.decode(response.body);
          final stalls = responseData.map((json) => StallModel.fromJson(json)).toList();
          if (kDebugMode) debugPrint('STALL_API: Successfully parsed ${stalls.length} search results');
          return stalls;
        } catch (parseError) {
          if (kDebugMode) debugPrint('STALL_API: Error parsing search results JSON: $parseError');
          return [];
        }
      } else {
        throw Exception('Failed to search stalls: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('STALL_API: Error searching stalls: $e');
      return [];
    }
  }

  static Future<double> getPendingFees(int stallId) async {
    String url = '${BaseApiService.baseUrl}/api/stalls/$stallId/pending-fees';
    if (kDebugMode) debugPrint('StallApiService: GET $url');
    
    final response = await http.get(
      Uri.parse(url),
      headers: BaseApiService.jsonHeaders,
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final pendingFees = (data['pendingFees'] ?? 0.0).toDouble();
      if (kDebugMode) debugPrint('StallApiService: Pending fees: $pendingFees');
      return pendingFees;
    } else {
      if (kDebugMode) debugPrint('StallApiService: Failed to get pending fees: ${response.statusCode}');
      throw Exception('Failed to get pending fees: ${response.statusCode}');
    }
  }

  static Future<bool> subtractPendingFees(int stallId, double amount) async {
    String url = '${BaseApiService.baseUrl}/api/stalls/$stallId/pending-fees/subtract';
    if (kDebugMode) debugPrint('StallApiService: PUT $url with amount: $amount');
    
    final response = await http.put(
      Uri.parse(url),
      headers: BaseApiService.jsonHeaders,
      body: json.encode({
        'amount': amount,
      }),
    );
    
    if (response.statusCode == 200) {
      if (kDebugMode) debugPrint('StallApiService: Successfully subtracted pending fees');
      return true;
    } else {
      if (kDebugMode) debugPrint('StallApiService: Failed to subtract pending fees: ${response.statusCode}');
      throw Exception('Failed to subtract pending fees: ${response.statusCode}');
    }
  }
} 