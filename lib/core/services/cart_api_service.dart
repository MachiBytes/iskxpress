import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/user_cart_model.dart';
import 'base_api_service.dart';

class CartApiService {
  static Future<UserCartModel> getUserCart(int userId) async {
    if (kDebugMode) {
      debugPrint('CartApiService: Getting cart for userId: $userId');
      debugPrint('CartApiService: URL: ${BaseApiService.baseUrl}/api/cart/user/$userId');
    }
    
    try {
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrl}/api/cart/user/$userId'),
        headers: BaseApiService.jsonHeaders,
      );
      
      if (kDebugMode) {
        debugPrint('CartApiService: Response status: ${response.statusCode}');
        debugPrint('CartApiService: Response body: ${response.body}');
      }
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (kDebugMode) {
          debugPrint('CartApiService: Parsed data: $data');
        }
        return UserCartModel.fromJson(data);
      } else {
        if (kDebugMode) {
          debugPrint('CartApiService: Error response: ${response.statusCode} - ${response.body}');
        }
        throw Exception('Failed to load user cart: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('CartApiService: Exception: $e');
      }
      rethrow;
    }
  }

  static Future<bool> addToCart({required int userId, required int productId, required int quantity}) async {
    if (kDebugMode) {
      debugPrint('CartApiService: Adding to cart - userId: $userId, productId: $productId, quantity: $quantity');
      debugPrint('CartApiService: URL: ${BaseApiService.baseUrl}/api/cart/user/$userId/add');
    }
    
    try {
      final body = json.encode({'productId': productId, 'quantity': quantity});
      if (kDebugMode) {
        debugPrint('CartApiService: Request body: $body');
      }
      
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrl}/api/cart/user/$userId/add'),
        headers: BaseApiService.jsonHeaders,
        body: body,
      );
      
      if (kDebugMode) {
        debugPrint('CartApiService: Add to cart response status: ${response.statusCode}');
        debugPrint('CartApiService: Add to cart response body: ${response.body}');
      }
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('CartApiService: Add to cart exception: $e');
      }
      rethrow;
    }
  }

  static Future<bool> updateCartItemQuantity({required int userId, required int cartItemId, required int quantity}) async {
    final response = await http.put(
      Uri.parse('${BaseApiService.baseUrl}/api/cart/user/$userId/items/$cartItemId/quantity'),
      headers: BaseApiService.jsonHeaders,
      body: json.encode({'quantity': quantity}),
    );
    return response.statusCode == 200;
  }

  static Future<bool> removeCartItem({required int userId, required int cartItemId}) async {
    final response = await http.delete(
      Uri.parse('${BaseApiService.baseUrl}/api/cart/user/$userId/items/$cartItemId'),
      headers: BaseApiService.jsonHeaders,
    );
    return response.statusCode == 200;
  }
} 