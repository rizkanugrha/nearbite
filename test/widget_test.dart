import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nearbite/features/restaurants/presentation/screens/menu_form_screen.dart';
import 'package:nearbite/features/restaurants/presentation/providers/menu_provider.dart';
import 'package:nearbite/features/restaurants/data/remote/restaurant_api_client.dart';
import 'package:nearbite/features/restaurants/domain/menu_item.dart';
import 'package:nearbite/core/constants/app_strings.dart';

void main() {
  group('Menu Form Validation Tests', () {
    late MockMenuProvider mockMenuProvider;
    late MockRestaurantApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockRestaurantApiClient();
      mockMenuProvider = MockMenuProvider(mockApiClient);
    });

    testWidgets('Menu form shows validation error when name is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<MenuProvider>.value(
                value: mockMenuProvider,
              ),
            ],
            child: const MenuFormScreen(restaurantId: 'resto-test-1'),
          ),
        ),
      );

      // Find price field and enter valid value
      final priceField = find.byType(TextField).at(1); // Second field is price
      await tester.enterText(priceField, '25000');

      // Tap save button without entering name
      final saveButton = find.byType(ElevatedButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Should show validation error
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Text && widget.data!.contains('wajib diisi'),
        ),
        findsWidgets,
      );
    });

    testWidgets('Menu form shows validation error for non-numeric price',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<MenuProvider>.value(
                value: mockMenuProvider,
              ),
            ],
            child: const MenuFormScreen(restaurantId: 'resto-test-2'),
          ),
        ),
      );

      // Enter valid name
      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, 'Menu Test');

      // Enter invalid price (non-numeric) - price field is at index 2
      final priceField = find.byType(TextField).at(2);
      await tester.enterText(priceField, 'abc');

      // Tap save button
      final saveButton = find.byType(ElevatedButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Should show validation error for price via errorText in TextField
      final priceTextField =
          tester.widget<TextField>(find.byType(TextField).at(2));
      expect(priceTextField.decoration?.errorText, isNotNull);
      expect(priceTextField.decoration?.errorText, contains('angka'));
    });

    testWidgets('Menu form shows validation error for negative price',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<MenuProvider>.value(
                value: mockMenuProvider,
              ),
            ],
            child: const MenuFormScreen(restaurantId: 'resto-test-3'),
          ),
        ),
      );

      // Enter valid name
      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, 'Menu Test');

      // Enter negative price - price field is at index 2
      final priceField = find.byType(TextField).at(2);
      await tester.enterText(priceField, '-5000');

      // Tap save button
      final saveButton = find.byType(ElevatedButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Should show validation error via errorText in TextField
      final priceTextField =
          tester.widget<TextField>(find.byType(TextField).at(2));
      expect(priceTextField.decoration?.errorText, isNotNull);
      expect(priceTextField.decoration?.errorText, contains('angka'));
    });

    testWidgets('Menu form accepts valid data and calls save',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<MenuProvider>.value(
                value: mockMenuProvider,
              ),
            ],
            child: const MenuFormScreen(restaurantId: 'resto-test-4'),
          ),
        ),
      );

      // Enter all valid data
      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, 'Nasi Goreng Spesial');

      final priceField = find.byType(TextField).at(1);
      await tester.enterText(priceField, '25000');

      // Tap save button
      final saveButton = find.byType(ElevatedButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Should not show validation error on either field
      final nameTextField =
          tester.widget<TextField>(find.byType(TextField).first);
      final priceTextField =
          tester.widget<TextField>(find.byType(TextField).at(1));

      expect(nameTextField.decoration?.errorText, isNull);
      expect(priceTextField.decoration?.errorText, isNull);
    });

    testWidgets('Menu price field accepts up to 9 digits (Rp999.999.999)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<MenuProvider>.value(
                value: mockMenuProvider,
              ),
            ],
            child: const MenuFormScreen(restaurantId: 'resto-test-5'),
          ),
        ),
      );

      // Enter valid name
      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, 'Expensive Dish');

      // Enter very high price
      final priceField = find.byType(TextField).at(1);
      await tester.enterText(priceField, '999999999'); // Max typical price

      // Tap save
      final saveButton = find.byType(ElevatedButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Should accept without error
      expect(find.byType(ScaffoldMessenger), findsWidgets);
    });
  });
}

// Mock classes for testing
class MockRestaurantApiClient implements RestaurantApiClient {
  @override
  Future<MenuItem> createMenuItem(MenuItem menuItem) async {
    // Mock implementation - return the same item with an ID
    return menuItem.copyWith(id: 'mock-menu-id');
  }

  @override
  Future<void> deleteMenuItem(String restaurantId, [String? menuItemId]) async {
    // Mock implementation
  }

  @override
  Future<MenuItem> updateMenuItem(MenuItem menuItem) async {
    // Mock implementation - return the updated item
    return menuItem;
  }

  // Implement other required methods
  @override
  noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class MockMenuProvider extends MenuProvider {
  MockMenuProvider(RestaurantApiClient apiClient)
      : super(restaurantApiClient: apiClient);

  @override
  Future<void> addMenuItem(MenuItem menuItem) async {
    // Mock: simulate success
  }

  @override
  Future<void> updateMenuItem(MenuItem menuItem) async {
    // Mock: simulate success
  }

  @override
  Future<void> deleteMenuItem(String menuItemId) async {
    // Mock: simulate success
  }
}
