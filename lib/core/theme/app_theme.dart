import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const primaryPink = Color(0xFFF5AFC6);
  static const cloudWhite = Color(0xFFFFF4EC);
  static const lavenderButton = Color(0xFFA78BD8);
  static const lcdYellow = Color(0xFFD9D08A);
  static const lcdPixelDark = Color(0xFF32312B);
  static const retroBrown = Color(0xFF7A4E2D);
  static const deskBrown = Color(0xFF9B6A43);
  static const dustGray = Color(0xFF6E6A61);
  static const starPeach = Color(0xFFFFC6A5);
  static const rainbowBlue = Color(0xFF95BFEA);
  static const mintAccent = Color(0xFFBFE8D4);
  static const shadowMauve = Color(0xFF8B6F82);
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryPink,
      primary: AppColors.primaryPink,
      secondary: AppColors.lavenderButton,
      surface: AppColors.cloudWhite,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.cloudWhite,
      fontFamily: 'monospace',
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.retroBrown,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.lavenderButton,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          minimumSize: const Size(48, 48),
        ),
      ),
    );
  }
}
