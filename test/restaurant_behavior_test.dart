import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nearbite/features/restaurants/data/remote/restaurant_api_client.dart';
import 'package:nearbite/features/restaurants/presentation/providers/restaurant_provider.dart';

void main() {
  RestaurantProvider createProvider() {
    final client = MockClient((request) async {
      if (request.url.path.endsWith('/restaurants')) {
        return http.Response(
          jsonEncode([
            {
              'id': 'near',
              'owner_id': 'owner',
              'name': 'Near Resto',
              'description': 'Dekat',
              'address': 'Jalan Dekat',
              'latitude': -6.2088,
              'longitude': 106.8456,
              'open_hours': '09:00-21:00',
              'created_at': '2026-08-10T03:00:00.000Z',
              'updated_at': '2026-08-10T03:00:00.000Z',
            },
            {
              'id': 'far',
              'owner_id': 'owner',
              'name': 'Far Resto',
              'description': 'Jauh',
              'address': 'Jalan Jauh',
              'latitude': -6.5951,
              'longitude': 106.7883,
              'open_hours': '09:00-21:00',
              'created_at': '2026-08-10T03:00:00.000Z',
              'updated_at': '2026-08-10T03:00:00.000Z',
            },
          ]),
          200,
        );
      }
      if (request.url.path.endsWith('/menu_items')) {
        return http.Response(
          jsonEncode([
            {
              'id': 'expensive',
              'restaurant_id': 'near',
              'name': 'Steak',
              'description': 'Menu mahal',
              'price': 50000,
              'is_available': true,
              'created_at': '2026-08-10T03:00:00.000Z',
            },
            {
              'id': 'cheap',
              'restaurant_id': 'near',
              'name': 'Nasi',
              'description': 'Menu murah',
              'price': 15000,
              'is_available': true,
              'created_at': '2026-08-10T03:00:00.000Z',
            },
          ]),
          200,
        );
      }
      return http.Response('[]', 200);
    });

    return RestaurantProvider(
      restaurantApiClient: RestaurantApiClient(
        baseUrl: 'https://test.supabase.co/rest/v1',
        httpClient: client,
      ),
    );
  }

  test('filters restaurants within a 3 km radius', () async {
    final provider = createProvider();
    await provider.loadRestaurants();
    provider.setUserLocation(latitude: -6.2088, longitude: 106.8456);

    final result = provider.restaurantsWithinRadius(3);

    expect(result.map((restaurant) => restaurant.id), ['near']);
  });

  test('sorts menu items by price ascending and descending', () async {
    final provider = createProvider();
    await provider.loadRestaurants();

    expect(
      provider.menuItemsSortedByPrice().map((menu) => menu.id),
      ['cheap', 'expensive'],
    );
    expect(
      provider.menuItemsSortedByPrice(ascending: false).map((menu) => menu.id),
      ['expensive', 'cheap'],
    );
  });

  test('searches menu case-insensitively and returns empty for no match',
      () async {
    final provider = createProvider();
    await provider.loadRestaurants();

    provider.setMenuSearchQuery('STEAK');
    expect(provider.filteredMenuItems.map((menu) => menu.id), ['expensive']);

    provider.setMenuSearchQuery('tidak ada');
    expect(provider.filteredMenuItems, isEmpty);
  });
}
