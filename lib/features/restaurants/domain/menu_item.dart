/// Model Menu Item.
class MenuItem {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final int price;
  final String? photoUrl;
  final bool isAvailable;
  final DateTime createdAt;

  const MenuItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    this.photoUrl,
    this.isAvailable = true,
    required this.createdAt,
  });

  /// Convert ke JSON untuk API request.
  Map<String, dynamic> toJson() => {
        'id': id,
        'restaurant_id': restaurantId,
        'name': name,
        'description': description,
        'price': price,
        'photo_url': photoUrl,
        'is_available': isAvailable,
        'created_at': createdAt.toIso8601String(),
      };

  /// Parse dari JSON response API.
  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: json['id'] as String,
        restaurantId: json['restaurant_id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        price: (json['price'] as num).toInt(),
        photoUrl: json['photo_url'] as String?,
        isAvailable: json['is_available'] as bool? ?? true,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  /// Copy with untuk immutability.
  MenuItem copyWith({
    String? id,
    String? restaurantId,
    String? name,
    String? description,
    int? price,
    String? photoUrl,
    bool? isAvailable,
    DateTime? createdAt,
  }) =>
      MenuItem(
        id: id ?? this.id,
        restaurantId: restaurantId ?? this.restaurantId,
        name: name ?? this.name,
        description: description ?? this.description,
        price: price ?? this.price,
        photoUrl: photoUrl ?? this.photoUrl,
        isAvailable: isAvailable ?? this.isAvailable,
        createdAt: createdAt ?? this.createdAt,
      );
}
