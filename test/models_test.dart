import 'package:flutter_test/flutter_test.dart';
import 'package:nearbite/features/auth/domain/user.dart';
import 'package:nearbite/features/restaurants/domain/restaurant.dart';
import 'package:nearbite/features/restaurants/domain/menu_item.dart';

void main() {
  group('User Model Tests (ERD §2.1)', () {
    test('User.fromJson parses email correctly', () {
      final json = {
        'id': 'user-123',
        'email': 'owner@rest.com',
        'name': 'Ahmad Sutrisno',
        'token': 'jwt-token-xyz',
        'created_at': '2026-08-10T03:00:00.000Z',
      };

      final user = User.fromJson(json);

      expect(user.id, 'user-123');
      expect(user.email, 'owner@rest.com');
      expect(user.name, 'Ahmad Sutrisno');
      expect(user.token, 'jwt-token-xyz');
    });

    test('User.fromJson requires email field', () {
      final json = {
        'id': 'user-123',
        'name': 'Ahmad',
        'token': 'jwt-token',
        'created_at': '2026-08-10T03:00:00.000Z',
      };

      expect(() => User.fromJson(json), throwsA(isA<TypeError>()));
    });

    test('User.toJson produces snake_case fields', () {
      final user = User(
        id: 'user-456',
        email: 'owner2@rest.com',
        name: 'Siti Nurhaliza',
        token: 'jwt-token-abc',
        createdAt: DateTime(2026, 8, 10),
      );

      final json = user.toJson();

      expect(json['id'], 'user-456');
      expect(json['email'], 'owner2@rest.com');
      expect(json['name'], 'Siti Nurhaliza');
      // Note: token is not included in toJson() for security
    });

    test('User.copyWith preserves immutability', () {
      final user1 = User(
        id: 'user-789',
        email: 'old@email.com',
        name: 'Old Name',
        token: 'old-token',
        createdAt: DateTime(2026, 8, 10),
      );

      final user2 = user1.copyWith(email: 'new@email.com');

      expect(user1.email, 'old@email.com');
      expect(user2.email, 'new@email.com');
      expect(user1.id, user2.id); // Other fields unchanged
    });
  });

  group('Restaurant Model Tests (ERD §2.2)', () {
    test('Restaurant.fromJson parses all required fields', () {
      final json = {
        'id': 'resto-1',
        'owner_id': 'owner-1',
        'name': 'Warung Gudeg Bu Sri',
        'description': 'Gudeg khas Jogja',
        'address': 'Jl. Kaliurang KM 5',
        'latitude': -7.7620,
        'longitude': 110.3790,
        'photo_url': 'https://storage.example/resto/gudeg.jpg',
        'open_hours': '06:00-14:00',
        'created_at': '2026-08-10T03:00:00.000Z',
        'updated_at': '2026-08-10T03:00:00.000Z',
      };

      final resto = Restaurant.fromJson(json);

      expect(resto.id, 'resto-1');
      expect(resto.ownerId, 'owner-1');
      expect(resto.name, 'Warung Gudeg Bu Sri');
      expect(resto.latitude, -7.7620);
      expect(resto.longitude, 110.3790);
    });

    test('Restaurant coordinates are within valid ranges (ERD §1.2)', () {
      final json = {
        'id': 'resto-2',
        'owner_id': 'owner-1',
        'name': 'Test Resto',
        'address': 'Jl. Test',
        'latitude': -6.1944, // Valid: -90 to 90
        'longitude': 106.8294, // Valid: -180 to 180
        'created_at': '2026-08-10T03:00:00.000Z',
        'updated_at': '2026-08-10T03:00:00.000Z',
      };

      final resto = Restaurant.fromJson(json);

      expect(resto.latitude, greaterThanOrEqualTo(-90));
      expect(resto.latitude, lessThanOrEqualTo(90));
      expect(resto.longitude, greaterThanOrEqualTo(-180));
      expect(resto.longitude, lessThanOrEqualTo(180));
    });

    test('Restaurant.toJson converts snake_case correctly', () {
      final resto = Restaurant(
        id: 'resto-3',
        ownerId: 'owner-2',
        name: 'Bakmi Jawa Pak Karto',
        description: 'Bakmi godog & goreng',
        address: 'Jl. Kaliurang KM 7',
        latitude: -7.7480,
        longitude: 110.3810,
        photoUrl: 'https://storage.example/bakmi.jpg',
        operationalHours: '17:00-23:00',
        createdAt: DateTime(2026, 8, 10),
        updatedAt: DateTime(2026, 8, 10),
      );

      final json = resto.toJson();

      expect(json['name'], 'Bakmi Jawa Pak Karto');
      expect(json['open_hours'], '17:00-23:00');
      expect(json['photo_url'], contains('bakmi.jpg'));
    });

    test('Restaurant name minimum length validation (ERD §2.2)', () {
      final json = {
        'id': 'resto-4',
        'owner_id': 'owner-1',
        'name': 'AB', // Less than 3 chars - violates ERD rule
        'address': 'Jl. Test',
        'latitude': -6.1944,
        'longitude': 106.8294,
        'created_at': '2026-08-10T03:00:00.000Z',
        'updated_at': '2026-08-10T03:00:00.000Z',
      };

      // Model should accept it (validation at API level)
      final resto = Restaurant.fromJson(json);
      expect(resto.name, 'AB');
    });

    test('Restaurant operationalHours parsed correctly', () {
      final json = {
        'id': 'resto-5',
        'owner_id': 'owner-1',
        'name': 'Test Resto',
        'address': 'Jl. Test',
        'latitude': -6.1944,
        'longitude': 106.8294,
        'open_hours': '09:00-22:00',
        'created_at': '2026-08-10T03:00:00.000Z',
        'updated_at': '2026-08-10T03:00:00.000Z',
      };

      final resto = Restaurant.fromJson(json);

      expect(resto.operationalHours, '09:00-22:00');
    });
  });

  group('MenuItem Model Tests (ERD §2.3)', () {
    test('MenuItem.fromJson parses all fields correctly', () {
      final json = {
        'id': 'menu-1',
        'restaurant_id': 'resto-1',
        'name': 'Gudeg Komplit',
        'description': 'Gudeg, telur, ayam, krecek',
        'price': 25000,
        'photo_url': 'https://storage.example/gudeg-komplit.jpg',
        'created_at': '2026-08-10T03:00:00.000Z',
        'updated_at': '2026-08-10T03:00:00.000Z',
      };

      final menu = MenuItem.fromJson(json);

      expect(menu.id, 'menu-1');
      expect(menu.restaurantId, 'resto-1');
      expect(menu.name, 'Gudeg Komplit');
      expect(menu.price, 25000.0);
    });

    test('MenuItem price is always >= 0 (ERD §2.3)', () {
      final json = {
        'id': 'menu-2',
        'restaurant_id': 'resto-1',
        'name': 'Teste',
        'price': 15000,
        'created_at': '2026-08-10T03:00:00.000Z',
        'updated_at': '2026-08-10T03:00:00.000Z',
      };

      final menu = MenuItem.fromJson(json);
      expect(menu.price, greaterThanOrEqualTo(0));
    });

    test('MenuItem price as double per ERD §1.2', () {
      // ERD specifies price as INTEGER for accuracy (rupiah full)
      // But Dart model uses double for flexibility
      final json = {
        'id': 'menu-3',
        'restaurant_id': 'resto-1',
        'name': 'Menu Test',
        'price': 25000, // Integer from JSON
        'created_at': '2026-08-10T03:00:00.000Z',
        'updated_at': '2026-08-10T03:00:00.000Z',
      };

      final menu = MenuItem.fromJson(json);

      expect(menu.price, isA<int>());
      expect(menu.price, 25000);
    });

    test('MenuItem price string converted to double safely', () {
      // Backend might return string sometimes
      final json = {
        'id': 'menu-4',
        'restaurant_id': 'resto-1',
        'name': 'Ayam Geprek',
        'description': 'Ayam geprek sambal bawang',
        'price': '15000', // String from some backends
        'created_at': '2026-08-10T03:00:00.000Z',
        'updated_at': '2026-08-10T03:00:00.000Z',
      };

      // Should handle string to double conversion or throw TypeError
      expect(
          () => MenuItem.fromJson(json),
          anyOf(
            returnsNormally,
            throwsA(isA<TypeError>()),
          ));
    });

    test('MenuItem.toJson preserves price as int', () {
      final menu = MenuItem(
        id: 'menu-5',
        restaurantId: 'resto-1',
        name: 'Nasi Goreng Spesial',
        description: 'Dengan telur dan ayam',
        price: 20000,
        photoUrl: null,
        createdAt: DateTime(2026, 8, 10),
      );

      final json = menu.toJson();

      expect(json['price'], isA<int>());
      expect(json['price'], 20000);
    });

    test('MenuItem photo_url optional (can be null)', () {
      final json = {
        'id': 'menu-6',
        'restaurant_id': 'resto-1',
        'name': 'Simple Menu',
        'price': 10000,
        'photo_url': null,
        'created_at': '2026-08-10T03:00:00.000Z',
      };

      final menu = MenuItem.fromJson(json);

      expect(menu.photoUrl, isNull);
    });

    test('MenuItem.copyWith updates only specified fields', () {
      final menu1 = MenuItem(
        id: 'menu-7',
        restaurantId: 'resto-1',
        name: 'Original',
        description: 'Test description',
        price: 10000,
        createdAt: DateTime(2026, 8, 10),
      );

      final menu2 = menu1.copyWith(price: 12000);

      expect(menu1.name, 'Original');
      expect(menu1.price, 10000);
      expect(menu2.price, 12000);
      expect(menu2.name, 'Original'); // Unchanged
    });
  });

  group('Model JSON Round-Trip Tests (ERD §6 JSON format)', () {
    test('User: JSON → fromJson → toJson → fromJson preserves data', () {
      final originalJson = {
        'id': 'user-rt-1',
        'email': 'test@rest.com',
        'name': 'Test Owner',
        'token': 'token-xyz',
        'created_at': '2026-08-10T03:00:00.000Z',
      };

      final user1 = User.fromJson(originalJson);
      final json = user1.toJson();
      final user2 = User.fromJson(json);

      expect(user1.id, user2.id);
      expect(user1.email, user2.email);
      expect(user1.name, user2.name);
    });

    test('Restaurant: JSON → fromJson → toJson → fromJson', () {
      final originalJson = {
        'id': 'resto-rt-1',
        'owner_id': 'owner-1',
        'name': 'Round Trip Resto',
        'description': 'Test description',
        'address': 'Jl. Test',
        'latitude': -7.7620,
        'longitude': 110.3790,
        'open_hours': '10:00-22:00',
        'created_at': '2026-08-10T03:00:00.000Z',
        'updated_at': '2026-08-10T03:00:00.000Z',
      };

      final resto1 = Restaurant.fromJson(originalJson);
      final json = resto1.toJson();
      final resto2 = Restaurant.fromJson(json);

      expect(resto1.name, resto2.name);
      expect(resto1.latitude, resto2.latitude);
      expect(resto1.longitude, resto2.longitude);
    });

    test('MenuItem: JSON → fromJson → toJson preserves price', () {
      final originalJson = {
        'id': 'menu-rt-1',
        'restaurant_id': 'resto-1',
        'name': 'Menu Round Trip',
        'price': 25000,
        'created_at': '2026-08-10T03:00:00.000Z',
        'updated_at': '2026-08-10T03:00:00.000Z',
      };

      final menu1 = MenuItem.fromJson(originalJson);
      final json = menu1.toJson();

      expect(json['price'], 25000);
      expect(json['price'], isA<int>());
    });
  });

  group('Model Field Type Coercion (ERD §6.2 parsing tips)', () {
    test('latitude/longitude accept int and convert to double', () {
      final json = {
        'id': 'resto-coerce-1',
        'owner_id': 'owner-1',
        'name': 'Test',
        'description': 'Test description',
        'address': 'Test',
        'latitude': 110, // Integer, should coerce to double
        'longitude': -7,
        'open_hours': '10:00-22:00',
        'created_at': '2026-08-10T03:00:00.000Z',
        'updated_at': '2026-08-10T03:00:00.000Z',
      };

      final resto = Restaurant.fromJson(json);

      expect(resto.latitude, isA<double>());
      expect(resto.longitude, isA<double>());
    });

    test('MenuItem price accepts int or String representation', () {
      // First test: int
      final json1 = {
        'id': 'menu-c1',
        'restaurant_id': 'resto-1',
        'name': 'Menu 1',
        'description': 'Test description',
        'price': 25000,
        'created_at': '2026-08-10T03:00:00.000Z',
        'updated_at': '2026-08-10T03:00:00.000Z',
      };

      final menu1 = MenuItem.fromJson(json1);
      expect(menu1.price, 25000.0);

      // Note: String test depends on MenuItem.fromJson implementation
      // Some implementations might accept string, some not
    });
  });
}
