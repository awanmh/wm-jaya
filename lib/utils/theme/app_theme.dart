// lib/utils/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: Colors.blue.shade800,
      colorScheme: ColorScheme.light(
        primary: Colors.blue.shade800,
        secondary: Colors.blue.shade600,
      ),
      scaffoldBackgroundColor: Colors.white,
      brightness: Brightness.light,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: Colors.blueGrey.shade800,
      colorScheme: ColorScheme.dark(
        primary: Colors.blueGrey.shade800,
        secondary: Colors.blueGrey.shade600,
      ),
      scaffoldBackgroundColor: Colors.grey.shade900,
      brightness: Brightness.dark,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.blueGrey.shade800,
      ),
      textTheme: TextTheme(
        displayLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.grey.shade300,
        ),
      ),
    );
  }
}