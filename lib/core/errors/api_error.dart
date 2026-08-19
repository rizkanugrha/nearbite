import 'dart:convert';

/// Sealed class untuk error API. UI dapat melakukan switch exhaustif.
sealed class ApiError implements Exception {
  const ApiError(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Tidak bisa menjangkau server (offline, DNS, timeout).
class NetworkError extends ApiError {
  const NetworkError([super.message = 'Tidak ada koneksi internet.']);
}

/// Server mengembalikan HTTP 5xx.
class ServerError extends ApiError {
  const ServerError(this.status, [String? message])
      : super(message ?? 'Server error ($status): coba lagi nanti.');
  final int status;
}

/// Autentikasi gagal (401).
class AuthenticationError extends ApiError {
  const AuthenticationError([super.message = 'Email atau password salah.']);
}

/// Forbidden (403).
class ForbiddenError extends ApiError {
  const ForbiddenError([super.message = 'Anda tidak memiliki akses.']);
}

/// Resource tidak ditemukan (404).
class NotFoundError extends ApiError {
  const NotFoundError([super.message = 'Data tidak ditemukan.']);
}

/// Klien error lainnya (400, 422, dll).
class ClientError extends ApiError {
  const ClientError(this.status, [String? message])
      : super(message ?? 'Permintaan tidak valid ($status).');
  final int status;
}

/// Input pengguna atau payload tidak valid.
class ValidationError extends ApiError {
  const ValidationError([super.message = 'Data tidak valid.']);
}

/// Response tidak bisa di-parse JSON.
class ParseError extends ApiError {
  const ParseError([super.message = 'Response tidak dapat di-parse.']);
}

/// Memetakan status HTTP ke [ApiError] yang sesuai.
ApiError mapHttpStatusToError(int status, [String? body]) {
  if (status >= 500) return ServerError(status);
  final detail = _extractServerMessage(body);
  if (status == 401) {
    return AuthenticationError(detail ?? 'Email atau password salah.');
  }
  if (status == 403) {
    return ForbiddenError(detail ?? 'Anda tidak memiliki akses.');
  }
  if (status == 404) return const NotFoundError();
  if (status >= 400) return ClientError(status, detail);
  return ClientError(status, 'Unexpected status $status');
}

String? _extractServerMessage(String? body) {
  if (body == null || body.trim().isEmpty) return null;
  try {
    final json = jsonDecode(body);
    if (json is Map<String, dynamic>) {
      final message =
          json['message'] ?? json['error_description'] ?? json['hint'];
      if (message is String && message.isNotEmpty) return message;
    }
  } catch (_) {
    // Keep the generic client error when the server body is not JSON.
  }
  return null;
}
