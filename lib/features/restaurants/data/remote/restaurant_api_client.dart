import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/errors/api_error.dart';
import '../../domain/restaurant.dart';
import '../../domain/menu_item.dart';
import '../../../auth/data/auth_local_storage.dart';

/// API client untuk restaurant dan menu.
class RestaurantApiClient {
  final String baseUrl;
  final http.Client httpClient;
  final AuthLocalStorage? localStorage;
  final String? apiKey;

  RestaurantApiClient({
    required this.baseUrl,
    http.Client? httpClient,
    this.localStorage,
    this.apiKey,
  }) : httpClient = httpClient ?? http.Client();

  String? get _token => localStorage?.getToken();

  String get _ownerId {
    final ownerId = localStorage?.getUser()?.id;
    if (ownerId == null || ownerId.isEmpty) {
      throw const AuthenticationError('User session tidak ditemukan.');
    }
    return ownerId;
  }

  Map<String, String> get _jsonHeaders => {
        'Content-Type': 'application/json',
        if (apiKey != null && apiKey!.isNotEmpty) 'apikey': apiKey!,
      };

  Map<String, String> get _returningHeaders => {
        ..._jsonHeaders,
        'Prefer': 'return=representation',
      };

  List<Map<String, dynamic>> _decodeRows(String body) {
    final decoded = jsonDecode(body);
    if (decoded is List) {
      return decoded.cast<Map<String, dynamic>>();
    }
    if (decoded is Map<String, dynamic> && decoded['data'] is List) {
      return (decoded['data'] as List).cast<Map<String, dynamic>>();
    }
    return const [];
  }

  Map<String, dynamic> _decodeRow(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic> && decoded['data'] is Map) {
      return Map<String, dynamic>.from(decoded['data'] as Map);
    }
    if (decoded is Map<String, dynamic> && decoded.containsKey('id')) {
      return decoded;
    }
    final rows = _decodeRows(body);
    if (rows.isEmpty) throw const ParseError('Data tidak ditemukan.');
    return rows.first;
  }

  String _requireToken() {
    final token = _token;
    if (token == null || token.isEmpty) {
      throw const AuthenticationError('No token available');
    }
    return token;
  }

  void _validateRestaurant(Restaurant restaurant) {
    if (restaurant.name.trim().isEmpty) {
      throw const ValidationError('Nama restoran wajib diisi.');
    }
  }

  void _validateMenuItem(MenuItem menuItem) {
    if (menuItem.name.trim().isEmpty) {
      throw const ValidationError('Nama menu wajib diisi.');
    }
    if (menuItem.price < 0) {
      throw const ValidationError('Harga menu tidak boleh negatif.');
    }
  }

  /// Ambil semua restaurant (public, tidak perlu token).
  Future<List<Restaurant>> getRestaurants() async {
    try {
      final response = await httpClient
          .get(
            Uri.parse('$baseUrl/restaurants?select=*'),
            headers: _jsonHeaders,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Request timeout'),
          );

      if (response.statusCode == 200) {
        return _decodeRows(response.body).map(Restaurant.fromJson).toList();
      } else {
        throw mapHttpStatusToError(response.statusCode, response.body);
      }
    } on ApiError {
      rethrow;
    } catch (e) {
      throw NetworkError('Gagal ambil restaurant: $e');
    }
  }

  /// Alias untuk kompatibilitas dengan test suite lama.
  Future<List<Restaurant>> searchRestaurants(String query) async {
    final restaurants = await getRestaurants();
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return restaurants;
    return restaurants.where((restaurant) {
      final name = restaurant.name.toLowerCase();
      final description = restaurant.description.toLowerCase();
      return name.contains(normalized) || description.contains(normalized);
    }).toList();
  }

  /// Ambil detail restaurant (public).
  Future<Restaurant> getRestaurant(String restaurantId) async {
    try {
      final response = await httpClient
          .get(
            Uri.parse(
              '$baseUrl/restaurants?select=*&id=eq.${Uri.encodeQueryComponent(restaurantId)}',
            ),
            headers: _jsonHeaders,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Request timeout'),
          );

      if (response.statusCode == 200) {
        final rows = _decodeRows(response.body);
        if (rows.isEmpty) {
          throw const NotFoundError('Restaurant tidak ditemukan');
        }
        return Restaurant.fromJson(rows.first);
      } else {
        throw mapHttpStatusToError(response.statusCode, response.body);
      }
    } on ApiError {
      rethrow;
    } catch (e) {
      throw NetworkError('Gagal ambil detail restaurant: $e');
    }
  }

  /// Alias kompatibilitas untuk test suite lama.
  Future<Restaurant> getRestaurantDetail(String restaurantId) =>
      getRestaurant(restaurantId);

  /// Ambil restaurant milik owner yang login.
  Future<Restaurant?> getOwnerRestaurant() async {
    try {
      final token = _requireToken();

      final response = await httpClient.get(
        Uri.parse(
          '$baseUrl/restaurants?select=*&owner_id=eq.${Uri.encodeQueryComponent(_ownerId)}',
        ),
        headers: {
          ..._jsonHeaders,
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Request timeout'),
      );

      if (response.statusCode == 200) {
        final rows = _decodeRows(response.body);
        return rows.isEmpty ? null : Restaurant.fromJson(rows.first);
      } else if (response.statusCode == 404) {
        return null; // Belum punya restaurant
      } else {
        throw mapHttpStatusToError(response.statusCode, response.body);
      }
    } on ApiError {
      rethrow;
    } catch (e) {
      throw NetworkError('Gagal ambil restaurant: $e');
    }
  }

  /// Create atau update restaurant (owner).
  Future<Restaurant> saveRestaurant(Restaurant restaurant) async {
    try {
      final token = _requireToken();
      final isCreate = restaurant.id.isEmpty;
      final url = isCreate
          ? Uri.parse('$baseUrl/restaurants')
          : Uri.parse(
              '$baseUrl/restaurants?id=eq.${Uri.encodeQueryComponent(restaurant.id)}',
            );

      final payload = <String, dynamic>{
        'name': restaurant.name.trim(),
        'description': restaurant.description.trim(),
        'address': restaurant.address.trim(),
        'open_hours': restaurant.operationalHours.trim(),
        'latitude': restaurant.latitude,
        'longitude': restaurant.longitude,
        'photo_url': restaurant.photoUrl,
        'updated_at': DateTime.now().toIso8601String(),
        if (isCreate) 'owner_id': _ownerId,
      };

      final request = http.Request(isCreate ? 'POST' : 'PATCH', url)
        ..headers.addAll({
          ..._returningHeaders,
          'Authorization': 'Bearer $token',
        })
        ..body = jsonEncode(payload);

      final response = await httpClient.send(request).timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Request timeout'),
          );
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw mapHttpStatusToError(response.statusCode, responseBody);
      }
      if (responseBody.trim().isEmpty) {
        throw const ParseError('Server tidak mengembalikan data restaurant.');
      }
      return Restaurant.fromJson(_decodeRow(responseBody));
    } on ApiError {
      rethrow;
    } catch (e) {
      throw NetworkError('Gagal simpan restaurant: $e');
    }
  }

  /// Alias kompatibilitas untuk create restaurant dari test suite lama.
  Future<Restaurant> createRestaurant(Restaurant restaurant) {
    _validateRestaurant(restaurant);
    _requireToken();
    return saveRestaurant(restaurant);
  }

  /// Ambil semua menu restaurant (public).
  Future<List<MenuItem>> getMenuItems(String restaurantId) async {
    try {
      final response = await httpClient
          .get(
            Uri.parse(
              '$baseUrl/menu_items?select=*&restaurant_id=eq.${Uri.encodeQueryComponent(restaurantId)}',
            ),
            headers: _jsonHeaders,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Request timeout'),
          );

      if (response.statusCode == 200) {
        return _decodeRows(response.body).map(MenuItem.fromJson).toList();
      } else {
        throw mapHttpStatusToError(response.statusCode, response.body);
      }
    } on ApiError {
      rethrow;
    } catch (e) {
      throw NetworkError('Gagal ambil menu: $e');
    }
  }

  /// Ambil seluruh menu publik untuk pencarian berdasarkan nama menu.
  Future<List<MenuItem>> getAllMenuItems() async {
    try {
      final response = await httpClient
          .get(
            Uri.parse('$baseUrl/menu_items?select=*'),
            headers: _jsonHeaders,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Request timeout'),
          );

      if (response.statusCode == 200) {
        return _decodeRows(response.body).map(MenuItem.fromJson).toList();
      }
      throw mapHttpStatusToError(response.statusCode, response.body);
    } on ApiError {
      rethrow;
    } catch (e) {
      throw NetworkError('Gagal ambil semua menu: $e');
    }
  }

  /// Create menu item (owner).
  Future<MenuItem> createMenuItem(MenuItem menuItem) {
    _validateMenuItem(menuItem);
    final token = _token;
    if (token == null || token.isEmpty) {
      throw const AuthenticationError('No token available');
    }

    return () async {
      try {
        final response = await httpClient
            .post(
              Uri.parse(
                '$baseUrl/menu_items',
              ),
              headers: {
                ..._returningHeaders,
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode(menuItem.toJson()
                ..remove('id')
                ..remove('created_at')
                ..remove('updated_at')),
            )
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () => throw TimeoutException('Request timeout'),
            );

        if (response.statusCode == 201) {
          return MenuItem.fromJson(_decodeRow(response.body));
        } else {
          throw mapHttpStatusToError(response.statusCode, response.body);
        }
      } on ApiError {
        rethrow;
      } catch (e) {
        throw NetworkError('Gagal tambah menu: $e');
      }
    }();
  }

  /// Update menu item (owner).
  Future<MenuItem> updateMenuItem(MenuItem menuItem) {
    _validateMenuItem(menuItem);
    if (menuItem.id.trim().isEmpty) {
      throw const ValidationError('ID menu wajib diisi saat edit.');
    }
    final token = _token;
    if (token == null || token.isEmpty) {
      throw const AuthenticationError('No token available');
    }

    return () async {
      try {
        final payload = <String, dynamic>{
          'name': menuItem.name.trim(),
          'description': menuItem.description.trim(),
          'price': menuItem.price,
          'photo_url': menuItem.photoUrl,
          'is_available': menuItem.isAvailable,
        };
        final response = await httpClient
            .patch(
              Uri.parse(
                '$baseUrl/menu_items?id=eq.${Uri.encodeQueryComponent(menuItem.id)}',
              ),
              headers: {
                ..._returningHeaders,
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode(payload),
            )
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () => throw TimeoutException('Request timeout'),
            );

        if (response.statusCode == 200) {
          return MenuItem.fromJson(_decodeRow(response.body));
        } else {
          throw mapHttpStatusToError(response.statusCode, response.body);
        }
      } on ApiError {
        rethrow;
      } catch (e) {
        throw NetworkError('Gagal update menu: $e');
      }
    }();
  }

  /// Delete menu item (owner).
  Future<void> deleteMenuItem(
    String restaurantId, [
    String? menuItemId,
  ]) {
    final token = _requireToken();

    final effectiveMenuId = menuItemId ?? restaurantId;

    return () async {
      try {
        final response = await httpClient.delete(
          Uri.parse(
            '$baseUrl/menu_items?id=eq.${Uri.encodeQueryComponent(effectiveMenuId)}',
          ),
          headers: {
            ..._jsonHeaders,
            'Authorization': 'Bearer $token',
          },
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('Request timeout'),
        );

        if (response.statusCode != 204 && response.statusCode != 200) {
          throw mapHttpStatusToError(response.statusCode, response.body);
        }
      } on ApiError {
        rethrow;
      } catch (e) {
        throw NetworkError('Gagal hapus menu: $e');
      }
    }();
  }
}

/// Exception untuk timeout.
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  @override
  String toString() => message;
}
