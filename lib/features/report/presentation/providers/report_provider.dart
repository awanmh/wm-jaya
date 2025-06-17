// lib/features/report/presentation/providers/report_provider.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wm_jaya/data/models/report.dart';
import 'package:wm_jaya/data/repositories/report_repository.dart';
import 'package:wm_jaya/utils/date_range.dart';
import 'package:wm_jaya/utils/helpers/date_formatter.dart';

class ReportProvider with ChangeNotifier {
  final ReportRepository _repository;
  List<Report> _reports = [];
  ReportType _selectedType = ReportType.daily;
  DateTimeRange _dateRange;
  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _chartData = [];

  ReportProvider(this._repository)
      : _dateRange = DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 7)),
          end: DateTime.now(),
        );

    // Getters
  List<Report> get reports => _reports;
  ReportType get selectedType => _selectedType;
  DateTimeRange get dateRange => _dateRange;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get chartData => _chartData;

  // Total Harian
  double get todayTotal {
    final now = DateTime.now();
    return _reports
        .where((report) =>
            report.date.year == now.year &&
            report.date.month == now.month &&
            report.date.day == now.day)
        .fold(0.0, (sum, report) => sum + report.total);
  }

  // Total Mingguan
  double get weekTotal {
    final currentWeek = DateFormatter.currentWeek();
    return _reports
        .where((report) =>
            report.date.isAfter(currentWeek.start) &&
            report.date.isBefore(currentWeek.end))
        .fold(0.0, (sum, report) => sum + report.total);
  }

  // Total Bulanan
  double get monthTotal {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    return _reports
        .where((report) =>
            report.date.isAfter(firstDay) &&
            report.date.isBefore(lastDay))
        .fold(0.0, (sum, report) => sum + report.total);
  }


  Future<void> loadReports() async {
    if (_isLoading) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final newReports = await _repository.getReports(
        DateRange(
          start: _dateRange.start,
          end: _dateRange.end,
        ),
      );

      // Cek perubahan data sebelum update
      if (_isDataChanged(newReports)) {
        _reports = newReports;
        _processChartData();
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat laporan: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // =================================================================
  // === PERBAIKAN DI SINI ===
  // =================================================================
  /// Mengambil detail lengkap dari sebuah laporan berdasarkan ID-nya.
  /// Parameter reportId diubah menjadi int agar sesuai dengan repository.
  Future<Report> getReportDetails(int reportId) async { // <-- Diubah menjadi int
    try {
      // Sekarang tidak ada lagi error tipe data
      final detailedReport = await _repository.getReportById(reportId);
      return detailedReport;
    } catch (e) {
      // Melempar error kembali agar bisa ditangkap oleh UI (ReportDetailScreen)
      throw Exception('Gagal mendapatkan detail laporan: ${e.toString()}');
    }
  }
  // =================================================================

  bool _isDataChanged(List<Report> newReports) {
    return newReports.length != _reports.length || 
        newReports.hashCode != _reports.hashCode;
  }

  void setReportType(ReportType type) {
    if (_selectedType == type) return;
    _selectedType = type;
    _scheduleDataLoad();
  }

  void updateDateRange(DateTimeRange newRange) {
    if (_dateRange.start == newRange.start && _dateRange.end == newRange.end) {
      return;
    }

    _dateRange = newRange;
    _scheduleDataLoad();
  }


  void _scheduleDataLoad() {
    Future.microtask(() {
      notifyListeners();
      loadReports();
    });
  }

  void _processChartData() {
    final newChartData = _reports.map((report) {
      // Pastikan 'period' ada di objek Report
      final labelDate = report.period;
      return {
        'label': _getChartLabel(labelDate),
        'value': report.total, // Menggunakan total dari report utama
      };
    }).toList();

    if (newChartData.hashCode != _chartData.hashCode) {
      _chartData = newChartData;
    }
  }

  String _getChartLabel(DateTime date) {
    switch (_selectedType) {
      case ReportType.daily:
        return DateFormat('HH:mm').format(date);
      case ReportType.weekly:
        return DateFormat('EEE', 'id_ID').format(date); // Format hari dalam Bahasa Indonesia
      case ReportType.monthly:
        return DateFormat('dd MMM').format(date);
    }
  }

  Future<void> exportReport(Report report, String format) async {
    try {
      await _repository.exportReportToFile(report);
    } catch (e) {
      _errorMessage = 'Ekspor gagal: ${e.toString()}';
    }
    notifyListeners();
  }

  Future<void> loadSavedReports() async {
    _reports = await _repository.getSavedReportsFromFiles();
    _processChartData();
    notifyListeners();
  }

  Future<void> deleteReport(Report report) async {
    try {
      await _repository.deleteReport(report);
      _reports.removeWhere((r) => r.id == report.id);
      _processChartData();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal menghapus laporan: ${e.toString()}';
      notifyListeners();
    }
  }
}
