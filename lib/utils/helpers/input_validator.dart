// lib/utils/helpers/input_validator.dart
extension EmailValidator on String {
  bool get isValidEmail {
    final emailRegExp = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"
    );
    return emailRegExp.hasMatch(this);
  }
}

class InputValidator {
  /// Validasi field wajib diisi
  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName harus diisi';
    return null;
  }

  /// Validasi username dengan ketentuan:
  /// - Minimal 4 karakter
  /// - Maksimal 20 karakter
  /// - Hanya boleh huruf, angka, dan underscore
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Username harus diisi';
    if (value.length < 4) return 'Username minimal 4 karakter';
    if (value.length > 20) return 'Username maksimal 20 karakter';
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username hanya boleh mengandung huruf, angka, dan underscore';
    }
    return null;
  }

  /// Validasi format email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email harus diisi';
    if (!value.isValidEmail) return 'Format email tidak valid';
    return null;
  }

  /// Validasi password dengan ketentuan:
  /// - Minimal 8 karakter
  /// - Mengandung huruf besar dan kecil
  /// - Mengandung angka
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password harus diisi';
    if (value.length < 8) return 'Password minimal 8 karakter';
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Harus mengandung huruf kapital';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Harus mengandung huruf kecil';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Harus mengandung angka';
    }
    return null;
  }

  /// Validasi nomor telepon Indonesia
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) return 'Nomor HP harus diisi';
    final phoneRegExp = RegExp(r'^(^\+62|62|0)8[1-9][0-9]{6,9}$');
    if (!phoneRegExp.hasMatch(value)) return 'Format nomor HP tidak valid';
    return null;
  }

  /// Validasi format currency (mata uang)
  static String? validateCurrency(String? value) {
    if (value == null || value.isEmpty) return 'Jumlah harus diisi';
    final currencyRegExp = RegExp(r'^(\d{1,3}(?:,\d{3})*|\d+)(\.\d{0,2})?$');
    if (!currencyRegExp.hasMatch(value)) {
      return 'Format jumlah tidak valid (Contoh: 1.000 atau 1.000,50)';
    }
    return null;
  }

  /// Validasi kuantitas (quantity)
  static String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) return 'Jumlah harus diisi';
    final quantityRegExp = RegExp(r'^\d+(\.\d{0,2})?$');
    if (!quantityRegExp.hasMatch(value)) {
      return 'Format jumlah tidak valid (Contoh: 50 atau 50.50)';
    }
    return null;
  }

  static String? validatePrice(String? value){
    if (value == null || value.isEmpty) {
      return 'Kolom ini harus diisi.';
    }
    if (double.tryParse(value) == null) {
      return 'Masukkan angka yang valid.';
    }
    if (double.parse(value) < 0) {
      return 'Harga tidak boleh negatif.';
    }
    return null;
  }

}
