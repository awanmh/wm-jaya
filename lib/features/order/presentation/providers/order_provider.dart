// lib/features/presentation/providers/order_provider.dart
import 'package:flutter/foundation.dart';
import 'package:wm_jaya/data/models/order.dart';
import 'package:wm_jaya/data/models/product.dart';
import 'package:wm_jaya/data/repositories/order_repository.dart';
import 'package:wm_jaya/data/repositories/product_repository.dart';
import 'package:flutter/material.dart';

class OrderProvider with ChangeNotifier {
  final OrderRepository _orderRepository;
  final ProductRepository _productRepository;

  List<Order> _orders = [];
  final List<OrderItem> _cartItems = [];
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String? _errorMessage;
  Order? _currentOrder;

  OrderProvider(this._orderRepository, this._productRepository);

  // Getters
  List<Product> get filteredProducts => _filteredProducts;
  List<OrderItem> get cartItems => _cartItems;
  double get totalAmount => _cartItems.fold(
      0.0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Order? get currentOrder => _currentOrder;

  Future<void> initialize() async {
    await loadProducts();
    await loadOrders();
  }

  // Product Management
  Future<void> loadProducts() async {
    _setLoading(true);
    try {
      _allProducts = await _productRepository.getAllProducts();
      _filteredProducts = _allProducts.where((p) => p.stock > 0).toList();
      _errorMessage = null;
    } catch (e) {
      _handleError('Gagal memuat produk: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getOrderDetails(int orderId) async {
    _setLoading(true);
    try {
      if (orderId <= 0) throw Exception('ID Order tidak valid');
      _currentOrder = await _orderRepository.getOrderById(orderId);
      if (_currentOrder == null) throw Exception('Order tidak ditemukan');
      _errorMessage = null;
    } catch (e) {
      _handleError('Gagal memuat detail order: ${e.toString()}');
      _currentOrder = null;
    } finally {
      _setLoading(false);
    }
  }

  void searchProducts(String query) {
    _filteredProducts = _allProducts.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) && product.stock > 0;
    }).toList();
    notifyListeners();
  }

  // Cart Operations
  void addToCart(Product product) {
    if (product.stock <= 0) return;

    final updatedProduct = product.copyWith(stock: product.stock - 1);
    _updateProductInLists(updatedProduct);

    final index = _cartItems.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _cartItems[index] = _cartItems[index].copyWith(quantity: _cartItems[index].quantity + 1);
    } else {
      _cartItems.add(OrderItem(product: updatedProduct, quantity: 1, price: updatedProduct.price));
    }
    notifyListeners();
  }

  void removeFromCart(Product product) {
    final index = _cartItems.indexWhere((item) => item.product.id == product.id);
    if (index == -1) return;

    final updatedProduct = product.copyWith(stock: product.stock + 1);
    _updateProductInLists(updatedProduct);

    if (_cartItems[index].quantity > 1) {
      _cartItems[index] = _cartItems[index].copyWith(quantity: _cartItems[index].quantity - 1);
    } else {
      _cartItems.removeAt(index);
    }
    notifyListeners();
  }

  void clearCart() {
    _resetProductStock();
    _cartItems.clear();
    notifyListeners();
  }

  // Order Management
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

  Future<int> createOrder() async {
    _setLoading(true);
    try {
      final paymentAmount = totalAmount;
      debugPrint('Creating order with total: $paymentAmount');
      final newOrder = Order(
        items: List.of(_cartItems),
        total: totalAmount,
        payment: paymentAmount,
        change: paymentAmount - totalAmount,
        date: DateTime.now(),
      );
      final orderId = await _orderRepository.addOrder(newOrder);
      if (orderId == null) throw Exception('Gagal mendapatkan ID order.');

      _orders.insert(0, newOrder.copyWith(id: orderId));
      _cartItems.clear();
      notifyListeners();

      return orderId;
    } catch (e) {
      _handleError('Gagal membuat order: ${e.toString()}');
      return -1;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markOrderAsReported(int orderId) async {
    _setLoading(true);
    try {
      if (orderId <= 0) throw Exception('ID Order tidak valid');
      await _orderRepository.markOrderReported(orderId);

      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(reportGenerated: true);
      }
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _handleError('Gagal menandai order sebagai dilaporkan: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  void _resetProductStock() {
    for (final item in _cartItems) {
      final originalProduct = item.product.copyWith(stock: item.product.stock + item.quantity);
      _updateProductInLists(originalProduct);
    }
  }

  void _updateProductInLists(Product updatedProduct) {
    _allProducts = _allProducts.map((p) => p.id == updatedProduct.id ? updatedProduct : p).toList();
    _filteredProducts = _filteredProducts.map((p) => p.id == updatedProduct.id ? updatedProduct : p).toList();
    _productRepository.updateProduct(updatedProduct);
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
