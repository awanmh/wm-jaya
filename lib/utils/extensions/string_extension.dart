// lib/utils/extensions/string_extension.dart
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  bool get isValidEmail {
    final emailRegExp = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      caseSensitive: false,
    );
    return emailRegExp.hasMatch(this);
  }

  String get trimExtraSpaces => replaceAll(RegExp(r'\s+'), ' ').trim();
  
  double? get toDouble => double.tryParse(this);
  int? get toInt => int.tryParse(this);
}