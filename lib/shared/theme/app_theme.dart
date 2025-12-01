import 'package:flutter/material.dart';

class AppColors {
  // Marca
  static const primary = Color(0xFF1A4E85);
  static const primaryAccent = Color(0xFF4A90E2);

  // Estado
  static const green = Color(0xFF4CAF50);
  static const orange = Color(0xFFFF832A);
  static const red = Color(0xFFF44336);
  static const yellow = Color(0xFFFDD634);

  // Superficies (light)
  static const lightBackground = Colors.white;
  static const lightSurface = Colors.white;
  static const lightSurfaceVariant = Color(0xFFF5F5F5);

  // Superficies (dark)
  static const darkBackground = Color(0xFF0F172A);
  static const darkAppBar      = Color(0xFF0B1220);
  static const darkSurface     = Color(0xFF111827);
  static const darkSurfaceVar  = Color(0xFF1F2937);
}

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.primaryAccent,
      background: AppColors.lightBackground,
      surface: AppColors.lightSurface,
      surfaceVariant: AppColors.lightSurfaceVariant,
      onSurface: Colors.black87,
      onBackground: Colors.black87,
    );
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        titleTextStyle: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
      ),
      cardColor: AppColors.lightSurface,
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceVariant,
        border: OutlineInputBorder(),
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primaryAccent,
      secondary: AppColors.primary,
      background: AppColors.darkBackground,
      surface: AppColors.darkSurface,
      surfaceVariant: AppColors.darkSurfaceVar,
      onSurface: Colors.white,
      onBackground: Colors.white,
    );
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkAppBar,
        elevation: 0,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
      ),
      cardColor: AppColors.darkSurface,
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVar,
        border: OutlineInputBorder(),
      ),
      dividerColor: Colors.white24,
    );
  }
}
