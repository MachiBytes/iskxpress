import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import 'base_api_service.dart';

class OrderApiService {
  static Future<List<OrderModel>> getUserOrders(int userId, {int? status}) async {
    String url = '${BaseApiService.baseUrl}/api/Order/user/$userId';
    if (status != null) {
      url += '?status=$status';
    }
    if (kDebugMode) debugPrint('OrderApiService: GET $url');
    final response = await http.get(
      Uri.parse(url),
      headers: BaseApiService.jsonHeaders,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => OrderModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load orders: ${response.statusCode}');
    }
  }

  static Future<OrderModel> getOrderById(int orderId) async {
    String url = '${BaseApiService.baseUrl}/api/Order/$orderId';
    if (kDebugMode) debugPrint('OrderApiService: GET $url');
    final response = await http.get(
      Uri.parse(url),
      headers: BaseApiService.jsonHeaders,
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return OrderModel.fromJson(data);
    } else {
      throw Exception('Failed to load order: ${response.statusCode}');
    }
  }
} 