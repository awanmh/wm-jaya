// lib/data/models/order.dart
import 'dart:convert';
import 'package:wm_jaya/data/models/product.dart';

class Order {
  final int? id;
  final List<OrderItem> items;
  final double total;
  final double payment;
  final double change;
  final DateTime date;
  final bool reportGenerated;

  Order({
    this.id,
    required this.items,
    required this.total,
    required this.payment,
    required this.change,
    required this.date,
    this.reportGenerated = false,
  });

  Order copyWith({
    int? id,
    List<OrderItem>? items,
    double? total,
    double? payment,
    double? change,
    DateTime? date,
    bool? reportGenerated,
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? this.items,
      total: total ?? this.total,
      payment: payment ?? this.payment,
      change: change ?? this.change,
      date: date ?? this.date,
      reportGenerated: reportGenerated ?? this.reportGenerated,
    );
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      items: (json.decode(map['items']) as List<dynamic>)
          .map((e) => OrderItem.fromJson(e))
          .toList(),
      total: map['total'].toDouble(),
      payment: map['payment'].toDouble(),
      change: map['change'].toDouble(),
      date: DateTime.parse(map['date']),
      reportGenerated: map['reportGenerated'] == 1,
    );
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'items': json.encode(items.map((e) => e.toJson()).toList()),
    'total': total,
    'payment': payment,
    'change': change,
    'date': date.toIso8601String(),
    'reportGenerated': reportGenerated ? 1 : 0,
  };

  double get orderTotalPrice => items.fold(
    0,
    (sum, item) => sum + (item.product.price * item.quantity),
  );
}

class OrderItem {
  final Product product;
  final int quantity;
  final double price;

  OrderItem({
    required this.product,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
  try {
    return OrderItem(
      product: Product.fromMap(json['product']),
      quantity: json['quantity'] ?? 0,
      price: (json['price'] as num).toDouble(),
    );
  } catch (e) {
    // Menghindari error dengan memberikan nilai default yang valid
    return OrderItem(
      product: Product(
        id: 0, 
        name: 'Unknown', 
        price: 0.0, 
        stock: 0, 
        category: 'Uncategorized', // Default category
        createdAt: DateTime.now(), // Menambahkan nilai default untuk createdAt
      ),
      quantity: 0,
      price: 0.0,
    );
  }
}



  Map<String, dynamic> toJson() => {
    'product': product.toMap(),
    'quantity': quantity,
    'price': price,
  };

  double get itemTotalPrice => product.price * quantity;

  OrderItem copyWith({
    Product? product,
    int? quantity,
    double? price,
  }) {
    return OrderItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }
}