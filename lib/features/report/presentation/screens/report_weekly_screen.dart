// lib/features/report/presentation/screens/report_weekly_screen.dart
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

class ReportWeeklyScreen extends StatelessWidget {
  const ReportWeeklyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Widget ini sekarang hanya fokus untuk menampilkan data dari provider
    return Consumer<ReportProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());
        if (provider.errorMessage != null) return Center(child: Text(provider.errorMessage!, style: const TextStyle(color: AppColors.error)));
        if (provider.reports.isEmpty) return const Center(child: Text("Tidak ada laporan untuk rentang minggu ini."));

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
        series: <LineSeries<Map<String, dynamic>, String>>[
          LineSeries<Map<String, dynamic>, String>(
            dataSource: provider.chartData,
            xValueMapper: (data, _) => data['label'],
            yValueMapper: (data, _) => data['value'],
            color: AppColors.primary,
            markerSettings: const MarkerSettings(isVisible: true),
          )
        ],
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context, ReportProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.reports.length,
      itemBuilder: (_, index) => _buildDaySummary(context, provider.reports[index]),
    );
  }

  Widget _buildDaySummary(BuildContext context, Report report) {
    final totalFormatted = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(report.total);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.2),
          child: const Icon(Icons.receipt_long, color: AppColors.primary),
        ),
        title: Text(
          DateFormatter.format(report.date, pattern: 'EEEE, dd MMM'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(totalFormatted),
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
