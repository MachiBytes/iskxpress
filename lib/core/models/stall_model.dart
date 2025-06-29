class StallModel {
  final int id;
  final String name;
  final String shortDescription;
  final String? pictureUrl;
  final int vendorId;
  final String? createdAt;
  final String? updatedAt;

  StallModel({
    required this.id,
    required this.name,
    required this.shortDescription,
    this.pictureUrl,
    required this.vendorId,
    this.createdAt,
    this.updatedAt,
  });

  factory StallModel.fromJson(Map<String, dynamic> json) {
    return StallModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      shortDescription: json['shortDescription'] ?? '',
      pictureUrl: json['pictureUrl'],
      vendorId: json['vendorId'] ?? 0,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shortDescription': shortDescription,
      'pictureUrl': pictureUrl,
      'vendorId': vendorId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  StallModel copyWith({
    int? id,
    String? name,
    String? shortDescription,
    String? pictureUrl,
    int? vendorId,
    String? createdAt,
    String? updatedAt,
  }) {
    return StallModel(
      id: id ?? this.id,
      name: name ?? this.name,
      shortDescription: shortDescription ?? this.shortDescription,
      pictureUrl: pictureUrl ?? this.pictureUrl,
      vendorId: vendorId ?? this.vendorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 