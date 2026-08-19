import 'package:geolocator/geolocator.dart';
import 'package:nearbite/core/errors/location_result.dart';

/// Service untuk akses GPS/lokasi pengguna.
/// Menangani permission handling dan error dengan sealed result type.
abstract class LocationService {
  Future<LocationResult> getCurrentLocation();
}

/// Implementasi nyata menggunakan geolocator package.
class GeolocatorLocationService implements LocationService {
  @override
  Future<LocationResult> getCurrentLocation() async {
    try {
      // Cek apakah layanan lokasi enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationUnavailable(
          'Layanan lokasi tidak diaktifkan. Aktifkan di pengaturan.',
        );
      }

      // Cek permission saat ini
      LocationPermission permission = await Geolocator.checkPermission();

      // Jika belum diberikan, minta permission
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const LocationDenied(
            'Izin akses lokasi ditolak. Kami membutuhkan izin untuk menampilkan resto terdekat.',
          );
        }
      }

      // Jika permanently denied, kembalikan error
      if (permission == LocationPermission.deniedForever) {
        return const LocationDenied(
          'Izin lokasi ditolak secara permanen. Ubah di pengaturan aplikasi.',
        );
      }

      // Dapatkan lokasi
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return LocationSuccess(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      return LocationError('Error mendapatkan lokasi: $e');
    }
  }
}

/// Mock location service untuk testing dan development.
class MockLocationService implements LocationService {
  /// Jika true, akan return LocationDenied; jika false, return LocationSuccess.
  final bool permissionDenied;

  /// Koordinat yang akan di-return jika berhasil.
  final double latitude;
  final double longitude;

  MockLocationService({
    this.permissionDenied = false,
    this.latitude = -6.2088, // Jakarta Pusat default
    this.longitude = 106.8456,
  });

  @override
  Future<LocationResult> getCurrentLocation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (permissionDenied) {
      return const LocationDenied();
    }
    return LocationSuccess(latitude: latitude, longitude: longitude);
  }
}
