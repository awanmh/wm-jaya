import 'package:flutter/material.dart';
import 'package:wm_jaya/app/routes.dart';
import 'package:wm_jaya/utils/theme/app_theme.dart';

class WMJayaApp extends StatelessWidget {
  const WMJayaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WM Jaya',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.initial,
      onGenerateRoute: RouteGenerator.generateRoute,
      builder: (context, child) {
        // Global configuration for text scaling and error handling
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: Banner(
            message: 'Development',
            location: BannerLocation.topEnd,
            color: Colors.red,
            child: child!,
          ),
        );
      },
    );
  }
}