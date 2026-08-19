import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/restaurant.dart';
import '../../presentation/providers/menu_provider.dart';
import '../../../location/data/location_service.dart';

class OwnerProfileScreen extends StatefulWidget {
  final Restaurant? restaurant;

  const OwnerProfileScreen({
    this.restaurant,
    super.key,
  });

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _hoursController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _photoUrlController;

  String? _nameError;
  String? _coordinatesError;
  String? _descriptionError;
  String? _addressError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.restaurant?.name ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.restaurant?.description ?? '',
    );
    _addressController = TextEditingController(
      text: widget.restaurant?.address ?? '',
    );
    _hoursController = TextEditingController(
      text: widget.restaurant?.operationalHours ?? '',
    );
    _latitudeController = TextEditingController(
      text: widget.restaurant != null
          ? widget.restaurant!.latitude.toString()
          : '',
    );
    _longitudeController = TextEditingController(
      text: widget.restaurant != null
          ? widget.restaurant!.longitude.toString()
          : '',
    );
    _photoUrlController = TextEditingController(
      text: widget.restaurant?.photoUrl ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant OwnerProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update controllers ketika restaurant data berubah (setelah save berhasil)
    if (widget.restaurant != oldWidget.restaurant &&
        widget.restaurant != null) {
      _nameController.text = widget.restaurant!.name;
      _descriptionController.text = widget.restaurant!.description;
      _addressController.text = widget.restaurant!.address;
      _hoursController.text = widget.restaurant!.operationalHours;
      _latitudeController.text = widget.restaurant!.latitude.toString();
      _longitudeController.text = widget.restaurant!.longitude.toString();
      _photoUrlController.text = widget.restaurant!.photoUrl ?? '';
      // Clear errors after successful save
      _nameError = null;
      _descriptionError = null;
      _addressError = null;
      _coordinatesError = null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _hoursController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    _nameError = null;
    _coordinatesError = null;
    _descriptionError = null;
    _addressError = null;

    if (_nameController.text.isEmpty || _nameController.text.length < 3) {
      _nameError = AppStrings.restaurantNameRequired;
    }

    if (_latitudeController.text.isEmpty || _longitudeController.text.isEmpty) {
      _coordinatesError = AppStrings.coordinatesRequired;
    } else {
      final lat = double.tryParse(_latitudeController.text);
      final lon = double.tryParse(_longitudeController.text);
      if (lat == null || lon == null) {
        _coordinatesError = 'Koordinat harus berupa angka';
      } else if (lat < -90 || lat > 90) {
        _coordinatesError = 'Latitude harus antara -90 dan 90';
      } else if (lon < -180 || lon > 180) {
        _coordinatesError = 'Longitude harus antara -180 dan 180';
      }
    }

    return _nameError == null &&
        _coordinatesError == null &&
        _descriptionError == null &&
        _addressError == null;
  }

  Future<void> _getUserLocation() async {
    final locationService = context.read<LocationService>();
    final result = await locationService.getCurrentLocation();
    if (!mounted) return;

    result.when(
      success: (location) {
        setState(() {
          _latitudeController.text = location.latitude.toString();
          _longitudeController.text = location.longitude.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lokasi berhasil diambil')),
        );
      },
      denied: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
      unavailable: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
      error: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
    );
  }

  void _handleSave(MenuProvider menuProvider) async {
    if (!_validateForm()) {
      setState(() {});
      return;
    }

    final latitude = double.tryParse(_latitudeController.text) ?? 0;
    final longitude = double.tryParse(_longitudeController.text) ?? 0;

    final restaurant = Restaurant(
      id: widget.restaurant?.id ?? '',
      ownerId: widget.restaurant?.ownerId ??
          '', // Preserve existing owner_id for update
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      address: _addressController.text.trim(),
      operationalHours: _hoursController.text.trim(),
      latitude: latitude,
      longitude: longitude,
      photoUrl: _photoUrlController.text.trim().isEmpty
          ? null
          : _photoUrlController.text.trim(),
      createdAt: widget.restaurant?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await menuProvider.saveRestaurantProfile(restaurant);

    if (!mounted) return;

    if (menuProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(menuProvider.error!)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.savedSuccessfully)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuProvider>(
      builder: (context, menuProvider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name field
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: AppStrings.restaurantName,
                  hintText: AppStrings.restaurantNameHint,
                  errorText: _nameError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.store),
                ),
              ),
              const SizedBox(height: 16),

              // Description field
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: AppStrings.fieldDescription,
                  hintText: AppStrings.restaurantDescriptionHint,
                  errorText: _descriptionError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Address field
              TextField(
                controller: _addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: AppStrings.restaurantAddress2,
                  hintText: AppStrings.restaurantAddressHint,
                  errorText: _addressError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),

              // Hours field
              TextField(
                controller: _hoursController,
                decoration: InputDecoration(
                  labelText: AppStrings.restaurantHours2,
                  hintText: AppStrings.restaurantHoursHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.access_time),
                ),
              ),
              const SizedBox(height: 16),

              // Photo URL field
              TextField(
                controller: _photoUrlController,
                decoration: InputDecoration(
                  labelText: '${AppStrings.restaurantPhoto} (URL)',
                  hintText: 'https://example.com/photo.jpg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.image),
                ),
              ),
              const SizedBox(height: 24),

              // GPS Coordinates section
              Text(
                AppStrings.restaurantCoordinates,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),

              // Latitude
              TextField(
                controller: _latitudeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppStrings.latitude,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorText: _coordinatesError,
                ),
              ),
              const SizedBox(height: 12),

              // Longitude
              TextField(
                controller: _longitudeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppStrings.longitude,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Get current location button
              ElevatedButton.icon(
                icon: const Icon(Icons.gps_fixed),
                label: const Text(AppStrings.useCurrentLocation),
                onPressed: _getUserLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: menuProvider.isLoading
                      ? null
                      : () => _handleSave(menuProvider),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: menuProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(AppStrings.actionSave),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
