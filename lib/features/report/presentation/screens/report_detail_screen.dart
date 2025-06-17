// lib/features/report/presentation/screens/report_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:wm_jaya/constants/app_colors.dart';
import 'package:wm_jaya/data/models/report.dart';
import 'package:wm_jaya/features/report/presentation/providers/report_provider.dart';
import 'package:wm_jaya/utils/helpers/date_formatter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// 1. Ubah menjadi StatefulWidget
class ReportDetailScreen extends StatefulWidget {
  // Terima objek Report ringkasan, terutama untuk ID dan info header
  final Report summaryReport;

  const ReportDetailScreen({super.key, required this.summaryReport});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  // 2. Tambahkan state untuk loading dan data detail
  bool _isLoading = true;
  String? _errorMessage;
  Report? _detailedReport;

  @override
  void initState() {
    super.initState();
    // 3. Panggil fungsi untuk mengambil data detail saat layar dibuka
    _fetchReportDetails();
  }

  /// PENTING: Anda perlu membuat fungsi ini di dalam ReportProvider Anda.
  /// Fungsi ini harus mengambil ID laporan, melakukan query ke database
  /// untuk mendapatkan SEMUA detail (termasuk item penjualan/BBM),
  /// dan mengembalikan objek Report yang lengkap.
  // Letakkan ini di dalam file report_detail_screen.dart
Future<void> _fetchReportDetails() async {
  final reportId = widget.summaryReport.id;

  // 1. Tambahkan pengecekan null di sini
  if (reportId == null) {
    if (mounted) {
      setState(() {
        _errorMessage = "Gagal memuat rincian: ID laporan tidak valid.";
        _isLoading = false;
      });
    }
    return; // Hentikan fungsi jika ID null
  }

  try {
    // 2. Sekarang 'reportId' dijamin tidak null
    final reportDetails = await context
        .read<ReportProvider>()
        .getReportDetails(reportId); // <-- Aman untuk dipanggil

    if (mounted) {
      setState(() {
        _detailedReport = reportDetails;
        _isLoading = false;
      });
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _errorMessage = "Gagal memuat rincian: $e";
        _isLoading = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    // Gunakan info dari summary untuk AppBar agar tidak kosong saat loading
    final reportForHeader = _detailedReport ?? widget.summaryReport;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.tertiary,
        title: Text(
          _getAppBarTitle(reportForHeader), // Kirim report ke helper
          style: const TextStyle(
            color: AppColors.tertiary,
            fontSize: 20,
            fontWeight: FontWeight.bold
          ),
        ),

        actions: [
          // Hanya tampilkan tombol hapus jika data sudah dimuat & berhasil
          if (!_isLoading && _detailedReport != null)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Hapus Laporan',
              onPressed: () => _confirmDelete(context, _detailedReport!),
            ),
        ],
      ),
      // 4. Tampilkan UI berdasarkan state
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(_errorMessage!, textAlign: TextAlign.center),
      ));
    }
    
    if (_detailedReport == null) {
        return const Center(child: Text("Data laporan tidak dapat ditemukan."));
    }

    // Jika sudah tidak loading dan tidak ada error, tampilkan detail
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView( 
        children: [
          _buildSummaryCard(_detailedReport!),
          const SizedBox(height: 20),
          const Text("Rincian Transaksi:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildTransactionDetails(_detailedReport!),
        ],
      ),
    );
  }

  // --- Helper Methods ---

  String _getAppBarTitle(Report report) {
    switch (report.type) {
      case ReportType.daily:
        return 'Detail Harian: ${DateFormatter.format(report.date, pattern: 'dd MMMM yyyy')}';
      case ReportType.weekly:
        final start = report.date;
        final end = report.date.add(const Duration(days: 6));
        return 'Detail Mingguan: ${DateFormatter.format(start, pattern: 'd MMM')} - ${DateFormatter.format(end, pattern: 'd MMM yyyy')}';
      case ReportType.monthly:
        return 'Detail Bulanan: ${DateFormatter.format(report.date, pattern: 'MMMM yyyy')}';
    }
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(value);
  }

  Widget _buildSummaryCard(Report report) {
     return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Ringkasan Laporan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            const SizedBox(height: 8),
            _buildDetailRow("Jenis Laporan", report.type.name.toUpperCase()),
            _buildDetailRow("Periode", DateFormatter.format(report.date, pattern: 'EEEE, dd MMMM yyyy')),
            _buildDetailRow("Total Laporan", _formatCurrency(report.total)),
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
          Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails(Report report) {
    bool hasSales = report.data.containsKey('sales') && (report.data['sales']['items'] as List).isNotEmpty;
    bool hasFuel = report.data.containsKey('fuel') && (report.data['fuel']['items'] as List).isNotEmpty;

    if (!hasSales && !hasFuel) {
      return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text("Tidak ada rincian transaksi.")));
    }
    
    return Column(
      children: [
        if (hasSales)
          _buildTransactionSection(title: "Penjualan", icon: Icons.shopping_cart, items: report.data['sales']['items']),
        if (hasFuel)
          _buildTransactionSection(title: "Bahan Bakar", icon: Icons.local_gas_station, items: report.data['fuel']['items']),
      ],
    );
  }

  Widget _buildTransactionSection({ required String title, required IconData icon, required List<dynamic>? items}) {
    if (items == null || items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        initiallyExpanded: true,
        children: items.map<Widget>((item) {
          final quantity = item['quantity'] ?? 0;
          final price = (item['price'] as num?)?.toDouble() ?? 0.0;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(flex: 3, child: Text(item['product']?.toString() ?? 'N/A', style: const TextStyle(fontSize: 14))),
                Expanded(flex: 2, child: Text("${quantity}x ${_formatCurrency(price)}", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 14))),
                Expanded(flex: 2, child: Text(_formatCurrency(quantity * price), textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Report reportToDelete) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Laporan"),
        content: const Text("Yakin ingin menghapus laporan ini? Tindakan ini tidak dapat diurungkan."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ReportProvider>().deleteReport(reportToDelete).then((_) {
                 Navigator.pop(context);
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Laporan berhasil dihapus."), backgroundColor: Colors.green));
              }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal menghapus laporan: $error"), backgroundColor: Colors.red));
              });
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
