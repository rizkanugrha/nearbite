import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:nearbite/core/providers/connectivity_provider.dart';

/// Mock Connectivity untuk testing tanpa dependency pada hardware nyata.
class MockConnectivity implements Connectivity {
  final StreamController<List<ConnectivityResult>> _controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  List<ConnectivityResult> _currentResult = [ConnectivityResult.wifi];

  /// Set hasil connectivity check yang akan di-return.
  void setConnectivity(List<ConnectivityResult> results) {
    _currentResult = results;
    _controller.add(results);
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return _currentResult;
  }

  void dispose() {
    _controller.close();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ConnectivityProvider', () {
    late MockConnectivity mockConnectivity;
    late ConnectivityProvider provider;

    setUp(() {
      mockConnectivity = MockConnectivity();
      provider = ConnectivityProvider(connectivity: mockConnectivity);
    });

    tearDown(() {
      provider.dispose();
      mockConnectivity.dispose();
    });

    test('initial state should be online', () {
      expect(provider.state, isA<ConnectivityOnline>());
      expect(provider.isConnected, isTrue);
    });

    test('initialize should check initial connection', () async {
      mockConnectivity.setConnectivity([ConnectivityResult.none]);

      await provider.initialize();

      // Wait for async operations
      await Future.delayed(const Duration(milliseconds: 100));

      expect(provider.state, isA<ConnectivityOffline>());
      expect(provider.isConnected, isFalse);
    });

    test('should update to offline when connectivity changes to none',
        () async {
      await provider.initialize();

      mockConnectivity.setConnectivity([ConnectivityResult.none]);

      // Wait for stream to propagate
      await Future.delayed(const Duration(milliseconds: 100));

      expect(provider.state, isA<ConnectivityOffline>());
      expect(provider.isConnected, isFalse);
    });

    test('should update to online when connectivity changes to wifi', () async {
      mockConnectivity.setConnectivity([ConnectivityResult.none]);
      await provider.initialize();
      await Future.delayed(const Duration(milliseconds: 100));

      mockConnectivity.setConnectivity([ConnectivityResult.wifi]);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(provider.state, isA<ConnectivityOnline>());
      expect(provider.isConnected, isTrue);
    });

    test('should update to online when connectivity changes to mobile',
        () async {
      mockConnectivity.setConnectivity([ConnectivityResult.none]);
      await provider.initialize();
      await Future.delayed(const Duration(milliseconds: 100));

      mockConnectivity.setConnectivity([ConnectivityResult.mobile]);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(provider.state, isA<ConnectivityOnline>());
      expect(provider.isConnected, isTrue);
    });

    test('should notify listeners when state changes', () async {
      await provider.initialize();

      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      mockConnectivity.setConnectivity([ConnectivityResult.none]);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifyCount, greaterThan(0));
    });

    test('should not notify listeners when state does not change', () async {
      await provider.initialize();
      await Future.delayed(const Duration(milliseconds: 100));

      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      // Set same state (online) again
      mockConnectivity.setConnectivity([ConnectivityResult.wifi]);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifyCount, equals(0));
    });

    test('should handle multiple connectivity types as online', () async {
      await provider.initialize();

      mockConnectivity.setConnectivity([ConnectivityResult.ethernet]);
      await Future.delayed(const Duration(milliseconds: 100));
      expect(provider.isConnected, isTrue);

      mockConnectivity.setConnectivity([ConnectivityResult.bluetooth]);
      await Future.delayed(const Duration(milliseconds: 100));
      expect(provider.isConnected, isFalse);
    });

    test('should handle mixed connectivity results', () async {
      await provider.initialize();

      // If any connection is active, should be online
      mockConnectivity.setConnectivity([
        ConnectivityResult.none,
        ConnectivityResult.wifi,
      ]);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(provider.isConnected, isTrue);
    });

    test('dispose should cancel subscription without error', () async {
      // Use a separate provider so tearDown dispose doesn't double-dispose
      final localProvider =
          ConnectivityProvider(connectivity: mockConnectivity);
      await localProvider.initialize();

      // Dispose should not throw
      expect(() => localProvider.dispose(), returnsNormally);

      // Sending events after dispose should not cause errors
      mockConnectivity.setConnectivity([ConnectivityResult.none]);
      await Future.delayed(const Duration(milliseconds: 100));
    });
  });

  group('ConnectivityState', () {
    test('ConnectivityOnline should be a ConnectivityState', () {
      const state = ConnectivityOnline();
      expect(state, isA<ConnectivityState>());
    });

    test('ConnectivityOffline should be a ConnectivityState', () {
      const state = ConnectivityOffline();
      expect(state, isA<ConnectivityState>());
    });

    test('ConnectivityOnline and ConnectivityOffline should be different types',
        () {
      const online = ConnectivityOnline();
      const offline = ConnectivityOffline();

      expect(online.runtimeType, isNot(equals(offline.runtimeType)));
    });
  });
}
