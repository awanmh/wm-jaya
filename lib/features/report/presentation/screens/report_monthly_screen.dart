// lib/features/report/presentation/screens/report_monthly_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:wm_jaya/constants/app_colors.dart';
import 'package:wm_jaya/data/models/report.dart';
import 'package:wm_jaya/features/report/presentation/providers/report_provider.dart';
import 'package:wm_jaya/features/report/presentation/screens/report_detail_screen.dart';
import 'package:wm_jaya/utils/helpers/date_formatter.dart';
import 'package:wm_jaya/widgets/common/app_card.dart';

class ReportMonthlyScreen extends StatelessWidget {
  const ReportMonthlyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Widget ini sekarang hanya fokus untuk menampilkan data dari provider
    return Consumer<ReportProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());
        if (provider.errorMessage != null) return Center(child: Text(provider.errorMessage!, style: const TextStyle(color: AppColors.error)));
        if (provider.reports.isEmpty) return const Center(child: Text("Tidak ada laporan untuk bulan ini."));

        return Column(
          children: [
            _buildChart(provider),
            Expanded(child: _buildTransactionList(context, provider)),
          ],
        );
      },
    );
  }

  Widget _buildChart(ReportProvider provider) {
    if (provider.chartData.isEmpty) return const SizedBox.shrink();
    return AppCard(
      margin: const EdgeInsets.all(16),
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        series: <ColumnSeries<Map<String, dynamic>, String>>[
          ColumnSeries<Map<String, dynamic>, String>(
            dataSource: provider.chartData,
            xValueMapper: (data, _) => data['label'],
            yValueMapper: (data, _) => data['value'],
            color: AppColors.primary,
          )
        ],
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context, ReportProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.reports.length,
      itemBuilder: (ctx, index) => _buildTransactionItem(context, provider.reports[index]),
    );
  }

  Widget _buildTransactionItem(BuildContext context, Report report) {
    final totalFormatted = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(report.total);
    // Asumsi laporan bulanan dikelompokkan per minggu atau tanggal
    final title = DateFormatter.format(report.date, pattern: 'dd MMM yyyy'); 

    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text('Laporan untuk: $title', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Total: $totalFormatted'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ReportDetailScreen(summaryReport: report)),
          );
        },
      ),
    );
  }
}
