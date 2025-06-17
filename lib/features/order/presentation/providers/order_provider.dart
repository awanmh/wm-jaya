// lib/features/presentation/providers/order_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wm_jaya/data/models/order.dart';
import 'package:wm_jaya/data/models/product.dart';
import 'package:wm_jaya/data/repositories/order_repository.dart';
import 'package:wm_jaya/data/repositories/product_repository.dart';

class OrderProvider with ChangeNotifier {
  final OrderRepository _orderRepository;
  final ProductRepository _productRepository;

  // State untuk Data
  List<Order> _orders = [];
  List<Product> _allProducts = []; // Daftar semua produk dari database
  List<Product> _filteredProducts = []; // Daftar produk yang akan ditampilkan (setelah filter/pencarian)
  final List<OrderItem> _cartItems = [];
  Order? _currentOrder;

  // State untuk UI
  bool _isLoading = false;
  String? _errorMessage;

  OrderProvider(this._orderRepository, this._productRepository);

  // === Getters ===
  List<Product> get filteredProducts => _filteredProducts;
  List<OrderItem> get cartItems => _cartItems;
  double get totalAmount => _cartItems.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Order? get currentOrder => _currentOrder;
  
  // === Manajemen Produk ===
  /// Memuat semua produk dari repository dan menyiapkannya untuk ditampilkan.
  Future<void> loadProducts() async {
    _setLoading(true);
    try {
      _allProducts = await _productRepository.getProducts();
      // Saat pertama kali dimuat, tampilkan semua produk yang memiliki stok
      _filteredProducts = _allProducts.where((p) => p.stock > 0).toList();
      _errorMessage = null;
    } catch (e) {
      _handleError('Gagal memuat produk: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Mencari produk berdasarkan nama.
  void searchProducts(String query) {
    if (query.isEmpty) {
      // Jika query kosong, tampilkan semua produk yang memiliki stok
      _filteredProducts = _allProducts.where((p) => p.stock > 0).toList();
    } else {
      // Jika ada query, cari produk berdasarkan nama dari semua produk
      _filteredProducts = _allProducts
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) && product.stock > 0)
          .toList();
    }
    notifyListeners();
  }

  // === Operasi Keranjang (Cart) ===
  void addToCart(Product product) {
    if (product.stock <= 0) return;

    // Kurangi stok di list lokal
    _updateLocalProductStock(product.id!, product.stock - 1);

    final index = _cartItems.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _cartItems[index] = _cartItems[index].copyWith(quantity: _cartItems[index].quantity + 1);
    } else {
      _cartItems.add(OrderItem(product: product, quantity: 1, price: product.price));
    }
    notifyListeners();
  }

  void removeFromCart(Product product) {
    final index = _cartItems.indexWhere((item) => item.product.id == product.id);
    if (index == -1) return;
    
    // Tambah stok di list lokal
    _updateLocalProductStock(product.id!, product.stock + 1);

    if (_cartItems[index].quantity > 1) {
      _cartItems[index] = _cartItems[index].copyWith(quantity: _cartItems[index].quantity - 1);
    } else {
      _cartItems.removeAt(index);
    }
    notifyListeners();
  }

  void clearCart() {
    // Kembalikan semua stok produk yang ada di keranjang
    for (final item in _cartItems) {
      final originalProduct = _allProducts.firstWhere((p) => p.id == item.product.id);
      _updateLocalProductStock(item.product.id!, originalProduct.stock);
    }
    _cartItems.clear();
    notifyListeners();
  }
  
  // === Manajemen Pesanan (Order) ===
  Future<void> loadOrders() async {
    _setLoading(true);
    try {
      _orders = await _orderRepository.getAllOrders();
      _errorMessage = null;
    } catch (e) {
      _handleError('Gagal memuat order: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> getOrderDetails(int orderId) async {
    _setLoading(true);
    try {
      if (orderId <= 0) throw Exception('ID Order tidak valid');
      _currentOrder = await _orderRepository.getOrderById(orderId);
    } catch (e) {
      _handleError('Gagal memuat detail order: ${e.toString()}');
      _currentOrder = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<int> createOrder() async {
    if (_cartItems.isEmpty) {
      throw Exception('Keranjang belanja kosong.');
    }
    _setLoading(true);
    try {
      final newOrder = Order(
        items: List.of(_cartItems),
        total: totalAmount,
        payment: totalAmount, // Asumsi pembayaran tunai pas
        change: 0,
        date: DateTime.now(),
      );
      // addOrder akan menangani update stok di database
      final orderId = await _orderRepository.addOrder(newOrder);
      
      _cartItems.clear(); // Kosongkan keranjang setelah berhasil
      await loadProducts(); // Muat ulang produk untuk refresh stok di UI
      
      return orderId ?? -1;
    } catch (e) {
      _handleError('Gagal membuat order: ${e.toString()}');
      return -1;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markOrderAsReported(int orderId) async {
    try {
      await _orderRepository.markOrderReported(orderId);
      if (_currentOrder?.id == orderId) {
        _currentOrder = _currentOrder?.copyWith(reportGenerated: true);
      }
      notifyListeners();
    } catch (e) {
      _handleError('Gagal menandai order: ${e.toString()}');
    }
  }

  Future<void> cancelOrder(int orderId) async {
    _setLoading(true);
    try {
      await _orderRepository.deleteOrderAndRestoreStock(orderId);
      _orders.removeWhere((order) => order.id == orderId);
      await loadProducts(); // Muat ulang produk untuk refresh stok
    } catch (e) {
      _handleError('Gagal membatalkan pesanan: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // === Helper Internals ===
  /// Mengupdate stok produk di list _allProducts dan _filteredProducts secara lokal
  void _updateLocalProductStock(int productId, int newStock) {
    int productIndex = _allProducts.indexWhere((p) => p.id == productId);
    if(productIndex != -1) {
      _allProducts[productIndex] = _allProducts[productIndex].copyWith(stock: newStock);
    }
    // Update juga di filtered list agar UI langsung berubah
    int filteredIndex = _filteredProducts.indexWhere((p) => p.id == productId);
    if(filteredIndex != -1) {
      _filteredProducts[filteredIndex] = _filteredProducts[filteredIndex].copyWith(stock: newStock);
    }
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
