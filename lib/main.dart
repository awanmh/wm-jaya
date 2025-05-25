// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wm_jaya/constants/app_colors.dart';
import 'package:wm_jaya/constants/app_strings.dart';
import 'package:wm_jaya/data/local_db/database_helper.dart';
import 'package:wm_jaya/data/models/user.dart';
import 'package:wm_jaya/locator/get_it.dart';
import 'package:wm_jaya/utils/helpers/security_helper.dart';
import 'package:wm_jaya/utils/theme/app_theme.dart';

// Providers
import 'package:wm_jaya/features/auth/presentation/providers/auth_provider.dart';
import 'package:wm_jaya/features/product/presentation/providers/product_provider.dart';
import 'package:wm_jaya/features/order/presentation/providers/order_provider.dart';
import 'package:wm_jaya/features/fuel/presentation/providers/fuel_provider.dart';
import 'package:wm_jaya/features/report/presentation/providers/report_provider.dart';

// Screens
import 'package:wm_jaya/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:wm_jaya/features/auth/presentation/screens/login_screen.dart';
import 'package:wm_jaya/features/dashboard/presentation/screens/home_screen.dart';
import 'package:wm_jaya/features/product/presentation/screens/product_screen.dart';
import 'package:wm_jaya/features/order/presentation/screens/order_create_screen.dart';
import 'package:wm_jaya/features/fuel/presentation/screens/fuel_purchase_screen.dart';
import 'package:wm_jaya/features/fuel/presentation/screens/fuel_history_screen.dart';
import 'package:wm_jaya/features/report/presentation/screens/report_screen.dart';
import 'package:wm_jaya/features/order/presentation/screens/order_detail_screen.dart';

//repositories
import 'package:wm_jaya/data/repositories/report_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    setupLocator();

    await Future.wait([
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
      _initializeAppDependencies(),
    ]);

    await _createDefaultUser();

    runApp(const WMJayaApp());
  } catch (e, stack) {
    _handleInitializationError(e, stack);
  }
}

class WMJayaApp extends StatelessWidget {
  const WMJayaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DatabaseHelper>(create: (_) => getIt<DatabaseHelper>()), // Tambahkan DatabaseHelper
        Provider<ReportRepository>(create: (context) => ReportRepository(context.read<DatabaseHelper>())), // Tambahkan ReportRepository
        ChangeNotifierProvider.value(value: getIt<AuthProvider>()),
        ChangeNotifierProvider.value(value: getIt<ProductProvider>()),
        ChangeNotifierProvider.value(value: getIt<OrderProvider>()),
        ChangeNotifierProvider.value(value: getIt<FuelProvider>()),
        ChangeNotifierProvider.value(value: getIt<ReportProvider>()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('id', 'ID'), // Bahasa Indonesia
          Locale('en', 'US'), // Bahasa Inggris
        ],
        home: const AuthWrapper(),
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AuthProvider, bool>(
      selector: (_, provider) => provider.isAuthenticated,
      builder: (context, isAuth, _) {
        return FutureBuilder<void>(
          future: _authFuture(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }
            return isAuth ? HomeScreen() : const LoginScreen();
          },
        );
      },
    );
  }

  Future<void> _authFuture(BuildContext context) async {
    try {
      await context.read<AuthProvider>().checkAuthStatus();
    } catch (e) {
      debugPrint('Auth check error: $e');
    }
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
            SizedBox(height: 20),
            Text(
              AppStrings.appName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Route<dynamic> _onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/home':
      return MaterialPageRoute(builder: (_) => HomeScreen());
    case '/login':
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    case '/products':
      return MaterialPageRoute(builder: (_) => const ProductScreen());
    case '/orders':
      return MaterialPageRoute(builder: (_) => const OrderCreateScreen());
    case '/fuel':
      return MaterialPageRoute(builder: (_) => const FuelPurchaseScreen());
    case '/fuel-history':
      return MaterialPageRoute(builder: (_) => const FuelHistoryScreen());
    case '/reports':
      return MaterialPageRoute(builder: (_) => const ReportScreen());
    case '/orderDetail':
      final orderId = settings.arguments as int;
      return MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: orderId));
    case '/reset-password':
      return MaterialPageRoute(builder: (_) => const ResetPasswordScreen());
    default:
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('Halaman tidak ditemukan')),
        ),
      );
  }
}

Future<void> _initializeAppDependencies() async {
  final dbHelper = getIt<DatabaseHelper>();
  await dbHelper.database;
  await getIt.allReady();
}

Future<void> _createDefaultUser() async {
  final dbHelper = getIt<DatabaseHelper>();
  final users = await dbHelper.getUsers();

  if (users.isEmpty) {
    const defaultUsername = 'admin';
    const defaultPassword = 'Admin123';

    final salt = SecurityHelper.generateSalt();
    final passwordHash = SecurityHelper.hashPassword(defaultPassword, salt);

    final defaultUser = User(
      id: 0,
      username: defaultUsername,
      passwordHash: passwordHash,
      salt: salt,
      role: 'admin',
      authToken: null,
      lastLogin: DateTime.now(),
    );

    await dbHelper.insertUser(defaultUser);
  }
}

void _handleInitializationError(Object error, StackTrace stack) {
  debugPrint('Initialization failed: $error\n$stack');
  runApp(const ErrorFallbackApp());
}

class ErrorFallbackApp extends StatelessWidget {
  const ErrorFallbackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 50, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                'Gagal memulai aplikasi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Silakan restart aplikasi',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}