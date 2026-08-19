import 'package:flutter/material.dart';

/// Warna aplikasi NearBite - Resto Terdekat.
class AppColors {
  const AppColors._();

  // Warna brand kuliner - Orange/Amber (makanan, hangat, appetizing)
  static const Color seed = Color(0xFFFF6B35);

  static const Color primary = seed;
  static const Color onPrimary = Colors.white;
  static const Color secondary = Color(0xFFFF8C42);
  static const Color tertiary = Color(0xFFFFA500);

  // Status untuk rating/prioritas menu
  static const Color ratingExcellent = Color(0xFF4CAF50);
  static const Color ratingGood = Color(0xFF8BC34A);
  static const Color ratingOk = Color(0xFFFFC107);
  static const Color ratingPoor = Color(0xFFFF5722);

  // Status perjalanan/jarak
  static const Color distanceNear = Color(0xFF4CAF50); // Hijau - dekat
  static const Color distanceFar = Color(0xFFFF9800); // Orange - jauh

  // UI States
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color surfaceMuted = Color(0xFFF5F5F5);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF4CAF50);
}
