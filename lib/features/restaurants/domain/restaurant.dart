import 'menu_item.dart';

/// Model Restaurant.
class Restaurant {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String address;
  final String operationalHours;
  final double latitude;
  final double longitude;
  final String? photoUrl;
  final List<MenuItem>? menuItems;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Restaurant({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.address,
    required this.operationalHours,
    required this.latitude,
    required this.longitude,
    this.photoUrl,
    this.menuItems,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert ke JSON untuk API request.
  Map<String, dynamic> toJson() => {
        'id': id,
        'owner_id': ownerId,
        'name': name,
        'description': description,
        'address': address,
        'open_hours': operationalHours,
        'latitude': latitude,
        'longitude': longitude,
        'photo_url': photoUrl,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  /// Parse dari JSON response API.
  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        id: json['id'] as String,
        ownerId: json['owner_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        address: json['address'] as String? ?? '',
        operationalHours: json['open_hours'] as String? ??
            json['operational_hours'] as String? ??
            '',
        latitude: (json['latitude'] as num? ?? 0).toDouble(),
        longitude: (json['longitude'] as num? ?? 0).toDouble(),
        photoUrl: json['photo_url'] as String?,
        menuItems: json['menu_items'] != null
            ? (json['menu_items'] as List)
                .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
                .toList()
            : null,
        createdAt: DateTime.parse(
            json['created_at'] as String? ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(
            json['updated_at'] as String? ?? DateTime.now().toIso8601String()),
      );

  /// Copy with untuk immutability.
  Restaurant copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? description,
    String? address,
    String? operationalHours,
    double? latitude,
    double? longitude,
    String? photoUrl,
    List<MenuItem>? menuItems,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Restaurant(
        id: id ?? this.id,
        ownerId: ownerId ?? this.ownerId,
        name: name ?? this.name,
        description: description ?? this.description,
        address: address ?? this.address,
        operationalHours: operationalHours ?? this.operationalHours,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        photoUrl: photoUrl ?? this.photoUrl,
        menuItems: menuItems ?? this.menuItems,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
