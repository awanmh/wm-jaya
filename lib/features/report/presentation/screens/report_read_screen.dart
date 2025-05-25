// lib/features/report/presentation/screens/report_read_screen.dart
import 'package:flutter/material.dart';
import 'package:wm_jaya/data/models/report.dart';
import 'package:wm_jaya/utils/helpers/date_formatter.dart'; // Import DateFormatter

class ReportReadScreen extends StatelessWidget {
  final Report report;

  const ReportReadScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final items = (report.data['items'] as List<dynamic>?) ?? [];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jam Pembelian: ${DateFormatter.format(report.date, pattern: 'dd/MM/yyyy HH:mm')}', // Format tanggal & jam
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Barang yang Dibeli:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final quantity = item['quantity'] as int;
                  final price = item['price'] as double;
                  final total = quantity * price;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.withOpacity(0.2),
                        child: Text(
                          quantity.toString(),
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ),
                      title: Text(
                        item['product'].toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${quantity}x Rp ${price.toStringAsFixed(0)}',
                      ),
                      trailing: Text(
                        'Rp ${total.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Keseluruhan:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Rp ${report.total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}