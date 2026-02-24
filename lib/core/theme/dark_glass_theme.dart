import 'package:flutter/material.dart';

class DarkGlassTheme {
  static const Color bg = Color(0xFF0B0B0B);
  static const Color surface = Color(0xFF121214);
  static const Color surfaceAlt = Color(0xFF0F0F10);
  static const Color primary = Color(0xFFFF2A2A);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: primary,
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(color: Color(0xFFCFCFD2)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAlt,
        hintStyle: const TextStyle(color: Color(0xFF97979E)),
        labelStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: primary, width: 1.3),
        ),
      ),
    );
  }
}

