import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Provider untuk monitoring status koneksi internet.
/// Menggunakan sealed class pattern untuk type-safe state management.
sealed class ConnectivityState {
  const ConnectivityState();
}

/// State ketika internet tersedia.
class ConnectivityOnline extends ConnectivityState {
  const ConnectivityOnline();
}

/// State ketika internet tidak tersedia.
class ConnectivityOffline extends ConnectivityState {
  const ConnectivityOffline();
}

/// Provider yang memantau status koneksi internet secara real-time.
/// Menggunakan ChangeNotifier untuk notifikasi ke UI.
class ConnectivityProvider extends ChangeNotifier {
  ConnectivityProvider({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityState _state = const ConnectivityOnline();

  /// State koneksi saat ini.
  ConnectivityState get state => _state;

  /// Apakah internet tersedia.
  bool get isConnected => _state is ConnectivityOnline;

  /// Inisialisasi listener untuk perubahan koneksi.
  Future<void> initialize() async {
    // Cek status awal
    await _checkInitialConnection();

    // Listen untuk perubahan koneksi
    _subscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  /// Cek koneksi awal saat provider dibuat.
  Future<void> _checkInitialConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      // Jika gagal cek, anggap offline untuk safety
      _updateState(const ConnectivityOffline());
    }
  }

  /// Update state berdasarkan hasil connectivity check.
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // Bluetooth bukan indikator koneksi internet.
    final hasConnection = results.any(
      (result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.vpn ||
          result == ConnectivityResult.other,
    );

    if (hasConnection) {
      _updateState(const ConnectivityOnline());
    } else {
      _updateState(const ConnectivityOffline());
    }
  }

  /// Update state dan notify listeners jika berubah.
  void _updateState(ConnectivityState newState) {
    if (_state.runtimeType != newState.runtimeType) {
      _state = newState;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
