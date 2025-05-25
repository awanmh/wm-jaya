// lib/features/report/presentation/screens/report_monthly_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:wm_jaya/constants/app_colors.dart';
import 'package:wm_jaya/data/models/report.dart'; // ✅ Import untuk ReportType
import 'package:wm_jaya/features/report/presentation/providers/report_provider.dart';
import 'package:wm_jaya/utils/helpers/date_formatter.dart';
import 'package:wm_jaya/widgets/common/app_card.dart';

class ReportMonthlyScreen extends StatefulWidget {
  const ReportMonthlyScreen({super.key});

  @override
  ReportMonthlyScreenState createState() => ReportMonthlyScreenState(); // ✅ Perbaiki nama
}

class ReportMonthlyScreenState extends State<ReportMonthlyScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    _loadData();
  }

  void _loadData() {
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0); // ✅ Perbaikan lastDay

    final provider = context.read<ReportProvider>();
    provider.setReportType(ReportType.monthly); // ✅ Tidak error
    provider.updateDateRange(DateTimeRange(start: firstDay, end: lastDay));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormatter.format(_selectedMonth, pattern: 'MMMM yyyy')),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectMonth,
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
        provider.errorMessage!,
        style: const TextStyle(color: AppColors.error),
      ),
    );
  }

  Widget _buildChart(ReportProvider provider) {
    return AppCard(
      margin: const EdgeInsets.all(16), // ✅ Parameter wajib diisi
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        series: <CartesianSeries<dynamic, dynamic>>[ // ✅ Perbaikan tipe
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

  Widget _buildTransactionList(ReportProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.reports.length,
      itemBuilder: (ctx, index) => _buildTransactionItem(provider.reports[index]),
    );
  }

  Widget _buildTransactionItem(Report report) {
  return AppCard(
    margin: const EdgeInsets.only(bottom: 16), // ✅ Parameter wajib diisi
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          report.type.toString().toUpperCase(),
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Total: Rp ${_formatTotal(report.data['total'])}',
        ),
        Text(
          'Waktu: ${DateFormatter.formatTime(report.createdAt)}',
        ),
      ],
    ),
  );
}

String _formatTotal(dynamic total) {
  if (total is num) {
    return total.toStringAsFixed(0);
  }
  return '0'; // Nilai default jika `total` tidak valid
}


  Future<void> _selectMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'), // ✅ Format Indonesia
    );

    if (picked != null && picked != _selectedMonth) {
      setState(() => _selectedMonth = DateTime(picked.year, picked.month, 1));
      _loadData();
    }
  }
}
