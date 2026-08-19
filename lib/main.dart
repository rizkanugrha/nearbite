import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';

// Auth
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/data/auth_local_storage.dart';
import 'features/auth/data/remote/auth_api_client.dart';

// Restaurants
import 'features/restaurants/presentation/providers/restaurant_provider.dart';
import 'features/restaurants/presentation/providers/menu_provider.dart';
import 'features/restaurants/data/remote/restaurant_api_client.dart';

// Location
import 'features/location/data/location_service.dart';

// Connectivity
import 'core/providers/connectivity_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup shared preferences untuk local storage
  final prefs = await SharedPreferences.getInstance();

  const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://gjrmykvmlfagizfpppmy.supabase.co',
  );
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  const restApiUrl = '$supabaseUrl/rest/v1';

  runApp(
    MultiProvider(
      providers: [
        // Auth layer
        Provider<AuthLocalStorage>(
          create: (_) => AuthLocalStorage(prefs),
        ),
        Provider<AuthApiClient>(
          create: (context) => AuthApiClient(
            baseUrl: supabaseUrl,
            apiKey: supabaseAnonKey,
            httpClient: http.Client(),
            localStorage: context.read<AuthLocalStorage>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            authApiClient: context.read<AuthApiClient>(),
            localStorage: context.read<AuthLocalStorage>(),
          ),
        ),

        // Restaurant layer
        Provider<RestaurantApiClient>(
          create: (context) => RestaurantApiClient(
            baseUrl: restApiUrl,
            apiKey: supabaseAnonKey,
            httpClient: http.Client(),
            localStorage: context.read<AuthLocalStorage>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => RestaurantProvider(
            restaurantApiClient: context.read<RestaurantApiClient>(),
          )..loadRestaurants(),
        ),
        ChangeNotifierProvider(
          create: (context) => MenuProvider(
            restaurantApiClient: context.read<RestaurantApiClient>(),
          ),
        ),

        // Location service
        Provider<LocationService>(
          create: (_) => GeolocatorLocationService(),
        ),

        // Connectivity monitoring
        ChangeNotifierProvider(
          create: (_) => ConnectivityProvider()..initialize(),
        ),
      ],
      child: const NearBiteApp(),
    ),
  );
}
