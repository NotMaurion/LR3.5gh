import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get theme {
    const background = Color(0xFF1A1A2E);
    return ThemeData(
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF10D38F),
        brightness: Brightness.dark,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Colors.white70),
        titleMedium: TextStyle(color: Colors.white),
      ),
      useMaterial3: true,
    );
  }
}


