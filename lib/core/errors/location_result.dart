/// Sealed class untuk hasil akses GPS. UI dapat melakukan switch exhaustif.
sealed class LocationResult {
  const LocationResult();

  /// Pattern matching untuk handling semua case dengan closure.
  R when<R>({
    required R Function(LocationSuccess location) success,
    required R Function(String message) denied,
    required R Function(String message) unavailable,
    required R Function(String message) error,
  }) {
    return switch (this) {
      LocationSuccess() => success(this as LocationSuccess),
      LocationDenied(message: final msg) => denied(msg),
      LocationUnavailable(message: final msg) => unavailable(msg),
      LocationError(message: final msg) => error(msg),
    };
  }
}

/// Berhasil mendapatkan lokasi pengguna.
class LocationSuccess extends LocationResult {
  final double latitude;
  final double longitude;

  const LocationSuccess({
    required this.latitude,
    required this.longitude,
  });
}

/// Izin akses lokasi ditolak oleh pengguna.
class LocationDenied extends LocationResult {
  final String message;
  const LocationDenied([this.message = 'Izin lokasi ditolak.']);
}

/// Layanan lokasi tidak tersedia (GPS mati, emulator tanpa GPS, dll).
class LocationUnavailable extends LocationResult {
  final String message;
  const LocationUnavailable([
    this.message = 'Layanan lokasi tidak tersedia.',
  ]);
}

/// Error lainnya saat akses lokasi.
class LocationError extends LocationResult {
  final String message;
  const LocationError([this.message = 'Error mengakses lokasi.']);
}
