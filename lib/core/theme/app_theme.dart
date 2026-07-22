import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Matches the web app's brand gradient (emerald -> sky), see
/// resources/views/layouts/app.blade.php `.gradient-text` / `.gradient-bg`.
class AppColors {
  AppColors._();

  static const primary = Color(0xFF059669); // emerald-600
  static const primaryDark = Color(0xFF047857); // emerald-700
  static const secondary = Color(0xFF0EA5E9); // sky-500
  static const background = Color(0xFFF9FAFB); // gray-50
}

class AppTheme {
  AppTheme._();

  /// [isArabic] picks the same font pairing the web app uses per-locale
  /// (Cairo for Arabic, Inter for English) — see layouts/app.blade.php.
  static ThemeData light({required bool isArabic}) {
    final textTheme = isArabic
        ? GoogleFonts.cairoTextTheme()
        : GoogleFonts.interTextTheme();

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
