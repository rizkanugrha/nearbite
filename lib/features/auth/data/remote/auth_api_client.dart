import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/errors/api_error.dart';
import '../auth_local_storage.dart';
import '../../domain/user.dart';

/// API client untuk autentikasi.
class AuthApiClient {
  final String baseUrl;
  final String apiKey;
  final http.Client httpClient;
  final AuthLocalStorage localStorage;

  AuthApiClient({
    required this.baseUrl,
    this.apiKey = '',
    required this.httpClient,
    required this.localStorage,
  });

  /// Register akun pemilik resto baru.
  Future<User> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await httpClient
          .post(
            Uri.parse('$baseUrl/auth/v1/signup'),
            headers: _headers,
            body: jsonEncode({
              'email': email,
              'password': password,
              'data': {'name': name},
            }),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Request timeout'),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final user = _userFromAuthResponse(data);

        // Insert user ke tabel users di database
        await _insertUserToDatabase(user, name);

        return user;
      } else {
        throw mapHttpStatusToError(response.statusCode, response.body);
      }
    } on ApiError {
      rethrow;
    } catch (e) {
      throw NetworkError('Gagal register: $e');
    }
  }

  /// Insert data user ke tabel users di database.
  Future<void> _insertUserToDatabase(User user, String name) async {
    try {
      final token = user.token;
      if (token == null || token.isEmpty) {
        return; // Skip jika tidak ada token (email confirmation required)
      }

      final response = await httpClient
          .post(
            Uri.parse('$baseUrl/rest/v1/users'),
            headers: {
              'Content-Type': 'application/json',
              if (apiKey.isNotEmpty) 'apikey': apiKey,
              'Authorization': 'Bearer $token',
              'Prefer': 'return=representation',
            },
            body: jsonEncode({
              'id': user.id,
              'email': user.email,
              'full_name': name,
              'created_at': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Request timeout'),
          );

      if (response.statusCode != 200 && response.statusCode != 201) {
        // Log error tapi jangan throw, karena user sudah terdaftar di auth
        // Mungkin tabel users belum ada atau ada constraint violation
        print(
            'Warning: Gagal insert user ke database: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      // Log error tapi jangan throw, karena user sudah terdaftar di auth
      print('Warning: Gagal insert user ke database: $e');
    }
  }

  /// Login dengan email dan password.
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await httpClient
          .post(
            Uri.parse('$baseUrl/auth/v1/token?grant_type=password'),
            headers: _headers,
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Request timeout'),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return _userFromAuthResponse(data);
      } else {
        throw mapHttpStatusToError(response.statusCode, response.body);
      }
    } on ApiError {
      rethrow;
    } catch (e) {
      throw NetworkError('Gagal login: $e');
    }
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (apiKey.isNotEmpty) 'apikey': apiKey,
      };

  User _userFromAuthResponse(Map<String, dynamic> data) {
    final user = data['user'] as Map<String, dynamic>? ?? data;
    return User.fromJson({
      ...user,
      'token': data['access_token'],
    });
  }

  /// Ambil data user dari token (refresh session).
  Future<User> getMe() async {
    try {
      final token = localStorage.getToken();
      if (token == null) {
        throw const AuthenticationError('No token available');
      }

      final response = await httpClient.get(
        Uri.parse('$baseUrl/auth/v1/user'),
        headers: {
          ..._headers,
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Request timeout'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final user = User.fromJson(data['user'] ?? data);
        return user.copyWith(token: token);
      } else {
        throw mapHttpStatusToError(response.statusCode, response.body);
      }
    } on ApiError {
      rethrow;
    } catch (e) {
      throw NetworkError('Gagal get user: $e');
    }
  }
}

/// Exception untuk timeout.
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  @override
  String toString() => message;
}
