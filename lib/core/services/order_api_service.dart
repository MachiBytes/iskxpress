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

  static Future<List<OrderModel>> getOrdersWithoutDeliveryPartner() async {
    String url = '${BaseApiService.baseUrl}/api/Order?hasDeliveryPartner=false';
    if (kDebugMode) debugPrint('OrderApiService: GET $url');
    final response = await http.get(
      Uri.parse(url),
      headers: BaseApiService.jsonHeaders,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => OrderModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load orders without delivery partner: ${response.statusCode}');
    }
  }

  static Future<bool> assignDeliveryPartner(int orderId, int deliveryPartnerId) async {
    String url = '${BaseApiService.baseUrl}/api/Order/$orderId/assign-delivery-partner';
    if (kDebugMode) debugPrint('OrderApiService: PUT $url with deliveryPartnerId: $deliveryPartnerId');
    
    final response = await http.put(
      Uri.parse(url),
      headers: BaseApiService.jsonHeaders,
      body: json.encode({
        'deliveryPartnerId': deliveryPartnerId,
      }),
    );
    
    if (response.statusCode == 200) {
      if (kDebugMode) debugPrint('OrderApiService: Successfully assigned delivery partner');
      return true;
    } else {
      if (kDebugMode) debugPrint('OrderApiService: Failed to assign delivery partner: ${response.statusCode}');
      throw Exception('Failed to assign delivery partner: ${response.statusCode}');
    }
  }

  static Future<List<OrderModel>> getActiveDeliveriesForPartner(int deliveryPartnerId) async {
    String url = '${BaseApiService.baseUrl}/api/Order/delivery-partner/$deliveryPartnerId?isFinished=false';
    if (kDebugMode) debugPrint('OrderApiService: GET $url');
    final response = await http.get(
      Uri.parse(url),
      headers: BaseApiService.jsonHeaders,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => OrderModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load active deliveries: ${response.statusCode}');
    }
  }

  static Future<List<OrderModel>> getFinishedDeliveriesForPartner(int deliveryPartnerId) async {
    String url = '${BaseApiService.baseUrl}/api/Order/delivery-partner/$deliveryPartnerId?isFinished=true';
    if (kDebugMode) debugPrint('OrderApiService: GET $url');
    final response = await http.get(
      Uri.parse(url),
      headers: BaseApiService.jsonHeaders,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => OrderModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load finished deliveries: ${response.statusCode}');
    }
  }

  static Future<List<OrderModel>> getOrdersForStall(int stallId) async {
    String url = '${BaseApiService.baseUrl}/api/Order/stall/$stallId';
    if (kDebugMode) debugPrint('OrderApiService: GET $url');
    final response = await http.get(
      Uri.parse(url),
      headers: BaseApiService.jsonHeaders,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => OrderModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load stall orders: ${response.statusCode}');
    }
  }

  static Future<bool> updateOrderStatus(int orderId, int status) async {
    String url = '${BaseApiService.baseUrl}/api/Order/$orderId/status';
    if (kDebugMode) debugPrint('OrderApiService: PUT $url with status: $status');
    
    final response = await http.put(
      Uri.parse(url),
      headers: BaseApiService.jsonHeaders,
      body: json.encode({
        'status': status,
      }),
    );
    
    if (response.statusCode == 200) {
      if (kDebugMode) debugPrint('OrderApiService: Successfully updated order status');
      return true;
    } else {
      if (kDebugMode) debugPrint('OrderApiService: Failed to update order status: ${response.statusCode}');
      throw Exception('Failed to update order status: ${response.statusCode}');
    }
  }

  static Future<bool> rejectOrder(int orderId, String rejectionReason) async {
    String url = '${BaseApiService.baseUrl}/api/Order/$orderId/reject';
    if (kDebugMode) debugPrint('OrderApiService: PUT $url with rejectionReason: $rejectionReason');
    
    final response = await http.put(
      Uri.parse(url),
      headers: BaseApiService.jsonHeaders,
      body: json.encode({
        'rejectionReason': rejectionReason,
      }),
    );
    
    if (response.statusCode == 200) {
      if (kDebugMode) debugPrint('OrderApiService: Successfully rejected order');
      return true;
    } else {
      if (kDebugMode) debugPrint('OrderApiService: Failed to reject order: ${response.statusCode}');
      throw Exception('Failed to reject order: ${response.statusCode}');
    }
  }
} 