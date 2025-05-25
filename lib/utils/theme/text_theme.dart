// lib/utils/theme/text_theme.dart
import 'package:flutter/material.dart';

class AppTextTheme {
  static TextTheme get textTheme {
    return const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        fontFamily: 'Roboto',
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        fontFamily: 'OpenSans',
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        fontFamily: 'OpenSans',
      ),
    );
  }

  static TextStyle get captionText => const TextStyle(
    fontSize: 12,
    color: Colors.grey,
    fontFamily: 'OpenSans',
  );
}