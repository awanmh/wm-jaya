// lib/features/report/presentation/screens/report_weekly_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:wm_jaya/constants/app_colors.dart';
import 'package:wm_jaya/data/models/report.dart';
import 'package:wm_jaya/features/report/presentation/providers/report_provider.dart';
import 'package:wm_jaya/utils/helpers/date_formatter.dart';
import 'package:wm_jaya/widgets/common/app_card.dart';

class ReportWeeklyScreen extends StatefulWidget {
  const ReportWeeklyScreen({super.key});

  @override
  ReportWeeklyScreenState createState() => ReportWeeklyScreenState();
}

class ReportWeeklyScreenState extends State<ReportWeeklyScreen> {
  late DateTimeRange _selectedWeek;

  @override
  void initState() {
    super.initState();
    _selectedWeek = DateFormatter.currentWeek();
    _loadData();
  }

  void _loadData() {
    final provider = context.read<ReportProvider>();
    provider.setReportType(ReportType.weekly); // ✅ Pastikan ReportType dikenali
    provider.updateDateRange(_selectedWeek);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormatter.formatWeeklyHeader(_selectedWeek)),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _selectWeek,
          ),
        ],
      ),
      body: Consumer<ReportProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return _buildLoading();
          if (provider.errorMessage != null) return _buildError(provider);
          return Column(
            children: [
              _buildChart(provider),
              Expanded(child: _buildTransactionList(provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError(ReportProvider provider) {
    return Center(
      child: Text(
        provider.errorMessage ?? "Terjadi kesalahan.",
        style: const TextStyle(color: AppColors.error),
      ),
    );
  }

  Widget _buildChart(ReportProvider provider) {
    return AppCard(
      margin: const EdgeInsets.all(16), // ✅ Pastikan margin ada
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        series: <LineSeries<dynamic, dynamic>>[ // ✅ Perbaikan tipe data agar lebih fleksibel
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

  Widget _buildTransactionList(ReportProvider provider) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.reports.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) => _buildDaySummary(provider.reports[index]),
    );
  }

  Widget _buildDaySummary(Report report) {
  return AppCard(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.2),
        child: const Icon(Icons.receipt_long, color: AppColors.primary),
      ),
      title: Text(
        DateFormatter.format(report.period, pattern: 'EEEE, dd MMM yyyy'),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Rp ${report.total.toStringAsFixed(0)}', // Asumsi total tidak null
      ),
    ),
  );
}

  Future<void> _selectWeek() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedWeek.start,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'), // ✅ Format Indonesia
    );

    if (picked != null) {
      setState(() {
        _selectedWeek = DateFormatter.getWeekRange(picked);
      });
      _loadData();
    }
  }
}
