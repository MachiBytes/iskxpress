import 'category_model.dart';

class StallModel {
  final int id;
  final String name;
  final String shortDescription;
  final String? pictureUrl;
  final int vendorId;
  final String? vendorName;
  final String? createdAt;
  final String? updatedAt;
  final List<CategoryModel> categories;
  final bool deliveryAvailable;

  StallModel({
    required this.id,
    required this.name,
    required this.shortDescription,
    this.pictureUrl,
    required this.vendorId,
    this.vendorName,
    this.createdAt,
    this.updatedAt,
    this.categories = const [],
    this.deliveryAvailable = false,
  });

  factory StallModel.fromJson(Map<String, dynamic> json) {
    return StallModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      shortDescription: json['shortDescription'] ?? '',
      pictureUrl: json['pictureUrl'],
      vendorId: json['vendorId'] ?? 0,
      vendorName: json['vendorName'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      categories: (json['categories'] as List<dynamic>?)?.map((cat) => CategoryModel.fromJson(cat)).toList() ?? [],
      deliveryAvailable: json['deliveryAvailable'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shortDescription': shortDescription,
      'pictureUrl': pictureUrl,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'categories': categories.map((cat) => cat.toJson()).toList(),
      'deliveryAvailable': deliveryAvailable,
    };
  }

  StallModel copyWith({
    int? id,
    String? name,
    String? shortDescription,
    String? pictureUrl,
    int? vendorId,
    String? vendorName,
    String? createdAt,
    String? updatedAt,
    List<CategoryModel>? categories,
    bool? deliveryAvailable,
  }) {
    return StallModel(
      id: id ?? this.id,
      name: name ?? this.name,
      shortDescription: shortDescription ?? this.shortDescription,
      pictureUrl: pictureUrl ?? this.pictureUrl,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categories: categories ?? this.categories,
      deliveryAvailable: deliveryAvailable ?? this.deliveryAvailable,
    );
  }
} 