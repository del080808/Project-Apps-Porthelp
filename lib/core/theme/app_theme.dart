import 'package:flutter/material.dart';

class AppPalette {
  static const Color primary = Color(0xFF1A237E);
  static const Color secondary = Color(0xFF3949AB);
  static const Color tertiary = Color(0xFF611E00);
  static const Color error = Color(0xFFBA1A1A);
  static const Color background = Color(0xFFF5F7FA);
  static const Color backgroundAlt = Color(0xFFF3F4F6);
  static const Color surface = Colors.white;
  static const Color mutedSurface = Color(0xFFF1F4FA);
  static const Color surfaceContainerLow = Color(0xFFF4F2FC);
  static const Color surfaceContainerHigh = Color(0xFFE8E7F1);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE3E8F0);
  static const Color outline = Color(0xFF757684);
  static const Color outlineVariant = Color(0xFFC4C5D5);

  static const Color textOnSurface = Color(0xFF1A1B22);
  static const Color textOnSurfaceVariant = Color(0xFF444653);
  static const Color mutedText = Color(0xFF6B7280);
  static const Color hintText = Color(0xFF9CA3AF);

  static const Color navyDark = Color(0xFF1A3461);
  static const Color navyLight = Color(0xFF2751A3);
  static const Color pageBg = Color(0xFFF2F4F8);
  static const Color inputBg = Color(0xFFF0F3FA);
  static const Color textPri = Color(0xFF1A2B4A);
  static const Color textSec = Color(0xFF6B7A99);
  static const Color textHint = Color(0xFFADB8CF);

  static const Color amber = Color(0xFFB45309);
  static const Color green = Color(0xFF166534);
  static const Color muted = Color(0xFF6B7280);
  static const Color hint = Color(0xFF9CA3AF);
  static const Color surfaceVar = Color(0xFFEEF2FF);
  static const Color outlineLight = Color(0xFFD1C9E8);
  static const Color tagRed = Color(0xFFFFEDEC);
  static const Color tagBlue = Color(0xFFEEF2FF);
  static const Color tagAmber = Color(0xFFFFF8E7);
  static const Color commentGreen = Color(0xFFE8F5E9);
  static const Color commentBlue = Color(0xFFEEF2FF);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppPalette.primary,
        brightness: Brightness.light,
      ),
      useMaterial3: true, // ← pindah ke sini, bukan di copyWith
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppPalette.background,
      colorScheme: base.colorScheme.copyWith(
        primary: AppPalette.primary,
        secondary: AppPalette.secondary,
        surface: AppPalette.surface,
        // background dihapus → sudah deprecated sejak v3.18, pakai surface
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppPalette.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AppPalette.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AppPalette.primary,
        unselectedItemColor: AppPalette.textSecondary,
        backgroundColor: AppPalette.surface,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.primary, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPalette.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppPalette.primary),
      ),
    );
  }
}
