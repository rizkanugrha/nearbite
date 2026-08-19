import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/restaurant.dart';
import '../../presentation/providers/restaurant_provider.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({
    required this.restaurant,
    super.key,
  });

  void _showImageDialog(
      BuildContext context, String imageUrl, String menuName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    width: 300,
                    height: 300,
                    color: AppColors.surfaceMuted,
                    child: const Icon(Icons.broken_image, size: 80),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.detailTitle),
      ),
      body: Consumer<RestaurantProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant photo
                if (restaurant.photoUrl != null)
                  GestureDetector(
                    onTap: () => _showImageDialog(
                        context, restaurant.photoUrl!, restaurant.name),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Image.network(
                          restaurant.photoUrl!,
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: double.infinity,
                            height: 300,
                            color: AppColors.surfaceMuted,
                            child: const Icon(Icons.restaurant, size: 100),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.zoom_in,
                              color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),

                // Restaurant info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        restaurant.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),

                      // Description
                      if (restaurant.description.isNotEmpty)
                        Text(
                          restaurant.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      const SizedBox(height: 16),

                      // Address
                      _InfoRow(
                        icon: Icons.location_on,
                        title: AppStrings.restaurantAddress,
                        value: restaurant.address,
                      ),
                      const SizedBox(height: 12),

                      // Hours
                      _InfoRow(
                        icon: Icons.access_time,
                        title: AppStrings.restaurantHours,
                        value: restaurant.operationalHours,
                      ),
                      const SizedBox(height: 12),

                      // Coordinates
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        title: 'Koordinat GPS',
                        value:
                            '${restaurant.latitude.toStringAsFixed(4)}, ${restaurant.longitude.toStringAsFixed(4)}',
                      ),
                    ],
                  ),
                ),

                // Menu section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    AppStrings.restaurantMenu,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    onChanged: provider.setMenuSearchQuery,
                    decoration: const InputDecoration(
                      hintText: 'Cari menu',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                if (provider.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  )
                else if (provider.error != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(provider.error!),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () =>
                              provider.loadRestaurantDetail(restaurant.id),
                          child: const Text(AppStrings.retry),
                        ),
                      ],
                    ),
                  )
                else if (provider.menuSearchQuery.isNotEmpty &&
                    provider.filteredMenuItems.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text('Menu tidak ditemukan untuk pencarian ini.'),
                    ),
                  )
                else if (provider.menuItems.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      AppStrings.noMenuAvailable,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: provider
                          .menuItemsSortedByPrice()
                          .where((menu) => provider.filteredMenuItems
                              .any((filtered) => filtered.id == menu.id))
                          .map((menu) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: menu.photoUrl != null
                                ? () => _showImageDialog(
                                    context, menu.photoUrl!, menu.name)
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Menu photo
                                  if (menu.photoUrl != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        menu.photoUrl!,
                                        width: double.infinity,
                                        height: 150,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: double.infinity,
                                          height: 150,
                                          color: AppColors.surfaceMuted,
                                          child: const Icon(
                                              Icons.restaurant_menu,
                                              size: 50),
                                        ),
                                      ),
                                    ),
                                  if (menu.photoUrl != null)
                                    const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          menu.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      Text(
                                        'Rp${NumberFormat('#,###').format(menu.price)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                  if (menu.description.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        menu.description,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
