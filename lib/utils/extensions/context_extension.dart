// lib/utils/extensions/context_extension.dart
import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : theme.primaryColor,
      ),
    );
  }

  void pop<T>([T? result]) => Navigator.pop(this, result);
  
  Future<T?> push<T>(Widget page) => Navigator.push(
    this,
    MaterialPageRoute(builder: (_) => page),
  );

  Size get screenSize => MediaQuery.of(this).size;
  EdgeInsets get padding => MediaQuery.of(this).padding;
}