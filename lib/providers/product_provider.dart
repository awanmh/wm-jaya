// product_provider.dart
import 'package:flutter/foundation.dart';
import 'package:wm_jaya/data/models/product.dart';
import 'package:wm_jaya/data/repositories/product_repository.dart';

class ProductProvider with ChangeNotifier {
  final ProductRepository _repository;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  ProductProvider(this._repository);

  List<Product> get products => _filteredProducts;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadProducts() async {
    _setLoading(true);
    _clearError();
    
    try {
      _products = await _repository.getProducts();
      _filteredProducts = List.from(_products);
      _extractCategories();
    } catch (e) {
      _handleError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void searchProducts(String query) {
    _filteredProducts = _products.where((p) => 
      p.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    _setLoading(true);
    try {
      final newProduct = await _repository.addProduct(product);
      _products.add(newProduct);
      _extractCategories();
    } catch (e) {
      _handleError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _extractCategories() {
    _categories = _products.map((p) => p.category).toSet().toList()
      ..insert(0, 'All');
    notifyListeners();
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