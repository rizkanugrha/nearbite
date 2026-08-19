/// Model User untuk autentikasi.
class User {
  final String id;
  final String email;
  final String name;
  final String? token;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.token,
    required this.createdAt,
  });

  /// Convert ke JSON untuk API request.
  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'created_at': createdAt.toIso8601String(),
      };

  /// Parse dari JSON response API.
  factory User.fromJson(Map<String, dynamic> json) {
    final metadata = json['user_metadata'] as Map<String, dynamic>?;
    final name = json['name'] as String? ?? metadata?['name'] as String? ?? '';
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: name,
      token: json['token'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Copy with untuk immutability.
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? token,
    DateTime? createdAt,
  }) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        token: token ?? this.token,
        createdAt: createdAt ?? this.createdAt,
      );
}
