import 'package:flutter/material.dart';

/// Thème global LikitaEvent (bleu / rouge / fond clair).
class LikitaColors {
  const LikitaColors._();
  static const Color primaryBlue = Color(0xFF0052A5);
  static const Color accentRed = Color(0xFFC0242F);
  static const Color background = Color(0xFFFFF7F0);
  static const Color textDark = Color(0xFF1F2933);
}

ThemeData buildLikitaTheme() {
  const primary = LikitaColors.primaryBlue;
  const secondary = LikitaColors.accentRed;
  final colorScheme = ColorScheme.fromSeed(
    seedColor: primary,
    primary: primary,
    secondary: secondary,
    surface: Colors.white,
    brightness: Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: LikitaColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: secondary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: primary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: LikitaColors.textDark),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: LikitaColors.textDark),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: LikitaColors.textDark),
      bodyLarge: TextStyle(fontSize: 16, color: LikitaColors.textDark),
      bodyMedium: TextStyle(fontSize: 14, color: LikitaColors.textDark),
    ),
  );
}
