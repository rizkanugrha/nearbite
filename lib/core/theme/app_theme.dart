import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Tema Material 3 aplikasi.
class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.seed);
    return ThemeData(
      colorScheme: scheme.copyWith(error: AppColors.error),
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
    );
  }
}
