// lib/features/report/presentation/screens/report_daily_screen.dart
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wm_jaya/data/models/report.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:wm_jaya/constants/app_colors.dart';
import 'package:wm_jaya/features/report/presentation/providers/report_provider.dart';
import 'package:wm_jaya/utils/helpers/date_formatter.dart';
import 'package:wm_jaya/widgets/common/app_card.dart';

class ReportDailyScreen extends StatefulWidget {
  const ReportDailyScreen({super.key});

  @override
  ReportDailyScreenState createState() => ReportDailyScreenState();
}

class ReportDailyScreenState extends State<ReportDailyScreen> {
  late DateTime _selectedDate;
  late ReportProvider _provider;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    
    // Pindahkan inisialisasi provider ke initState dengan listen: false
    _provider = Provider.of<ReportProvider>(context, listen: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  void _loadData() {
    _provider.setReportType(ReportType.daily);
    _provider.updateDateRange(
      DateTimeRange(
        start: _selectedDate,
        end: _selectedDate.add(const Duration(days: 1)),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormatter.format(_selectedDate, pattern: 'dd MMMM yyyy')),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
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
      margin: const EdgeInsets.all(8.0),
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        series: <CartesianSeries<dynamic, dynamic>>[
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

 Widget _buildTransactionItem(dynamic report) {
  if (report == null) return const SizedBox(); // Hindari error jika null

  // Pastikan type memiliki nilai yang valid
  String type = (report.type is ReportType)
      ? (report.type as ReportType).name.toUpperCase()
      : "TIDAK DIKETAHUI";

  // Format angka ke format rupiah tanpa desimal
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  String totalFormatted = currencyFormat.format(report.total ?? 0);

  return AppCard(
    margin: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          type,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text('Total: $totalFormatted'),
        Text('Waktu: ${DateFormatter.formatTime(report.date ?? DateTime.now())}'),
      ],
    ),
  );
}


  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadData();
    }
  }
}