import 'product_model.dart';

class CartItemModel {
  final int id;
  final int productId;
  final int stallId;
  final String stallName;
  final String? stallPictureUrl;
  final ProductModel product;
  final int quantity;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.stallId,
    required this.stallName,
    this.stallPictureUrl,
    required this.product,
    required this.quantity,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    // Create a ProductModel from the flat fields
    final product = ProductModel(
      id: json['productId'] ?? 0,
      name: json['productName'] ?? '',
      basePrice: (json['productBasePrice'] ?? 0.0).toDouble(),
      sectionId: 0, // Not provided in cart response
      imageUrl: json['productPictureUrl'],
      availability: json['productAvailability'] ?? 0,
      priceWithMarkup: json['productPriceWithMarkup'] != null ? (json['productPriceWithMarkup'] as num).toDouble() : null,
      premiumUserPrice: json['productPremiumUserPrice'] != null ? (json['productPremiumUserPrice'] as num).toDouble() : null,
    );

    return CartItemModel(
      id: json['id'] ?? 0,
      productId: json['productId'] ?? 0,
      stallId: json['stallId'] ?? 0,
      stallName: json['stallName'] ?? '',
      stallPictureUrl: json['stallPictureUrl'],
      product: product,
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'stallId': stallId,
      'stallName': stallName,
      'stallPictureUrl': stallPictureUrl,
      'product': product.toJson(),
      'quantity': quantity,
    };
  }
} 