// lib/features/report/presentation/screens/app_info_screen.dart
import 'package:flutter/material.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: FlutterLogo(size: 100),
            ),
            const SizedBox(height: 20),
            const Text(
              'App Name',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Version: 1.0.0 (1234)',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Text(
              'Developed by:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('Your Company Name'),
            const SizedBox(height: 20),
            const Text(
              'Description:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'A wonderful application that helps you manage your daily tasks and activities.',
            ),
            const Spacer(),
            const AboutListTile(
              icon: Icon(Icons.info),
              applicationName: 'Your App Name',
              applicationVersion: '1.0.0',
              applicationLegalese: '© 2024 Your Company',
              child: Text('About this app'),
            ),
          ],
        ),
      ),
    );
  }
}