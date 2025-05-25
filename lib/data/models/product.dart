// lib/data/models/product.dart
class Product {
  final int? id;
  final String category;
  final String name;
  final int stock;
  final double price;
  final String? qrCode;
  final String? imageUrl;
  final DateTime createdAt;

  Product({
    this.id,
    required this.category,
    required this.name,
    required this.stock,
    required this.price,
    this.qrCode,
    this.imageUrl,
    required this.createdAt,
  });

  factory Product.fromMap(Map<String, dynamic> map) => Product(
        id: map['id'],
        category: map['category'] ?? 'Tanpa Kategori',
        name: map['name'] ?? 'Tanpa Nama',
        stock: (map['stock'] is int) ? map['stock'] : int.tryParse(map['stock'].toString()) ?? 0,
        price: map['price']?.toDouble() ?? 0.0,
        qrCode: map['qrCode'],
        imageUrl: map['imageUrl'],
        createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) ?? DateTime.now() : DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'category': category,
        'name': name,
        'stock': stock,
        'price': price,
        'qrCode': qrCode,
        'imageUrl': imageUrl,
        'createdAt': createdAt.toIso8601String(),
      };

  Product copyWith({
    int? id,
    String? category,
    String? name,
    int? stock,
    double? price,
    String? qrCode,
    String? imageUrl,
    DateTime? createdAt,
  }) =>
      Product(
        id: id ?? this.id,
        category: category ?? this.category,
        name: name ?? this.name,
        stock: stock ?? this.stock,
        price: price ?? this.price,
        qrCode: qrCode ?? this.qrCode,
        imageUrl: imageUrl ?? this.imageUrl,
        createdAt: createdAt ?? this.createdAt,
      );

  bool get hasStock => stock > 0;

  @override
  String toString() => 'Product(id: $id, name: $name, stock: $stock pcs, price: $price)';
}
