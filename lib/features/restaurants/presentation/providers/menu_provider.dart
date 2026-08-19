import 'package:flutter/foundation.dart';
import '../../../../core/errors/api_error.dart';
import '../../data/remote/restaurant_api_client.dart';
import '../../domain/menu_item.dart';
import '../../domain/restaurant.dart';

/// Provider untuk CRUD menu owner.
class MenuProvider extends ChangeNotifier {
  MenuProvider({
    required RestaurantApiClient restaurantApiClient,
  }) : _restaurantApiClient = restaurantApiClient;

  final RestaurantApiClient _restaurantApiClient;

  Restaurant? _ownerRestaurant;
  List<MenuItem> _menuItems = [];
  String? _error;
  bool _isLoading = false;

  Restaurant? get ownerRestaurant => _ownerRestaurant;
  List<MenuItem> get menuItems => List.unmodifiable(_menuItems);
  String? get error => _error;
  bool get isLoading => _isLoading;

  /// Load restaurant dan menu milik owner yang login.
  Future<void> loadOwnerData() async {
    _isLoading = true;
    _error = null;
    _ownerRestaurant = null;
    _menuItems = [];
    notifyListeners();

    try {
      _ownerRestaurant = await _restaurantApiClient.getOwnerRestaurant();
      if (_ownerRestaurant != null) {
        _menuItems =
            await _restaurantApiClient.getMenuItems(_ownerRestaurant!.id);
      }
    } on ApiError catch (e) {
      _ownerRestaurant = null;
      _menuItems = [];
      _error = e.message;
    } catch (e) {
      _ownerRestaurant = null;
      _menuItems = [];
      _error = 'Gagal memuat data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save restaurant profile.
  Future<void> saveRestaurantProfile(Restaurant restaurant) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _ownerRestaurant = await _restaurantApiClient.saveRestaurant(restaurant);
      // Reload menu items if this is a new restaurant
      if (_ownerRestaurant != null && _menuItems.isEmpty) {
        _menuItems =
            await _restaurantApiClient.getMenuItems(_ownerRestaurant!.id);
      }
    } on ApiError catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Gagal simpan profil: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add menu item.
  Future<void> addMenuItem(MenuItem menuItem) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newItem = await _restaurantApiClient.createMenuItem(menuItem);
      _menuItems.add(newItem);
    } on ApiError catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Gagal tambah menu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update menu item.
  Future<void> updateMenuItem(MenuItem menuItem) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedItem = await _restaurantApiClient.updateMenuItem(menuItem);
      final index = _menuItems.indexWhere((m) => m.id == menuItem.id);
      if (index != -1) {
        _menuItems[index] = updatedItem;
      }
    } on ApiError catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Gagal update menu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete menu item.
  Future<void> deleteMenuItem(String menuItemId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_ownerRestaurant == null) {
        throw const ClientError(400, 'Restaurant not found');
      }
      await _restaurantApiClient.deleteMenuItem(
        _ownerRestaurant!.id,
        menuItemId,
      );
      _menuItems.removeWhere((m) => m.id == menuItemId);
    } on ApiError catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Gagal hapus menu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear semua data (saat logout).
  void clear() {
    _ownerRestaurant = null;
    _menuItems = [];
    _error = null;
    notifyListeners();
  }
}
