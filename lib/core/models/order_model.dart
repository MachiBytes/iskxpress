class OrderModel {
  final int id;
  final String stallName;
  final double totalPrice;
  final DateTime createdAt;
  final int status;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.stallName,
    required this.totalPrice,
    required this.createdAt,
    required this.status,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      stallName: json['stallName'] ?? '',
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      status: json['status'] ?? 0,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItemModel.fromJson(item)).toList(),
    );
  }

  String get createdAtString =>
      '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
}

class OrderItemModel {
  final String productName;
  final double basePrice;
  final int quantity;
  final double totalPrice;

  OrderItemModel({
    required this.productName,
    required this.basePrice,
    required this.quantity,
    required this.totalPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productName: json['productName'] ?? '',
      basePrice: (json['basePrice'] ?? 0.0).toDouble(),
      quantity: json['quantity'] ?? 1,
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
    );
  }
} 