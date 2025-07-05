class OrderModel {
  final int id;
  final int userId;
  final int stallId;
  final String stallName;
  final int status;
  final int fulfillmentMethod;
  final String? deliveryAddress;
  final String? notes;
  final double totalPrice;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.userId,
    required this.stallId,
    required this.stallName,
    required this.status,
    required this.fulfillmentMethod,
    this.deliveryAddress,
    this.notes,
    required this.totalPrice,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      stallId: json['stallId'] ?? 0,
      stallName: json['stallName'] ?? '',
      status: json['status'] ?? 0,
      fulfillmentMethod: json['fulfillmentMethod'] ?? 0,
      deliveryAddress: json['deliveryAddress'],
      notes: json['notes'],
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      items: (json['orderItems'] as List<dynamic>? ?? [])
          .map((item) => OrderItemModel.fromJson(item)).toList(),
    );
  }

  String get createdAtString =>
      '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
      
  String get statusText {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'To Prepare';
      case 2:
        return 'To Deliver';
      case 3:
        return 'To Receive';
      case 4:
        return 'Completed';
      default:
        return 'Unknown';
    }
  }
  
  String get fulfillmentMethodText {
    switch (fulfillmentMethod) {
      case 0:
        return 'Pickup';
      case 1:
        return 'Delivery';
      default:
        return 'Unknown';
    }
  }
}

class OrderItemModel {
  final int id;
  final int productId;
  final String productName;
  final String? productDescription;
  final String? productPictureUrl;
  final int quantity;
  final double priceEach;
  final double totalPrice;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.productDescription,
    this.productPictureUrl,
    required this.quantity,
    required this.priceEach,
    required this.totalPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] ?? 0,
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      productDescription: json['productDescription'],
      productPictureUrl: json['productPictureUrl'],
      quantity: json['quantity'] ?? 1,
      priceEach: (json['priceEach'] ?? 0.0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
    );
  }
} 