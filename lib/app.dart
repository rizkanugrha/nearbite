import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_strings.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/connectivity_provider.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/restaurants/presentation/screens/restaurant_list_screen.dart';
import 'features/restaurants/presentation/screens/owner_menu_screen.dart';

class NearBiteApp extends StatelessWidget {
  const NearBiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                // Jika sudah login, tampilkan owner menu; jika belum, tampilkan list resto
                if (authProvider.isAuthenticated) {
                  return const OwnerMenuScreen();
                }
                return const RestaurantListScreen();
              },
            ),
      },
      builder: (context, child) {
        return Column(
          children: [
            // Banner koneksi internet - muncul di atas semua halaman
            Consumer<ConnectivityProvider>(
              builder: (context, connectivityProvider, _) {
                if (!connectivityProvider.isConnected) {
                  return Container(
                    width: double.infinity,
                    color: AppColors.error,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.wifi_off,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  AppStrings.noInternetConnection,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  AppStrings.noInternetMessage,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            // Konten utama aplikasi
            Expanded(
              child: child ?? const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}
