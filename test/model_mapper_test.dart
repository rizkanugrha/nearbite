import 'package:flutter_test/flutter_test.dart';
import 'package:nearbite/features/restaurants/domain/restaurant.dart';
import 'package:nearbite/features/restaurants/domain/menu_item.dart';
import 'package:nearbite/features/auth/domain/user.dart';

void main() {
  group('Restaurant Mapper', () {
    test('Restaurant.fromJson parses JSON correctly', () {
      final json = {
        'id': 'rest-1',
        'owner_id': 'owner-1',
        'name': 'Warung Makan Asri',
        'description': 'Makanan tradisional Indonesia',
        'address': 'Jl. Merdeka No. 123, Jakarta',
        'open_hours': '10:00 - 22:00',
        'latitude': -6.2088,
        'longitude': 106.8456,
        'photo_url': 'https://example.com/photo.jpg',
        'created_at': '2024-01-01T10:00:00Z',
        'updated_at': '2024-01-02T15:30:00Z',
      };

      final restaurant = Restaurant.fromJson(json);

      expect(restaurant.id, 'rest-1');
      expect(restaurant.name, 'Warung Makan Asri');
      expect(restaurant.latitude, -6.2088);
      expect(restaurant.longitude, 106.8456);
      expect(restaurant.photoUrl, 'https://example.com/photo.jpg');
    });

    test('Restaurant.toJson returns correct structure', () {
      final restaurant = Restaurant(
        id: 'rest-1',
        ownerId: 'owner-1',
        name: 'Warung Makan Asri',
        description: 'Makanan tradisional',
        address: 'Jl. Merdeka 123',
        operationalHours: '10:00 - 22:00',
        latitude: -6.2088,
        longitude: 106.8456,
        photoUrl: 'https://example.com/photo.jpg',
        createdAt: DateTime.parse('2024-01-01T10:00:00Z'),
        updatedAt: DateTime.parse('2024-01-02T15:30:00Z'),
      );

      final json = restaurant.toJson();

      expect(json['id'], 'rest-1');
      expect(json['name'], 'Warung Makan Asri');
      expect(json['latitude'], -6.2088);
      expect(json['longitude'], 106.8456);
    });

    test('Restaurant.copyWith creates new instance with updated fields', () {
      final restaurant = Restaurant(
        id: 'rest-1',
        ownerId: 'owner-1',
        name: 'Restaurant Lama',
        description: 'Deskripsi Lama',
        address: 'Alamat Lama',
        operationalHours: '10:00 - 20:00',
        latitude: -6.2088,
        longitude: 106.8456,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = restaurant.copyWith(name: 'Restaurant Baru');

      expect(updated.id, 'rest-1');
      expect(updated.name, 'Restaurant Baru');
      expect(updated.description, 'Deskripsi Lama');
    });
  });

  group('MenuItem Mapper', () {
    test('MenuItem.fromJson parses JSON correctly with numeric price', () {
      final json = {
        'id': 'menu-1',
        'restaurant_id': 'rest-1',
        'name': 'Nasi Goreng Spesial',
        'description': 'Nasi dengan telur, ayam, dan sayuran',
        'price': 25000,
        'photo_url': 'https://example.com/menu.jpg',
        'created_at': '2024-01-01T10:00:00Z',
        'updated_at': '2024-01-02T15:30:00Z',
      };

      final menuItem = MenuItem.fromJson(json);

      expect(menuItem.id, 'menu-1');
      expect(menuItem.name, 'Nasi Goreng Spesial');
      expect(menuItem.price, 25000);
      expect(menuItem.price, isA<int>());
    });

    test('MenuItem.fromJson handles null optional fields', () {
      final json = {
        'id': 'menu-1',
        'restaurant_id': 'rest-1',
        'name': 'Menu Sederhana',
        'description': '',
        'price': 15000,
        'photo_url': null,
        'created_at': '2024-01-01T10:00:00Z',
        'updated_at': '2024-01-02T15:30:00Z',
      };

      final menuItem = MenuItem.fromJson(json);

      expect(menuItem.name, 'Menu Sederhana');
      expect(menuItem.description, '');
      expect(menuItem.photoUrl, null);
    });

    test('MenuItem price must be non-negative', () {
      final menuItem = MenuItem(
        id: 'menu-1',
        restaurantId: 'rest-1',
        name: 'Menu Valid',
        description: 'Valid',
        price: 50000,
        createdAt: DateTime.now(),
      );

      expect(menuItem.price, greaterThanOrEqualTo(0));
    });
  });

  group('User Mapper', () {
    test('User.fromJson parses JSON correctly', () {
      final json = {
        'id': 'user-1',
        'email': 'owner@example.com',
        'name': 'John Doe',
        'token': 'token-abc123',
        'created_at': '2024-01-01T10:00:00Z',
      };

      final user = User.fromJson(json);

      expect(user.id, 'user-1');
      expect(user.email, 'owner@example.com');
      expect(user.name, 'John Doe');
      expect(user.token, 'token-abc123');
    });

    test('User.toJson returns correct structure', () {
      final user = User(
        id: 'user-1',
        email: 'owner@example.com',
        name: 'John Doe',
        token: 'token-abc123',
        createdAt: DateTime.parse('2024-01-01T10:00:00Z'),
      );

      final json = user.toJson();

      expect(json['id'], 'user-1');
      expect(json['email'], 'owner@example.com');
      expect(json['name'], 'John Doe');
    });

    test('User.copyWith preserves token', () {
      final user = User(
        id: 'user-1',
        email: 'old@example.com',
        name: 'Old Name',
        token: 'token-abc123',
        createdAt: DateTime.now(),
      );

      final updated = user.copyWith(name: 'New Name');

      expect(updated.token, 'token-abc123');
      expect(updated.name, 'New Name');
      expect(updated.email, 'old@example.com');
    });
  });
}
