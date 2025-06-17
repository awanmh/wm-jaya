import 'package:flutter/material.dart';
import 'package:wm_jaya/constants/app_colors.dart';

class BackupRestoreScreen extends StatelessWidget {
  const BackupRestoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text('Backup & Restore'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Backup Data'),
              onPressed: () {
                // Tambahkan logika backup di sini
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Backup initiated...'),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.cloud_download),
              label: const Text('Restore Data'),
              onPressed: () {
                // Tambahkan logika restore di sini
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Restore initiated...'),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Note: Backup data will be stored in your cloud storage associated with this account',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}