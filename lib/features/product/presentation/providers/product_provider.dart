// lib/features/product/presentation/providers/product_provider.dart
import 'package:flutter/foundation.dart';
import 'package:wm_jaya/data/models/product.dart';
import 'package:wm_jaya/data/repositories/product_repository.dart';

class ProductProvider with ChangeNotifier {
  final ProductRepository _repository;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String? _errorMessage;
  List<String> _categories = [];

  ProductProvider(this._repository);

  List<Product> get products => _products;
  List<Product> get filteredProducts => _filteredProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<String> get categories => _categories;

  Future<void> loadProducts() async {
    _setLoading(true);
    try {
      _products = await _repository.getProducts();
      _filteredProducts = List.from(_products);
      _updateCategories();
      _errorMessage = null;
    } catch (e) {
      _handleError('Gagal memuat produk: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  void _updateCategories() {
    final categories = _products.map((p) => p.category).toSet().toList();
    categories.insert(0, 'Semua');
    _categories = categories;
    notifyListeners();
  }

  Future<void> addCategory(String category) async {
    if (!_categories.contains(category)) {
      _categories.add(category);
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product) async {
    _setLoading(true);
    try {
      final newProduct = await _repository.addProduct(product);
      _products.add(newProduct);
      _filteredProducts = List.from(_products);
      if (!_categories.contains(product.category)) {
        _categories.add(product.category);
      }
      _errorMessage = null;
    } catch (e) {
      _handleError('Gagal menambah produk: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteProduct(int productId) async {
    _setLoading(true);
    try {
      await _repository.deleteProduct(productId);
      _products.removeWhere((p) => p.id == productId);
      _filteredProducts = List.from(_products);
      _updateCategories();
      _errorMessage = null;
    } catch (e) {
      _handleError('Gagal menghapus produk: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteCategory(String category) async {
    _setLoading(true);
    try {
      await _repository.deleteProductsByCategory(category);
      _products.removeWhere((p) => p.category == category);
      _filteredProducts = List.from(_products);
      _updateCategories();
      _errorMessage = null;
    } catch (e) {
      _handleError('Gagal menghapus kategori: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProduct(Product updatedProduct) async {
    _setLoading(true);
    try {
      await _repository.updateProduct(updatedProduct);
      final index = _products.indexWhere((p) => p.id == updatedProduct.id);
      if (index != -1) {
        _products[index] = updatedProduct;
        _filteredProducts = List.from(_products);
        if (!_categories.contains(updatedProduct.category)) {
          _categories.add(updatedProduct.category);
        }
      }
      _errorMessage = null;
    } catch (e) {
      _handleError('Gagal memperbarui produk: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  void filterByCategory(String category) {
    if (category == 'Semua') {
      _filteredProducts = List.from(_products);
    } else {
      _filteredProducts = _products.where((p) => p.category == category).toList();
    }
    notifyListeners();
  }

  void searchProducts(String query) {
    _filteredProducts = _products.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
    notifyListeners();
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