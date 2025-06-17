// lib/features/fuel/presentation/screens/fuel_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wm_jaya/constants/app_colors.dart';
import 'package:wm_jaya/data/local_db/database_helper.dart';
import 'package:wm_jaya/utils/helpers/date_formatter.dart';
import 'package:wm_jaya/widgets/common/app_card.dart';

class FuelHistoryScreen extends StatelessWidget {
  const FuelHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dbHelper = Provider.of<DatabaseHelper>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pengisian Bahan Bakar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DatabaseHelper>().getFuelPurchases(),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: dbHelper.getFuelPurchases(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada riwayat pengisian'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) =>
                _buildFuelItem(snapshot.data![index]),
          );
        },
      ),
    );
  }

  Widget _buildFuelItem(Map<String, dynamic> purchase) {
    final date = DateTime.fromMillisecondsSinceEpoch(purchase['date']);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  purchase['type'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    backgroundColor: AppColors.primary,
                  ),
                ),
                Text(
                  DateFormatter.format(date, pattern: 'dd MMM yyyy HH:mm'),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Harga per Liter',
                'Rp ${purchase['price'].toStringAsFixed(0)}'),
            _buildDetailRow(
                'Jumlah Liter', '${purchase['liters'].toStringAsFixed(2)} L'),
            _buildDetailRow('Total Biaya',
                'Rp ${(purchase['price'] * purchase['liters']).toStringAsFixed(0)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
