// lib/di/injector.dart
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
import 'package:wm_jaya/providers/fuel_provider.dart';
import 'package:wm_jaya/providers/auth_provider.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Third-party services
  getIt.registerLazySingleton(() => const FlutterSecureStorage());

  // Database
  getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<DatabaseHelper>(), getIt<FlutterSecureStorage>()),
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

  // Services
  getIt.registerLazySingleton<PDFService>(() => PDFService());
  getIt.registerLazySingleton<GoogleDriveService>(() => GoogleDriveService());
  getIt.registerLazySingleton<QrService>(() => QrService());

  // Providers (State Management)
  getIt.registerLazySingleton<AuthProvider>(
  () => AuthProvider(getIt<AuthRepository>()),
  );


  getIt.registerLazySingleton<FuelProvider>(
    () => FuelProvider(getIt<FuelRepository>()),
  );
}