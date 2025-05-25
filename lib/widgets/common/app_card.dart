// lib/widgets/common/app_card.dart
import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry margin;
  final double elevation;
  final Color? shadowColor;
  final Color? backgroundColor;

  const AppCard({
    required this.child,
    required this.margin,
    this.elevation = 4.0,
    this.shadowColor,
    this.backgroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      elevation: elevation,
      shadowColor: shadowColor ?? Colors.grey[300],
      color: backgroundColor ?? Theme.of(context).cardColor,
      child: child,
    );
  }
}
