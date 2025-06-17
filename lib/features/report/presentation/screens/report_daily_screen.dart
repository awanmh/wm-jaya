// lib/features/report/presentation/screens/report_daily_screen.dart
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wm_jaya/data/models/report.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:wm_jaya/constants/app_colors.dart';
import 'package:wm_jaya/features/report/presentation/providers/report_provider.dart';
import 'package:wm_jaya/features/report/presentation/screens/report_detail_screen.dart';
import 'package:wm_jaya/utils/helpers/date_formatter.dart';
import 'package:wm_jaya/widgets/common/app_card.dart';

class ReportDailyScreen extends StatefulWidget {
  // Anda perlu meneruskan initialDate dari parent (ReportScreen)
  // Ini adalah bagian dari solusi arsitektur yang lebih baik
  final DateTime initialDate; 

  const ReportDailyScreen({
    super.key,
    required this.initialDate,
    // Callback ini juga bagian dari solusi yang lebih baik
    // required Function(DateTime) onDateSelected, 
  });

  @override
  ReportDailyScreenState createState() => ReportDailyScreenState();
}

class ReportDailyScreenState extends State<ReportDailyScreen> {
  late DateTime _selectedDate;
  late ReportProvider _provider;

  @override
  void initState() {
    super.initState();
    // Gunakan initialDate dari widget, bukan DateTime.now()
    _selectedDate = widget.initialDate; 
    
    _provider = Provider.of<ReportProvider>(context, listen: false);
    _loadData(); // Panggil load data di initState
  }

  // Hapus didChangeDependencies agar data tidak di-load berulang kali
  
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
        // INI SOLUSINYA: Tambahkan baris ini untuk menghapus panah kembali
        automaticallyImplyLeading: false, 
        
        title: Text(DateFormatter.format(_selectedDate, pattern: 'dd MMMM yyyy')),
        backgroundColor: Colors.transparent, // Membuat AppBar transparan
        elevation: 0, // Menghilangkan bayangan AppBar
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
          // Jika tidak ada laporan, tampilkan pesan
          if (provider.reports.isEmpty) {
            return const Center(child: Text("Tidak ada laporan untuk tanggal ini."));
          }
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
    // Jangan tampilkan chart jika tidak ada data
    if(provider.chartData.isEmpty) return const SizedBox.shrink();

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
      itemBuilder: (ctx, index) => _buildTransactionItem(ctx, provider.reports[index]),
    );
  }

  Widget _buildTransactionItem(BuildContext context, Report report) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final totalFormatted = currencyFormat.format(report.total);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportDetailScreen(summaryReport: report),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: AppCard(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                report.type.name.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total: $totalFormatted',
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                'Waktu: ${DateFormatter.formatTime(report.date)}',
                 style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
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
