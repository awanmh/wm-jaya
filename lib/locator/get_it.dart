// lib/locator/get_it.dart
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wm_jaya/data/local_db/database_helper.dart';
import 'package:wm_jaya/data/repositories/auth_repository.dart';
import 'package:wm_jaya/data/repositories/product_repository.dart';
import 'package:wm_jaya/data/repositories/order_repository.dart';
import 'package:wm_jaya/data/repositories/fuel_repository.dart';
import 'package:wm_jaya/data/repositories/report_repository.dart';
import 'package:wm_jaya/services/pdf_service.dart';
import 'package:wm_jaya/services/google_drive_service.dart';
import 'package:wm_jaya/services/qr_service.dart';
import 'package:wm_jaya/features/auth/presentation/providers/auth_provider.dart';
import 'package:wm_jaya/features/product/presentation/providers/product_provider.dart';
import 'package:wm_jaya/features/order/presentation/providers/order_provider.dart';
import 'package:wm_jaya/features/fuel/presentation/providers/fuel_provider.dart';
import 'package:wm_jaya/features/report/presentation/providers/report_provider.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // 🔹 Third-party services
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // 🔹 Database Helper
  getIt.registerLazySingleton<DatabaseHelper>(
    () => DatabaseHelper(),
  );

  // 🔹 Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      getIt<DatabaseHelper>(),
      getIt<FlutterSecureStorage>(),
    ),
  );

  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepository(getIt<DatabaseHelper>()),
  );

  getIt.registerLazySingleton<OrderRepository>(
    () => OrderRepository(getIt<DatabaseHelper>()),
  );

  getIt.registerLazySingleton<FuelRepository>(
    () => FuelRepository(getIt<DatabaseHelper>()),
  );

  getIt.registerLazySingleton<ReportRepository>(
    () => ReportRepository(getIt<DatabaseHelper>()),
  );

  // 🔹 Services
  getIt.registerLazySingleton<PDFService>(() => PDFService());
  getIt.registerLazySingleton<GoogleDriveService>(() => GoogleDriveService());
  getIt.registerLazySingleton<QrService>(() => QrService());

  // 🔹 Providers
  getIt.registerLazySingleton<AuthProvider>(
    () => AuthProvider(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<ProductProvider>(
    () => ProductProvider(getIt<ProductRepository>()),
  );

  getIt.registerLazySingleton<OrderProvider>(
    () => OrderProvider(
      getIt<OrderRepository>(), 
      getIt<ProductRepository>(), // 🔹 Perbaikan: Tambahkan ProductRepository jika memang diperlukan
    ),
  );

  getIt.registerLazySingleton<FuelProvider>(
    () => FuelProvider(getIt<FuelRepository>()),
  );

  getIt.registerLazySingleton<ReportProvider>(
    () => ReportProvider(getIt<ReportRepository>()),
  );
}
