import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import '../models/product_model.dart';
import 'base_api_service.dart';

class ProductApiService {
  // Get products for a stall
  static Future<List<ProductModel>> getStallProducts(int stallId) async {
    try {
      if (kDebugMode) debugPrint('PRODUCT_API: Getting products for stall ID: $stallId');
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrl}/api/stalls/$stallId/products'),
        headers: BaseApiService.jsonHeaders,
      );

      if (kDebugMode) debugPrint('PRODUCT_API: Get stall products response - Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final List<dynamic> responseData = json.decode(response.body);
          final products = responseData.map((json) => ProductModel.fromJson(json)).toList();
          if (kDebugMode) debugPrint('PRODUCT_API: Successfully parsed ${products.length} products');
          return products;
        } catch (parseError) {
          if (kDebugMode) debugPrint('PRODUCT_API: Error parsing products JSON: $parseError');
          return [];
        }
      } else {
        throw Exception('Failed to get products: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('PRODUCT_API: Error getting stall products: $e');
      return [];
    }
  }

  // Create new product (correct request body format)
  static Future<ProductModel?> createProduct({
    required int stallId,
    required String name,
    required double basePrice,
    required int sectionId,
    int? categoryId,
  }) async {
    try {
      final requestData = <String, dynamic>{
        'name': name,
        'basePrice': basePrice,
        'sectionId': sectionId,
      };
      
      // Only include categoryId if it's not null
      if (categoryId != null) {
        requestData['categoryId'] = categoryId;
      }
      
      final body = json.encode(requestData);

      if (kDebugMode) {
        debugPrint('PRODUCT_API: Creating product for stall $stallId');
        debugPrint('PRODUCT_API: Request data: $requestData');
        debugPrint('PRODUCT_API: Request body: $body');
        debugPrint('PRODUCT_API: Content-Type: ${BaseApiService.jsonHeaders['Content-Type']}');
        debugPrint('PRODUCT_API: URL: ${BaseApiService.baseUrl}/api/stalls/$stallId/products');
      }

      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrl}/api/stalls/$stallId/products'),
        headers: BaseApiService.jsonHeaders,
        body: body,
      );

      if (kDebugMode) {
        debugPrint('PRODUCT_API: Create product response - Status: ${response.statusCode}');
        debugPrint('PRODUCT_API: Create product response - Headers: ${response.headers}');
        debugPrint('PRODUCT_API: Create product response - Body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = json.decode(response.body);
          if (kDebugMode) debugPrint('PRODUCT_API: Successfully parsed created product data: $responseData');
          return ProductModel.fromJson(responseData);
        } catch (parseError) {
          if (kDebugMode) debugPrint('PRODUCT_API: Error parsing created product JSON: $parseError');
          return null;
        }
      } else {
        // Try to parse error response
        String errorMessage = 'Failed to create product: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          if (kDebugMode) debugPrint('PRODUCT_API: Error response data: $errorData');
          errorMessage += ' - ${response.body}';
        } catch (e) {
          errorMessage += ' - ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('PRODUCT_API: Error creating product: $e');
      return null;
    }
  }

  // Update product (correct request body format)
  static Future<ProductModel?> updateProduct({
    required int productId,
    required String name,
    required double basePrice,
    required int sectionId,
    int? categoryId,
  }) async {
    try {
      final requestData = <String, dynamic>{
        'name': name,
        'basePrice': basePrice,
        'sectionId': sectionId,
      };
      
      // Only include categoryId if it's not null
      if (categoryId != null) {
        requestData['categoryId'] = categoryId;
      }
      
      final body = json.encode(requestData);

      if (kDebugMode) {
        debugPrint('PRODUCT_API: Updating product $productId');
        debugPrint('PRODUCT_API: Request data: $requestData');
        debugPrint('PRODUCT_API: Request body: $body');
      }

      final response = await http.put(
        Uri.parse('${BaseApiService.baseUrl}/api/products/$productId'),
        headers: BaseApiService.jsonHeaders,
        body: body,
      );

      if (kDebugMode) {
        debugPrint('PRODUCT_API: Update product response - Status: ${response.statusCode}');
        debugPrint('PRODUCT_API: Update product response - Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          if (kDebugMode) debugPrint('PRODUCT_API: Successfully parsed updated product data: $responseData');
          return ProductModel.fromJson(responseData);
        } catch (parseError) {
          if (kDebugMode) debugPrint('PRODUCT_API: Error parsing updated product JSON: $parseError');
          return null;
        }
      } else {
        // Try to parse error response
        String errorMessage = 'Failed to update product: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          if (kDebugMode) debugPrint('PRODUCT_API: Error response data: $errorData');
          errorMessage += ' - ${response.body}';
        } catch (e) {
          errorMessage += ' - ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('PRODUCT_API: Error updating product: $e');
      return null;
    }
  }

  // Delete product
  static Future<bool> deleteProduct(int productId) async {
    try {
      if (kDebugMode) debugPrint('PRODUCT_API: Deleting product ID: $productId');
      final response = await http.delete(
        Uri.parse('${BaseApiService.baseUrl}/api/products/$productId'),
        headers: BaseApiService.jsonHeaders,
      );

      if (kDebugMode) debugPrint('PRODUCT_API: Delete product response - Status: ${response.statusCode}, Body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      if (kDebugMode) debugPrint('PRODUCT_API: Error deleting product: $e');
      return false;
    }
  }

  // Upload product picture
  static Future<bool> uploadProductPicture({
    required int productId,
    required File imageFile,
  }) async {
    try {
      if (kDebugMode) debugPrint('PRODUCT_API: Uploading picture for product $productId');
      
      // Check if file exists
      if (!await BaseApiService.fileExists(imageFile)) {
        if (kDebugMode) debugPrint('PRODUCT_API: Image file does not exist at path: ${imageFile.path}');
        return false;
      }

      // Get file size for logging
      final fileSize = await BaseApiService.getFileSize(imageFile);
      if (kDebugMode) debugPrint('PRODUCT_API: Image file size: $fileSize bytes');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${BaseApiService.baseUrl}/api/products/$productId/upload-picture'),
      );

      // Determine the correct MIME type based on file extension
      String? mimeType = BaseApiService.getMimeType(imageFile.path);
      if (kDebugMode) debugPrint('PRODUCT_API: Detected MIME type: $mimeType');

      // Add the file to the request with proper MIME type
      final multipartFile = await http.MultipartFile.fromPath(
        'file', // This should match the field name expected by the API
        imageFile.path,
        contentType: mimeType != null ? 
          http_parser.MediaType.parse(mimeType) : null,
      );
      
      request.files.add(multipartFile);

      if (kDebugMode) {
        debugPrint('PRODUCT_API: Sending multipart request for product picture');
        debugPrint('PRODUCT_API: File name: ${path.basename(imageFile.path)}');
        debugPrint('PRODUCT_API: Content type: ${multipartFile.contentType}');
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) debugPrint('PRODUCT_API: Upload product picture response - Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        if (kDebugMode) debugPrint('PRODUCT_API: Upload failed with status ${response.statusCode}');
        return false;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('PRODUCT_API: Error uploading product picture: $e');
      return false;
    }
  }
} 