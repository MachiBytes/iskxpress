import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/section_model.dart';
import 'base_api_service.dart';

class SectionApiService {
  // Get sections for a stall
  static Future<List<SectionModel>> getStallSections(int stallId) async {
    try {
      if (kDebugMode) debugPrint('SECTION_API: Getting sections for stall ID: $stallId');
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrl}/api/stalls/$stallId/sections'),
        headers: BaseApiService.jsonHeaders,
      );

      if (kDebugMode) debugPrint('SECTION_API: Get stall sections response - Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final List<dynamic> responseData = json.decode(response.body);
          final sections = responseData.map((json) => SectionModel.fromJson(json)).toList();
          if (kDebugMode) debugPrint('SECTION_API: Successfully parsed ${sections.length} sections');
          return sections;
        } catch (parseError) {
          if (kDebugMode) debugPrint('SECTION_API: Error parsing sections JSON: $parseError');
          return [];
        }
      } else {
        throw Exception('Failed to get sections: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('SECTION_API: Error getting stall sections: $e');
      return [];
    }
  }

  // Create new section
  static Future<SectionModel?> createSection({
    required int stallId,
    required String name,
  }) async {
    try {
      final body = json.encode({
        'name': name,
      });

      if (kDebugMode) debugPrint('SECTION_API: Creating section for stall $stallId with body: $body');

      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrl}/api/stalls/$stallId/sections'),
        headers: BaseApiService.jsonHeaders,
        body: body,
      );

      if (kDebugMode) debugPrint('SECTION_API: Create section response - Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = json.decode(response.body);
          if (kDebugMode) debugPrint('SECTION_API: Successfully parsed created section data: $responseData');
          return SectionModel.fromJson(responseData);
        } catch (parseError) {
          if (kDebugMode) debugPrint('SECTION_API: Error parsing created section JSON: $parseError');
          return null;
        }
      } else {
        throw Exception('Failed to create section: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('SECTION_API: Error creating section: $e');
      return null;
    }
  }

  // Update section
  static Future<SectionModel?> updateSection({
    required int sectionId,
    required String name,
  }) async {
    try {
      final body = json.encode({
        'name': name,
      });

      if (kDebugMode) debugPrint('SECTION_API: Updating section $sectionId with body: $body');

      final response = await http.put(
        Uri.parse('${BaseApiService.baseUrl}/api/sections/$sectionId'),
        headers: BaseApiService.jsonHeaders,
        body: body,
      );

      if (kDebugMode) debugPrint('SECTION_API: Update section response - Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          if (kDebugMode) debugPrint('SECTION_API: Successfully parsed updated section data: $responseData');
          return SectionModel.fromJson(responseData);
        } catch (parseError) {
          if (kDebugMode) debugPrint('SECTION_API: Error parsing updated section JSON: $parseError');
          return null;
        }
      } else {
        throw Exception('Failed to update section: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('SECTION_API: Error updating section: $e');
      return null;
    }
  }

  // Delete section
  static Future<bool> deleteSection(int sectionId) async {
    try {
      if (kDebugMode) debugPrint('SECTION_API: Deleting section ID: $sectionId');
      final response = await http.delete(
        Uri.parse('${BaseApiService.baseUrl}/api/sections/$sectionId'),
        headers: BaseApiService.jsonHeaders,
      );

      if (kDebugMode) debugPrint('SECTION_API: Delete section response - Status: ${response.statusCode}, Body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      if (kDebugMode) debugPrint('SECTION_API: Error deleting section: $e');
      return false;
    }
  }
} 