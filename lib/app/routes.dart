// lib/app/routes.dart
import 'package:flutter/material.dart';
import 'package:wm_jaya/features/auth/presentation/screens/login_screen.dart';
import 'package:wm_jaya/features/dashboard/presentation/screens/home_screen.dart';
import 'package:wm_jaya/features/fuel/presentation/screens/fuel_purchase_screen.dart';
import 'package:wm_jaya/features/order/presentation/screens/order_create_screen.dart';
import 'package:wm_jaya/features/product/presentation/screens/product_add_screen.dart';
import 'package:wm_jaya/features/product/presentation/screens/product_edit_screen.dart';
import 'package:wm_jaya/features/product/presentation/screens/product_list_screen.dart';
import 'package:wm_jaya/features/report/presentation/screens/report_daily_screen.dart';
import 'package:wm_jaya/features/report/presentation/screens/report_monthly_screen.dart';
import 'package:wm_jaya/features/report/presentation/screens/report_weekly_screen.dart';
import 'package:wm_jaya/features/settings/presentation/screens/app_info_screen.dart';
import 'package:wm_jaya/features/settings/presentation/screens/backup_restore_screen.dart';
import 'package:wm_jaya/features/settings/presentation/screens/settings_main_screen.dart';
import 'package:wm_jaya/features/product/presentation/screens/qr_scanner_screen.dart';


class AppRoutes {
  // Auth Routes
  static const String initial = '/';
  static const String login = '/login';
  
  // Main Routes
  static const String home = '/home';
  
  // Product Routes
  static const String productList = '/products';
  static const String addProduct = '/products/add';
  static const String editProduct = '/products/edit';
  
  // Order Routes
  static const String createOrder = '/orders/create';
  
  // Fuel Routes
  static const String fuelPurchase = '/fuel/purchase';
  
  // Report Routes
  static const String dailyReport = '/reports/daily';
  static const String weeklyReport = '/reports/weekly';
  static const String monthlyReport = '/reports/monthly';
  
  // Settings Routes
  static const String settings = '/settings';
  static const String backupRestore = '/settings/backup';
  static const String appInfo = '/settings/info';

  // Error Route
  static const String notFound = '/404';

  // QR Scanner Route
  static const String qrScanner = '/qr-scanner';

}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      // Auth
      case AppRoutes.initial:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      // Main
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      
      // Product
      case AppRoutes.productList:
        final category = settings.arguments as String? ?? 'Semua';
      return MaterialPageRoute(
        builder: (_) => ProductListScreen(category: category),
      );

      // QR code
      case AppRoutes.qrScanner:
        return MaterialPageRoute(
          builder: (_) => const QRScannerScreen(),
          fullscreenDialog: true // Untuk tampilan fullscreen
      );

      case AppRoutes.addProduct:
        return MaterialPageRoute(builder: (_) => const ProductAddScreen());
      case AppRoutes.editProduct:
        if (args is String) {
          final productId = int.tryParse(args) ?? 0;
           return MaterialPageRoute(
            builder: (_) => ProductEditScreen(productId: productId), 
          );
        }
        return _errorRoute();
      
      // Order
      case AppRoutes.createOrder:
        return MaterialPageRoute(builder: (_) => const OrderCreateScreen());
      
      // Fuel
      case AppRoutes.fuelPurchase:
        return MaterialPageRoute(builder: (_) => const FuelPurchaseScreen());
      
      // Report
      case AppRoutes.dailyReport:
        return MaterialPageRoute(builder: (_) => const ReportDailyScreen());
      case AppRoutes.weeklyReport:
        return MaterialPageRoute(builder: (_) => const ReportWeeklyScreen());
      case AppRoutes.monthlyReport:
        return MaterialPageRoute(builder: (_) => const ReportMonthlyScreen());
      
      // Settings
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsMainScreen());
      case AppRoutes.backupRestore:
        return MaterialPageRoute(builder: (_) => const BackupRestoreScreen());
      case AppRoutes.appInfo:
        return MaterialPageRoute(builder: (_) => const AppInfoScreen());
      
      // Error
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Halaman tidak ditemukan')),
      );
    });
  }
}