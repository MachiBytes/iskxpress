class SectionModel {
  final int id;
  final String name;
  final int stallId;
  final String? createdAt;
  final String? updatedAt;

  SectionModel({
    required this.id,
    required this.name,
    required this.stallId,
    this.createdAt,
    this.updatedAt,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      stallId: json['stallId'] ?? 0,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'stallId': stallId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  SectionModel copyWith({
    int? id,
    String? name,
    int? stallId,
    String? createdAt,
    String? updatedAt,
  }) {
    return SectionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      stallId: stallId ?? this.stallId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 