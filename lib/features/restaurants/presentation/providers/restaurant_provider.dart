import 'package:flutter/foundation.dart';
import '../../../../core/errors/api_error.dart';
import '../../../../core/utils/distance_calculator.dart';
import '../../data/remote/restaurant_api_client.dart';
import '../../domain/restaurant.dart';
import '../../domain/menu_item.dart';

/// Provider untuk restaurant list, search, dan detail.
class RestaurantProvider extends ChangeNotifier {
  RestaurantProvider({
    required RestaurantApiClient restaurantApiClient,
  }) : _restaurantApiClient = restaurantApiClient;

  final RestaurantApiClient _restaurantApiClient;

  List<Restaurant> _restaurants = [];
  Restaurant? _selectedRestaurant;
  List<MenuItem> _menuItems = [];
  String? _error;
  bool _isLoading = false;
  String _searchQuery = '';
  String _menuSearchQuery = '';

  // User location untuk sorting
  double? _userLatitude;
  double? _userLongitude;

  List<Restaurant> get restaurants => List.unmodifiable(_restaurants);
  Restaurant? get selectedRestaurant => _selectedRestaurant;
  List<MenuItem> get menuItems => List.unmodifiable(_menuItems);
  String? get error => _error;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get menuSearchQuery => _menuSearchQuery;
  bool get hasLocationData => _userLatitude != null && _userLongitude != null;

  List<MenuItem> get filteredMenuItems {
    final query = _menuSearchQuery.trim().toLowerCase();
    final items = query.isEmpty
        ? _menuItems
        : _menuItems.where((menu) {
            return menu.name.toLowerCase().contains(query) ||
                menu.description.toLowerCase().contains(query);
          }).toList();
    return List.unmodifiable(items);
  }

  List<Restaurant> restaurantsWithinRadius(double radiusKm) {
    if (!hasLocationData) return const [];
    return _restaurants.where((restaurant) {
      final distance = getDistanceToRestaurant(restaurant);
      return distance != null && distance <= radiusKm;
    }).toList(growable: false);
  }

  List<MenuItem> menuItemsSortedByPrice({bool ascending = true}) {
    final sorted = List<MenuItem>.from(_menuItems)
      ..sort((a, b) =>
          ascending ? a.price.compareTo(b.price) : b.price.compareTo(a.price));
    return List.unmodifiable(sorted);
  }

  /// Get filtered restaurants berdasarkan search query.
  List<Restaurant> get filteredRestaurants {
    if (_searchQuery.isEmpty) {
      return restaurants;
    }

    final query = _searchQuery.toLowerCase();
    return _restaurants.where((restaurant) {
      final nameMatch = restaurant.name.toLowerCase().contains(query);
      final descMatch = restaurant.description.toLowerCase().contains(query);
      // Cek juga apakah ada menu yang cocok
      final menuMatch = _menuItems.any((menu) =>
          menu.restaurantId == restaurant.id &&
          menu.name.toLowerCase().contains(query));

      return nameMatch || descMatch || menuMatch;
    }).toList();
  }

  /// Set user location untuk sorting jarak.
  void setUserLocation({
    required double latitude,
    required double longitude,
  }) {
    _userLatitude = latitude;
    _userLongitude = longitude;
    _sortRestaurantsByDistance();
    notifyListeners();
  }

  /// Load semua restaurant dan sort by distance jika ada user location.
  Future<void> loadRestaurants() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _restaurants = await _restaurantApiClient.getRestaurants();
      try {
        _menuItems = await _restaurantApiClient.getAllMenuItems();
      } on ApiError {
        // Daftar resto publik tetap dapat digunakan jika menu gagal dimuat.
        _menuItems = [];
      }
      _sortRestaurantsByDistance();
    } on ApiError catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Gagal memuat restaurant: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sort restaurant by distance dari user.
  void _sortRestaurantsByDistance() {
    if (!hasLocationData) return;

    _restaurants.sort((a, b) {
      final distanceA = calculateDistance(
        userLat: _userLatitude!,
        userLon: _userLongitude!,
        restaurantLat: a.latitude,
        restaurantLon: a.longitude,
      );

      final distanceB = calculateDistance(
        userLat: _userLatitude!,
        userLon: _userLongitude!,
        restaurantLat: b.latitude,
        restaurantLon: b.longitude,
      );

      return distanceA.compareTo(distanceB);
    });
  }

  /// Get jarak dari user ke restaurant (return null jika belum ada location).
  double? getDistanceToRestaurant(Restaurant restaurant) {
    if (!hasLocationData) return null;

    return calculateDistance(
      userLat: _userLatitude!,
      userLon: _userLongitude!,
      restaurantLat: restaurant.latitude,
      restaurantLon: restaurant.longitude,
    );
  }

  /// Load detail restaurant dan menu-nya.
  Future<void> loadRestaurantDetail(String restaurantId) async {
    _isLoading = true;
    _error = null;
    _selectedRestaurant = null;
    _menuItems = [];
    notifyListeners();

    try {
      // Data resto sudah tersedia dari daftar publik; gunakan itu sebagai
      // fallback jika query detail berdasarkan ID tidak mengembalikan baris.
      for (final restaurant in _restaurants) {
        if (restaurant.id == restaurantId) {
          _selectedRestaurant = restaurant;
          break;
        }
      }
      _selectedRestaurant ??=
          await _restaurantApiClient.getRestaurant(restaurantId);
      _menuItems = await _restaurantApiClient.getMenuItems(restaurantId);
    } on ApiError catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Gagal memuat detail: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set search query.
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setMenuSearchQuery(String query) {
    _menuSearchQuery = query;
    notifyListeners();
  }

  /// Clear error.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear selected restaurant dan menu.
  void clearDetail() {
    _selectedRestaurant = null;
    _menuItems = [];
    notifyListeners();
  }
}
