// lib/providers/fuel_providers.dart
import 'package:flutter/foundation.dart';
import 'package:wm_jaya/data/models/fuel.dart';
import 'package:wm_jaya/data/repositories/fuel_repository.dart';
import 'package:wm_jaya/utils/date_range.dart';

class FuelProvider with ChangeNotifier {
  final FuelRepository _repository;
  List<Fuel> _purchases = [];
  bool _isLoading = false;
  String? _errorMessage;

  FuelProvider(this._repository);

  List<Fuel> get purchases => _purchases;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPurchases({required DateRange range}) async {
    _setLoading(true);
    try {
      _purchases = await _repository.getFuelPurchases(range);
      notifyListeners();
    } catch (e) {
      _handleError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addPurchase(Fuel purchase) async {
    _setLoading(true);
    try {
      await _repository.addFuelPurchase(purchase);
      await loadPurchases(
        range: DateRange(
          start: DateTime(DateTime.now().year, DateTime.now().month, 1),
          end: DateTime(DateTime.now().year, DateTime.now().month + 1, 1).subtract(
            const Duration(days: 1),
      ),
    ),
  );
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
