import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/menu_item.dart';
import '../../presentation/providers/menu_provider.dart';

class MenuFormScreen extends StatefulWidget {
  final String restaurantId;
  final MenuItem? menuItem;

  const MenuFormScreen({
    required this.restaurantId,
    this.menuItem,
    super.key,
  });

  @override
  State<MenuFormScreen> createState() => _MenuFormScreenState();
}

class _MenuFormScreenState extends State<MenuFormScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _photoUrlController;

  String? _nameError;
  String? _priceError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.menuItem?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.menuItem?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.menuItem?.price.toString() ?? '',
    );
    _photoUrlController = TextEditingController(
      text: widget.menuItem?.photoUrl ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    _nameError = null;
    _priceError = null;

    if (_nameController.text.isEmpty) {
      _nameError = AppStrings.menuNameRequired;
    }

    if (_priceController.text.isEmpty) {
      _priceError = AppStrings.menuPriceRequired;
    } else {
      try {
        final price = int.parse(_priceController.text);
        if (price < 0) {
          _priceError = AppStrings.menuPriceInvalid;
        }
      } catch (e) {
        _priceError = AppStrings.menuPriceInvalid;
      }
    }

    return _nameError == null && _priceError == null;
  }

  void _handleSave(MenuProvider menuProvider) async {
    if (!_validateForm()) {
      setState(() {});
      return;
    }

    final price = int.parse(_priceController.text);
    final now = DateTime.now();

    final menuItem = MenuItem(
      id: widget.menuItem?.id ?? '',
      restaurantId: widget.restaurantId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: price,
      photoUrl: _photoUrlController.text.trim().isEmpty
          ? null
          : _photoUrlController.text.trim(),
      createdAt: widget.menuItem?.createdAt ?? now,
    );

    if (widget.menuItem == null) {
      await menuProvider.addMenuItem(menuItem);
    } else {
      await menuProvider.updateMenuItem(menuItem);
    }

    if (!mounted) return;

    if (menuProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(menuProvider.error!)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.menuItem == null
                ? AppStrings.menuAddedSuccessfully
                : AppStrings.menuUpdatedSuccessfully,
          ),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.menuItem == null ? AppStrings.addMenu : AppStrings.editMenu,
        ),
      ),
      body: Consumer<MenuProvider>(
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
                    labelText: AppStrings.menuName,
                    hintText: AppStrings.menuNameHint,
                    errorText: _nameError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.restaurant_menu),
                  ),
                ),
                const SizedBox(height: 16),

                // Description field
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: AppStrings.menuDescription2,
                    hintText: AppStrings.menuDescriptionHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Price field
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: AppStrings.menuPrice,
                    hintText: AppStrings.menuPriceHint,
                    errorText: _priceError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                ),
                const SizedBox(height: 16),

                // Photo URL field
                TextField(
                  controller: _photoUrlController,
                  decoration: InputDecoration(
                    labelText: 'URL Foto Menu (opsional)',
                    hintText: 'https://example.com/image.jpg',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.image),
                  ),
                ),
                const SizedBox(height: 24),

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
      ),
    );
  }
}
