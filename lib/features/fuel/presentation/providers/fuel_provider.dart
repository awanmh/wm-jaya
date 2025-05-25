// lib/features/presentation/providers/fuel_provider.dart
import 'package:flutter/foundation.dart';
import 'package:wm_jaya/data/models/fuel.dart';
import 'package:wm_jaya/data/repositories/fuel_repository.dart';
import 'package:wm_jaya/data/local_db/database_helper.dart';


class FuelProvider with ChangeNotifier {
  final FuelRepository _repository;
  Fuel? _currentPurchase;
  List<Fuel> _fuelHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, double> _fuelPrices = {
    'Pertalite': 10000,
    'Pertamax': 15000,
    'Solar': 8000,
  };

  FuelProvider(this._repository);

  // Getters
  Fuel? get currentPurchase => _currentPurchase;
  List<Fuel> get fuelHistory => _fuelHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<String> get fuelTypes => _fuelPrices.keys.toList();

  double getPricePerLiter(String type) {
    return _fuelPrices[type] ?? 0;
  }

  void setPricePerLiter(String type, double price) {
    _fuelPrices[type] = price;
    notifyListeners();
  }

  Future<void> savePurchase({
    required String type,
    double? price,
    double? liters,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      if (!_fuelPrices.containsKey(type)) {
        throw Exception('Jenis bensin tidak valid');
      }

      final pricePerLiter = _fuelPrices[type]!;
      double calculatedLiters;
      double calculatedTotal;

      if (price != null) {
        calculatedLiters = price / pricePerLiter;
        calculatedTotal = price;
      } else if (liters != null) {
        calculatedTotal = liters * pricePerLiter;
        calculatedLiters = liters;
      } else {
        throw Exception('Harap isi harga atau liter');
      }

      final newPurchase = Fuel(
        type: type,
        liters: calculatedLiters,
        pricePerLiter: pricePerLiter,
        total: calculatedTotal,
        date: DateTime.now(),
      );

      await compute(_savePurchaseInBackground, newPurchase);

      _fuelHistory.insert(0, newPurchase);
      _currentPurchase = null;
      notifyListeners();
    } catch (e) {
      _handleError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadFuelHistory() async {
    _setLoading(true);
    _clearError();

    try {
      final fuelHistory = await compute(_loadFuelHistoryInBackground, _repository);
      _fuelHistory = fuelHistory;
      notifyListeners();
    } catch (e) {
      _handleError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void calculatePreview({String? type, double? price, double? liters}) {
    if (type == null || !_fuelPrices.containsKey(type)) return;

    final pricePerLiter = _fuelPrices[type]!;
    Fuel? preview;

    if (price != null) {
      preview = Fuel(
        type: type,
        liters: price / pricePerLiter,
        pricePerLiter: pricePerLiter,
        total: price,
        date: DateTime.now(),
      );
    } else if (liters != null) {
      preview = Fuel(
        type: type,
        liters: liters,
        pricePerLiter: pricePerLiter,
        total: liters * pricePerLiter,
        date: DateTime.now(),
      );
    }

    _currentPurchase = preview;
    notifyListeners();
  }

  Future<void> deletePurchase(String id) async {
    _setLoading(true);

    try {
      await compute(_deletePurchaseInBackground, {'repository': _repository, 'id': id});
      _fuelHistory.removeWhere((p) => p.id == int.tryParse(id));
      notifyListeners();
    } catch (e) {
      _handleError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Background helper functions
  static Future<void> _savePurchaseInBackground(Fuel purchase) async {
    final dbHelper = DatabaseHelper();
    final fuelRepository = FuelRepository(dbHelper);
    await Future.delayed(const Duration(milliseconds: 500));
    await fuelRepository.addFuelPurchase(purchase);
  }

  static Future<List<Fuel>> _loadFuelHistoryInBackground(FuelRepository repository) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return await repository.getFuelHistory();
  }

  static Future<void> _deletePurchaseInBackground(Map<String, dynamic> params) async {
    final repository = params['repository'] as FuelRepository;
    final id = params['id'] as String;
    await Future.delayed(const Duration(milliseconds: 500));
    await repository.deleteFuelPurchase(id);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _handleError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}