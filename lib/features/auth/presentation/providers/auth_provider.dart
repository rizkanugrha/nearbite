import 'package:flutter/foundation.dart';
import 'package:nearbite/core/errors/api_error.dart';
import 'package:nearbite/features/auth/data/auth_local_storage.dart';
import 'package:nearbite/features/auth/data/remote/auth_api_client.dart';
import 'package:nearbite/features/auth/domain/user.dart';

/// State untuk autentikasi.
enum AuthState { initial, loading, authenticated, unauthenticated, error }

/// Provider untuk autentikasi dan session management.
class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required AuthApiClient authApiClient,
    required AuthLocalStorage localStorage,
  })  : _authApiClient = authApiClient,
        _localStorage = localStorage {
    _initialize();
  }

  final AuthApiClient _authApiClient;
  final AuthLocalStorage _localStorage;

  AuthState _state = AuthState.initial;
  User? _currentUser;
  String? _error;
  bool _isLoading = false;
  int _sessionValidationVersion = 0;

  AuthState get state => _state;
  User? get currentUser => _currentUser;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  /// Initialize: cek apakah ada session aktif.
  void _initialize() {
    _currentUser = _localStorage.getUser();
    _state = _currentUser != null
        ? AuthState.authenticated
        : AuthState.unauthenticated;
    notifyListeners();

    if (_currentUser != null) {
      _validateCachedSession();
    }
  }

  /// Validasi token lokal tanpa mengunci startup ketika perangkat offline.
  Future<void> _validateCachedSession() async {
    final cachedUser = _currentUser;
    if (cachedUser == null) return;
    final validationVersion = ++_sessionValidationVersion;

    try {
      final serverUser = await _authApiClient.getMe();
      if (validationVersion != _sessionValidationVersion) return;
      _currentUser = serverUser.copyWith(
        name: serverUser.name.isEmpty ? cachedUser.name : serverUser.name,
      );
      await _localStorage.saveUser(_currentUser!);
      notifyListeners();
    } on AuthenticationError {
      if (validationVersion != _sessionValidationVersion) return;
      _currentUser = null;
      _state = AuthState.unauthenticated;
      await _localStorage.clearSession();
      notifyListeners();
    } on NetworkError {
      // Pertahankan session lokal agar app tetap bisa menampilkan halaman
      // owner saat validasi gagal karena perangkat sedang offline.
    } catch (_) {
      // Error non-auth tidak boleh mengeluarkan user secara sepihak.
    }
  }

  /// Register akun pemilik resto baru.
  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _error = null;
    _state = AuthState.loading;
    notifyListeners();

    try {
      final user = await _authApiClient.register(
        email: email,
        password: password,
        name: name,
      );
      if (user.token == null || user.token!.isEmpty) {
        _currentUser = null;
        _error = 'Registrasi berhasil. Silakan cek email untuk verifikasi.';
        _state = AuthState.unauthenticated;
        return;
      }
      _currentUser = user;
      await _localStorage.saveUser(user);
      _state = AuthState.authenticated;
    } on ApiError catch (e) {
      _error = e.message;
      _state = AuthState.error;
    } catch (e) {
      _error = 'Register gagal: $e';
      _state = AuthState.error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login dengan email dan password.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    _sessionValidationVersion++;
    _isLoading = true;
    _error = null;
    _state = AuthState.loading;
    notifyListeners();

    try {
      final user = await _authApiClient.login(
        email: email,
        password: password,
      );
      _currentUser = user;
      await _localStorage.saveUser(user);
      _state = AuthState.authenticated;
    } on ApiError catch (e) {
      _error = e.message;
      _state = AuthState.error;
    } catch (e) {
      _error = 'Login gagal: $e';
      _state = AuthState.error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout dan hapus session.
  Future<void> logout() async {
    _sessionValidationVersion++;
    _currentUser = null;
    _error = null;
    _state = AuthState.unauthenticated;
    await _localStorage.clearSession();
    notifyListeners();
  }

  /// Clear error message.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
