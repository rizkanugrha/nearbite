import 'package:flutter_test/flutter_test.dart';
import 'package:nearbite/core/utils/distance_calculator.dart';

void main() {
  group('Distance Calculator (Haversine)', () {
    test('calculateDistance returns 0 for same coordinates', () {
      const latitude = -6.2088;
      const longitude = 106.8456;

      final distance = calculateDistance(
        userLat: latitude,
        userLon: longitude,
        restaurantLat: latitude,
        restaurantLon: longitude,
      );

      expect(distance, lessThan(0.001)); // Harus sangat dekat ke 0
    });

    test('calculateDistance returns positive value for different coordinates',
        () {
      final distance = calculateDistance(
        userLat: -6.2088, // Jakarta Pusat
        userLon: 106.8456,
        restaurantLat: -6.1944, // Sedikit beda
        restaurantLon: 106.8294,
      );

      expect(distance, greaterThan(0));
      expect(distance, lessThan(5)); // Harus dalam radius 5 km
    });

    test('calculateDistance is symmetric', () {
      final distance1 = calculateDistance(
        userLat: -6.2088,
        userLon: 106.8456,
        restaurantLat: -6.1944,
        restaurantLon: 106.8294,
      );

      final distance2 = calculateDistance(
        userLat: -6.1944,
        userLon: 106.8294,
        restaurantLat: -6.2088,
        restaurantLon: 106.8456,
      );

      expect(
          distance1, closeTo(distance2, 0.001)); // Harus sama dengan toleransi
    });

    test('calculateDistance returns reasonable value for known coordinates',
        () {
      // Jakarta ke Bogor (sekitar 60 km)
      final distance = calculateDistance(
        userLat: -6.2088, // Jakarta
        userLon: 106.8456,
        restaurantLat: -6.5951, // Bogor
        restaurantLon: 106.7883,
      );

      expect(distance, greaterThan(40)); // Minimal 40 km
      expect(distance, lessThan(80)); // Maksimal 80 km
    });
  });
}
