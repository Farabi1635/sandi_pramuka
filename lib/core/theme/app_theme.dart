import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.green,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.green,
      onPrimary: AppColors.white,
      secondary: AppColors.army,
      onSecondary: AppColors.white,
      tertiary: AppColors.brown,
      surface: AppColors.cream,
      onSurface: AppColors.greenDark,
    );
    return _base(scheme);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.army,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFF8FB08A),
      secondary: AppColors.army,
      tertiary: const Color(0xFFC4A57B),
      surface: const Color(0xFF111A15),
    );
    return _base(scheme);
  }

  static ThemeData _base(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: scheme.primary.withAlpha(40),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
