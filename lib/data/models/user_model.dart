class UserModel {
  final String id;
  final String name;
  final String email;
  final String profilePicture;
  final int totalScore;
  final int level;
  final DateTime joinedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture = '',
    this.totalScore = 0,
    this.level = 1,
    required this.joinedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'totalScore': totalScore,
      'level': level,
      'joinedAt': joinedAt.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profilePicture: json['profilePicture'] as String? ?? '',
      totalScore: json['totalScore'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      joinedAt: DateTime.fromMillisecondsSinceEpoch(json['joinedAt'] as int),
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? profilePicture,
    int? totalScore,
    int? level,
    DateTime? joinedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      totalScore: totalScore ?? this.totalScore,
      level: level ?? this.level,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, totalScore: $totalScore, level: $level)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
