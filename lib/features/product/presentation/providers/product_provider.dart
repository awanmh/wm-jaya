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

  // Getters
  List<Product> get products => _products;
  List<Product> get filteredProducts => _filteredProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  /// Getter untuk kategori mentah (digunakan untuk validasi)
  List<String> get categories => _categories;
  
  /// Getter untuk kategori yang akan ditampilkan di UI (dengan tambahan "Semua")
  List<String> get categoriesForDisplay {
    final displayList = List<String>.from(_categories);
    displayList.insert(0, 'Semua');
    return displayList;
  }

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
    // Fungsi ini sekarang hanya memperbarui list kategori mentah
    final categorySet = _products.map((p) => p.category).toSet();
    _categories = categorySet.toList()..sort(); // Urutkan berdasarkan abjad
  }

  Future<void> addProduct(Product product) async {
    _setLoading(true);
    try {
      final newProduct = await _repository.addProduct(product);
      _products.add(newProduct);
      _filteredProducts = List.from(_products);
      _updateCategories();
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
      await loadProducts(); // Cara paling aman untuk sinkronisasi data
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
      await loadProducts(); // Muat ulang semua data agar konsisten
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
      await loadProducts(); // Muat ulang semua data agar konsisten
    } catch (e) {
      _handleError('Gagal memperbarui produk: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // PERBAIKAN: Fungsi ini sekarang berada di dalam kelas dan menggunakan variabel yang benar
  Future<void> updateCategory(String oldCategory, String newCategory) async {
    _setLoading(true);
    try {
      await _repository.updateCategoryName(oldCategory, newCategory);
      await loadProducts(); // Muat ulang produk untuk memperbarui UI
    } catch (e) {
      _handleError('Gagal memperbarui kategori: ${e.toString()}');
      rethrow;
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
    if (query.isEmpty) {
        _filteredProducts = List.from(_products);
    } else {
        _filteredProducts = _products
            .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
    }
    notifyListeners();
  }

  void _setLoading(bool loading) {
    if (_isLoading == loading) return;
    _isLoading = loading;
    notifyListeners();
  }

  void _handleError(String message) {
    _errorMessage = message;
  }
}
