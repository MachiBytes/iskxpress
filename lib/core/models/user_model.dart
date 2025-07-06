class UserModel {
  final int id;
  final String name;
  final String email;
  final bool verified;
  final bool premium;
  final int authProvider;
  final String authProviderString;
  final int role;
  final String roleString;
  final int? profilePictureId;
  final String? pictureUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.verified,
    required this.premium,
    required this.authProvider,
    required this.authProviderString,
    required this.role,
    required this.roleString,
    this.profilePictureId,
    this.pictureUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      verified: json['verified'] ?? false,
      premium: json['premium'] ?? false,
      authProvider: json['authProvider'] ?? 0,
      authProviderString: json['authProviderString'] ?? '',
      role: json['role'] ?? 0,
      roleString: json['roleString'] ?? '',
      profilePictureId: json['profilePictureId'],
      pictureUrl: json['pictureUrl'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'verified': verified,
      'premium': premium,
      'authProvider': authProvider,
      'authProviderString': authProviderString,
      'role': role,
      'roleString': roleString,
      'profilePictureId': profilePictureId,
      'pictureUrl': pictureUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    bool? verified,
    bool? premium,
    int? authProvider,
    String? authProviderString,
    int? role,
    String? roleString,
    int? profilePictureId,
    String? pictureUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      verified: verified ?? this.verified,
      premium: premium ?? this.premium,
      authProvider: authProvider ?? this.authProvider,
      authProviderString: authProviderString ?? this.authProviderString,
      role: role ?? this.role,
      roleString: roleString ?? this.roleString,
      profilePictureId: profilePictureId ?? this.profilePictureId,
      pictureUrl: pictureUrl ?? this.pictureUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 