// lib/providers/order_provider.dart/
import 'package:flutter/foundation.dart';
import 'package:wm_jaya/data/models/order.dart';
import 'package:wm_jaya/data/repositories/order_repository.dart';
import 'package:wm_jaya/data/models/product.dart';
import 'package:wm_jaya/utils/date_range.dart';

class OrderProvider with ChangeNotifier {
  final OrderRepository _repository;
  final List<OrderItem> _cartItems = [];
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;
  double? _paymentAmount;

  OrderProvider(this._repository);

  List<OrderItem> get cartItems => _cartItems;
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get totalAmount => _cartItems.fold(
        0,
        (sum, item) => sum + (item.product.price * item.quantity),
      );

  Future<void> loadOrders() async {
    _setLoading(true);
    try {
      final now = DateTime.now();
      final firstDay = DateTime(now.year, now.month, 1);
      final lastDay = DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));

      _orders = await _repository.getOrders(
        DateRange(
          start: firstDay,
          end: lastDay,
        ),
      );
      notifyListeners();
    } catch (e) {
      _handleError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void addToCart(Product product) {
    final index = _cartItems.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      _cartItems.removeAt(index);
      _cartItems.insert(
        index,
        OrderItem(
          product: product,
          quantity: _cartItems[index].quantity + 1,
          price: product.price, // Tambahkan price di sini
        ),
      );
    } else {
      _cartItems.add(OrderItem(
        product: product,
        quantity: 1,
        price: product.price, // Tambahkan price di sini
      ));
    }
    notifyListeners();
  }

  Future<void> confirmOrder() async {
    _setLoading(true);
    try {
      final order = Order(
        items: List.from(_cartItems),
        total: totalAmount,
        payment: _paymentAmount ?? 0,
        change: _paymentAmount != null ? (_paymentAmount! - totalAmount) : 0,
        date: DateTime.now(),
        reportGenerated: false,
      );
      await _repository.addOrder(order);
      _cartItems.clear();
      await loadOrders();
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