import 'package:shared_preferences/shared_preferences.dart';
import '../domain/user.dart';

/// Service untuk menyimpan dan mengambil session/token lokal.
class AuthLocalStorage {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';

  final SharedPreferences _prefs;

  AuthLocalStorage(this._prefs);

  /// Simpan user dan token setelah login/register.
  Future<void> saveUser(User user) async {
    await _prefs.setString(_tokenKey, user.token ?? '');
    await _prefs.setString(_userIdKey, user.id);
    await _prefs.setString(_userEmailKey, user.email);
    await _prefs.setString(_userNameKey, user.name);
  }

  /// Ambil user dari local storage jika ada sesi aktif.
  User? getUser() {
    final token = _prefs.getString(_tokenKey);
    final id = _prefs.getString(_userIdKey);
    final email = _prefs.getString(_userEmailKey);
    final name = _prefs.getString(_userNameKey);

    if (token == null || id == null || email == null || name == null) {
      return null;
    }

    return User(
      id: id,
      email: email,
      name: name,
      token: token,
      createdAt: DateTime.now(),
    );
  }

  /// Ambil token untuk request API.
  String? getToken() => _prefs.getString(_tokenKey);

  /// Hapus session (logout).
  Future<void> clearSession() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_userEmailKey);
    await _prefs.remove(_userNameKey);
  }

  /// Cek apakah ada session aktif.
  bool hasActiveSession() => _prefs.getString(_tokenKey)?.isNotEmpty == true;
}
