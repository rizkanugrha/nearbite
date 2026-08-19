import 'dart:math' as math;

/// Fungsi pure Dart untuk menghitung jarak menggunakan formula Haversine.
/// Mengembalikan jarak dalam kilometer.
///
/// Contoh test:
/// ```dart
/// final distance = calculateDistance(
///   userLat: -6.2088,
///   userLon: 106.8456,
///   restaurantLat: -6.1944,
///   restaurantLon: 106.8294,
/// );
/// expect(distance, greaterThan(0));
/// expect(distance, lessThan(10)); // Harus dekat
/// ```
double calculateDistance({
  required double userLat,
  required double userLon,
  required double restaurantLat,
  required double restaurantLon,
}) {
  const earthRadiusKm = 6371.0; // Radius bumi dalam km

  // Convert ke radian
  final latDiff = _toRadian(restaurantLat - userLat);
  final lonDiff = _toRadian(restaurantLon - userLon);
  final a = (math.sin(latDiff / 2) * math.sin(latDiff / 2)) +
      (math.cos(_toRadian(userLat)) *
          math.cos(_toRadian(restaurantLat)) *
          math.sin(lonDiff / 2) *
          math.sin(lonDiff / 2));

  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  final distance = earthRadiusKm * c;

  return distance;
}

/// Convert derajat ke radian.
double _toRadian(double degree) => degree * (math.pi / 180);
