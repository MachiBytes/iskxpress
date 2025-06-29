import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import 'base_api_service.dart';

class CategoryApiService {
  // Get all categories
  static Future<List<CategoryModel>> getCategories() async {
    try {
      if (kDebugMode) debugPrint('CATEGORY_API: Getting categories from ${BaseApiService.baseUrl}/api/category');
      
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrl}/api/category'),
        headers: BaseApiService.jsonHeaders,
      );

      if (kDebugMode) {
        debugPrint('CATEGORY_API: Get categories response - Status: ${response.statusCode}');
        debugPrint('CATEGORY_API: Get categories response - Headers: ${response.headers}');
        debugPrint('CATEGORY_API: Get categories response - Body length: ${response.body.length}');
        debugPrint('CATEGORY_API: Get categories response - Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        try {
          if (response.body.trim().isEmpty) {
            if (kDebugMode) debugPrint('CATEGORY_API: Categories response body is empty');
            return [];
          }
          
          final dynamic rawData = json.decode(response.body);
          if (kDebugMode) debugPrint('CATEGORY_API: Parsed JSON type: ${rawData.runtimeType}');
          
          if (rawData is! List) {
            if (kDebugMode) debugPrint('CATEGORY_API: Expected List but got ${rawData.runtimeType}: $rawData');
            return [];
          }
          
          final List<dynamic> responseData = rawData;
          if (kDebugMode) debugPrint('CATEGORY_API: Found ${responseData.length} category items in response');
          
          final categories = <CategoryModel>[];
          for (int i = 0; i < responseData.length; i++) {
            try {
              final categoryJson = responseData[i];
              if (kDebugMode) debugPrint('CATEGORY_API: Processing category $i: $categoryJson');
              
              final category = CategoryModel.fromJson(categoryJson);
              categories.add(category);
              
              if (kDebugMode) debugPrint('CATEGORY_API: Successfully parsed category: ${category.id} - ${category.name}');
            } catch (e) {
              if (kDebugMode) debugPrint('CATEGORY_API: Error parsing category $i: $e');
            }
          }
          
          if (kDebugMode) debugPrint('CATEGORY_API: Successfully parsed ${categories.length} categories total');
          return categories;
        } catch (parseError) {
          if (kDebugMode) debugPrint('CATEGORY_API: Error parsing categories JSON: $parseError');
          if (kDebugMode) debugPrint('CATEGORY_API: Raw response body: ${response.body}');
          return [];
        }
      } else {
        if (kDebugMode) debugPrint('CATEGORY_API: Categories request failed with status ${response.statusCode}');
        if (kDebugMode) debugPrint('CATEGORY_API: Error response body: ${response.body}');
        throw Exception('Failed to get categories: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('CATEGORY_API: Error getting categories: $e');
      return [];
    }
  }
} 