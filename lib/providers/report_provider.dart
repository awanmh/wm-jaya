// report_provider.dart
import 'package:flutter/foundation.dart';
import 'package:wm_jaya/data/models/report.dart';
import 'package:wm_jaya/data/repositories/report_repository.dart';
import 'package:wm_jaya/utils/date_range.dart';

class ReportProvider with ChangeNotifier {
  final ReportRepository _repository;
  List<Report> _reports = [];
  bool _isLoading = false;
  String? _errorMessage;

  ReportProvider(this._repository);

  List<Report> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadReports(DateRange range) async {
    _setLoading(true);
    try {
      _reports = await _repository.getReports(range);
      notifyListeners();
    } catch (e) {
      _handleError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _handleError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
  
}
