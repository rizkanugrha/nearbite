import 'package:flutter_test/flutter_test.dart';
import 'package:nearbite/core/errors/api_error.dart';

void main() {
  group('ApiError Mapping', () {
    test('mapHttpStatusToError maps 401 to AuthenticationError', () {
      final error = mapHttpStatusToError(401);

      expect(error, isA<AuthenticationError>());
      expect(error.message, contains('Email atau password'));
    });

    test('mapHttpStatusToError maps 403 to ForbiddenError', () {
      final error = mapHttpStatusToError(403);

      expect(error, isA<ForbiddenError>());
      expect(error.message, contains('akses'));
    });

    test('mapHttpStatusToError maps 404 to NotFoundError', () {
      final error = mapHttpStatusToError(404);

      expect(error, isA<NotFoundError>());
    });

    test('mapHttpStatusToError maps 4xx to ClientError', () {
      final error = mapHttpStatusToError(422);

      expect(error, isA<ClientError>());
      expect((error as ClientError).status, 422);
    });

    test('mapHttpStatusToError maps 5xx to ServerError', () {
      final error = mapHttpStatusToError(500);

      expect(error, isA<ServerError>());
      expect((error as ServerError).status, 500);
    });

    test('ApiError toString includes type and message', () {
      final error = const NetworkError('Connection timeout');

      expect(error.toString(), contains('NetworkError'));
      expect(error.toString(), contains('Connection timeout'));
    });

    test('Different error types are distinguishable', () {
      final authError = const AuthenticationError();
      final notFoundError = const NotFoundError();
      final networkError = const NetworkError();

      expect(authError, isA<AuthenticationError>());
      expect(notFoundError, isA<NotFoundError>());
      expect(networkError, isA<NetworkError>());

      expect(authError.runtimeType != notFoundError.runtimeType, true);
    });

    test('ClientError preserves status code', () {
      final error = const ClientError(400, 'Bad request');

      expect((error as ClientError).status, 400);
      expect(error.message, contains('Bad request'));
    });
  });
}
