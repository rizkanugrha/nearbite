import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/restaurant.dart';
import '../../presentation/providers/menu_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../restaurants/presentation/screens/restaurant_list_screen.dart';
import 'owner_profile_screen.dart';
import 'menu_form_screen.dart';

class OwnerMenuScreen extends StatefulWidget {
  const OwnerMenuScreen({super.key});

  @override
  State<OwnerMenuScreen> createState() => _OwnerMenuScreenState();
}

class _OwnerMenuScreenState extends State<OwnerMenuScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load owner data ketika screen dibuka
    Future.microtask(() {
      context.read<MenuProvider>().loadOwnerData();
    });
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.logout),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.actionCancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = context.read<AuthProvider>();
              final menuProvider = context.read<MenuProvider>();
              final navigator = Navigator.of(context);
              await authProvider.logout();
              if (!mounted) return;
              menuProvider.clear();
              navigator.pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const RestaurantListScreen(),
                ),
              );
            },
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.ownerProfile),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: AppStrings.logout,
          ),
        ],
      ),
      body: Consumer<MenuProvider>(
        builder: (context, menuProvider, _) {
          if (menuProvider.isLoading && menuProvider.ownerRestaurant == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return _buildContent(context, menuProvider);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, MenuProvider menuProvider) {
    if (_selectedIndex == 0) {
      return OwnerProfileScreen(
        restaurant: menuProvider.ownerRestaurant,
      );
    } else {
      return _MenuManagementTab(restaurant: menuProvider.ownerRestaurant);
    }
  }
}

class _MenuManagementTab extends StatelessWidget {
  final Restaurant? restaurant;

  const _MenuManagementTab({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    if (restaurant == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.store, size: 64, color: AppColors.surfaceMuted),
              const SizedBox(height: 16),
              Text(
                'Lengkapi profil resto terlebih dahulu',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Consumer<MenuProvider>(
      builder: (context, menuProvider, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text(AppStrings.addMenu),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MenuFormScreen(
                          restaurantId: restaurant!.id,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: menuProvider.menuItems.isEmpty
                  ? const Center(
                      child: Text(AppStrings.noMenuItems),
                    )
                  : ListView.builder(
                      itemCount: menuProvider.menuItems.length,
                      itemBuilder: (context, index) {
                        final item = menuProvider.menuItems[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            title: Text(item.name),
                            subtitle: Text(
                              'Rp${NumberFormat('#,###').format(item.price)}',
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: const Text('Edit'),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => MenuFormScreen(
                                          restaurantId: restaurant!.id,
                                          menuItem: item,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                PopupMenuItem(
                                  child: const Text('Hapus'),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text(
                                          AppStrings.deleteMenu,
                                        ),
                                        content: Text(
                                          'Hapus menu ${item.name}?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text(
                                              AppStrings.actionCancel,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              menuProvider
                                                  .deleteMenuItem(item.id);
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              AppStrings.actionDelete,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
