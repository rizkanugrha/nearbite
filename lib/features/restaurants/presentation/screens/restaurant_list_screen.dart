import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../domain/restaurant.dart';
import '../../presentation/providers/restaurant_provider.dart';
import '../../../location/data/location_service.dart';
import 'restaurant_detail_screen.dart';

class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({super.key});

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  late LocationService _locationService;
  bool _locationPermissionDenied = false;
  bool _nearbyOnly = false;

  @override
  void initState() {
    super.initState();
    _locationService = context.read<LocationService>();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    final result = await _locationService.getCurrentLocation();
    if (!mounted) return;

    result.when(
      success: (location) {
        context.read<RestaurantProvider>().setUserLocation(
              latitude: location.latitude,
              longitude: location.longitude,
            );
      },
      denied: (message) {
        setState(() => _locationPermissionDenied = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      },
      unavailable: (message) {
        setState(() => _locationPermissionDenied = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      },
      error: (message) {
        setState(() => _locationPermissionDenied = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.homeTitle),
        elevation: 1,
        actions: [
          IconButton(
            tooltip: 'Resto dalam radius 3 km',
            onPressed: () => setState(() => _nearbyOnly = !_nearbyOnly),
            icon: Icon(
              _nearbyOnly ? Icons.filter_alt : Icons.filter_alt_outlined,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text(
                  AppStrings.login,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<RestaurantProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  onChanged: provider.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: AppStrings.searchRestaurantHint,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              // Location permission warning
              if (_locationPermissionDenied)
                Container(
                  color: AppColors.surfaceMuted,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: AppColors.tertiary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppStrings.locationPermissionDenied,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),

              // Restaurant list
              Expanded(
                child: _buildRestaurantList(context, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRestaurantList(
    BuildContext context,
    RestaurantProvider provider,
  ) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(provider.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.loadRestaurants(),
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      );
    }

    final filteredRestaurants = _nearbyOnly
        ? provider
            .restaurantsWithinRadius(3)
            .where((restaurant) => provider.filteredRestaurants
                .any((item) => item.id == restaurant.id))
            .toList()
        : provider.filteredRestaurants;
    if (filteredRestaurants.isEmpty) {
      return Center(
        child: Text(
          _nearbyOnly && !provider.hasLocationData
              ? 'Lokasi belum tersedia untuk filter radius 3 km'
              : provider.searchQuery.isEmpty
                  ? AppStrings.emptyRestaurantList
                  : AppStrings.noResults,
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredRestaurants.length,
      itemBuilder: (context, index) {
        final restaurant = filteredRestaurants[index];
        return RestaurantCard(
          restaurant: restaurant,
          distance: provider.getDistanceToRestaurant(restaurant),
          onTap: () {
            if (!context.mounted) return;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RestaurantDetailScreen(restaurant: restaurant),
              ),
            );
            provider.loadRestaurantDetail(restaurant.id);
          },
        );
      },
    );
  }
}

/// Card untuk menampilkan restaurant di list.
class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final double? distance;
  final VoidCallback onTap;

  const RestaurantCard({
    required this.restaurant,
    required this.distance,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: restaurant.photoUrl != null
            ? Image.network(
                restaurant.photoUrl!,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.restaurant, size: 40),
              )
            : const Icon(Icons.restaurant, size: 40),
        title: Text(restaurant.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              restaurant.address,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (distance != null)
              Text(
                '${distance!.toStringAsFixed(1)} km',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.distanceNear,
                      fontWeight: FontWeight.bold,
                    ),
              ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
