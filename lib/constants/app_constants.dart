class AppConstants {
  // Layout Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double buttonHeight = 48.0;

  // Animation
  static const Duration animationShort = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 350);

  // API Constants
  static const int apiTimeout = 30; // dalam detik

  // Database
  static const int dbVersion = 7;
  static const int dbPageLimit = 20;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxProductNameLength = 50;

  // QR Code
  static const double qrScannerSize = 250.0;
  static const String qrPrefix = "WMJ-";

  // Receipt
  static const String receiptFooter = "Terima kasih telah berbelanja";
}
