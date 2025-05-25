// lib/features/report/presentation/providers/report_providers.dart
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
      return {
        'label': _getChartLabel(report.period),
        'value': report.data['totalSales'] ?? 0.0,
        'category': report.data['category'] ?? '',
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
        return DateFormat('EEEE').format(date);
      case ReportType.monthly:
        return DateFormat('dd MMM').format(date);
    }
  }

  Future<void> exportReport(Report report, String format) async {
    try {
      // Generate dan simpan report
      await _repository.generateReport(report);
      
      // Tambahkan ke daftar reports
      if (!_reports.contains(report)) {
        _reports.add(report);
        _processChartData();
      }
    } catch (e) {
      _errorMessage = 'Ekspor gagal: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> loadSavedReports() async {
    _reports = await _repository.getSavedReportsFromFiles();
    _processChartData();
    notifyListeners();
  }
  // di report_providers.dart
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