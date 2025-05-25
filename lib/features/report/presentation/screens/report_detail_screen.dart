// report_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:wm_jaya/data/models/report.dart';
import 'package:wm_jaya/features/report/presentation/providers/report_provider.dart';
import 'package:wm_jaya/utils/helpers/date_formatter.dart';
import 'package:provider/provider.dart';

class ReportDetailScreen extends StatelessWidget {
  final Report report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Laporan - ${report.type.name.toUpperCase()}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informasi Dasar Laporan
            _buildDetailRow("Jenis Laporan", report.type.name.toUpperCase()),
            _buildDetailRow("Tanggal", DateFormatter.format(report.date)),
            _buildDetailRow("Total Laporan", "Rp ${report.total.toStringAsFixed(0)}"),
            
            const SizedBox(height: 20),
            
            // Total Keseluruhan
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Keseluruhan:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTotalRow("Hari Ini", context.watch<ReportProvider>().todayTotal),
                  _buildTotalRow("Minggu Ini", context.watch<ReportProvider>().weekTotal),
                  _buildTotalRow("Bulan Ini", context.watch<ReportProvider>().monthTotal),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Detail Transaksi
            const Text(
              "Detail Transaksi:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _buildTransactionDetails(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            "Rp ${value.toStringAsFixed(0)}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails() {
    return ListView(
      children: [
        if (report.data['sales'] != null)
          _buildTransactionSection(
            title: "Penjualan",
            icon: Icons.shopping_cart,
            items: report.data['sales']['items'],
          ),
        if (report.data['fuel'] != null)
          _buildTransactionSection(
            title: "Bahan Bakar", 
            icon: Icons.local_gas_station,
            items: report.data['fuel']['items'],
          ),
      ],
    );
  }

  Widget _buildTransactionSection({
    required String title,
    required IconData icon,
    required List<dynamic> items,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...items.map<Widget>((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item['product'] ?? 'Produk Tidak Diketahui'),
                  Text(
                    "${item['quantity']}x Rp ${(item['price'] ?? 0.0).toStringAsFixed(0)}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    "Rp ${(item['quantity'] * item['price']).toStringAsFixed(0)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Laporan"),
        content: const Text("Yakin ingin menghapus laporan ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ReportProvider>().deleteReport(report);
              Navigator.pop(context);
            },
            child: const Text(
              "Hapus",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}