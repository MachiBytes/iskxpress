class ProductModel {
  final int id;
  final String name;
  final double basePrice;
  final int sectionId;
  final int? categoryId;
  final String? imageUrl;
  final String? createdAt;
  final String? updatedAt;
  final int availability; // 0 = available, 1 = sold out
  final double? priceWithDelivery;

  // Default markup percentage (20% - you can adjust this value)
  static const double defaultMarkupPercentage = 20.0;

  ProductModel({
    required this.id,
    required this.name,
    required this.basePrice,
    required this.sectionId,
    this.categoryId,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
    this.availability = 0,
    this.priceWithDelivery,
  });

  // Calculate selling price with markup
  double get sellingPrice {
    return basePrice * (1 + (defaultMarkupPercentage / 100));
  }

  // Get markup amount
  double get markupAmount {
    return basePrice * (defaultMarkupPercentage / 100);
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      basePrice: (json['basePrice'] ?? 0.0).toDouble(),
      sectionId: json['sectionId'] ?? 0,
      categoryId: json['categoryId'],
      imageUrl: json['pictureUrl'] ?? json['imageUrl'], // Try pictureUrl first, fallback to imageUrl
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      availability: json['availability'] ?? 0,
      priceWithDelivery: json['priceWithDelivery'] != null ? (json['priceWithDelivery'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'basePrice': basePrice,
      'sectionId': sectionId,
      'categoryId': categoryId,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'availability': availability,
      'priceWithDelivery': priceWithDelivery,
    };
  }

  ProductModel copyWith({
    int? id,
    String? name,
    double? basePrice,
    int? sectionId,
    int? categoryId,
    String? imageUrl,
    String? createdAt,
    String? updatedAt,
    int? availability,
    double? priceWithDelivery,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      basePrice: basePrice ?? this.basePrice,
      sectionId: sectionId ?? this.sectionId,
      categoryId: categoryId ?? this.categoryId,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      availability: availability ?? this.availability,
      priceWithDelivery: priceWithDelivery ?? this.priceWithDelivery,
    );
  }
} 