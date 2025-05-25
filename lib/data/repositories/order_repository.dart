// lib/data/repositories/order_repository.dart
// lib/data/repositories/order_repository.dart
import 'package:wm_jaya/data/local_db/database_helper.dart';
import 'package:wm_jaya/data/models/order.dart';
import 'package:wm_jaya/data/models/product.dart';
import 'package:wm_jaya/utils/date_range.dart';
import 'package:flutter/foundation.dart';

class OrderRepository {
  final DatabaseHelper _dbHelper;

  OrderRepository(this._dbHelper);

  /// 📌 **Menambahkan Order Baru**
  Future<int?> addOrder(Order order) async {
    final db = await _dbHelper.database;
    return db.transaction((txn) async {
      try {
        debugPrint('🔹 Menambahkan order: ${order.toMap()}');
        final orderId = await txn.insert('orders', order.toMap());
        debugPrint('✅ Order berhasil disimpan dengan ID: $orderId');

        for (final item in order.items) {
          debugPrint('🔹 Mengupdate stok produk: ID ${item.product.id} | Stok sebelum: ${item.product.stock}');
          if (item.product.stock < item.quantity) {
            throw Exception('🚨 Stok tidak mencukupi untuk produk ID: ${item.product.id}');
          }
          await txn.update(
            'products',
            {'stock': item.product.stock - item.quantity},
            where: 'id = ?',
            whereArgs: [item.product.id],
          );
          debugPrint('✅ Stok produk ID ${item.product.id} berhasil diperbarui.');
        }

        return orderId;
      } catch (e, stackTrace) {
        debugPrint('❌ ERROR di addOrder: $e');
        debugPrint('🔍 StackTrace: $stackTrace');
        return null;
      }
    });
  }

  /// 📌 **Mengambil Semua Produk**
  Future<List<Product>> getProducts() async {
    final db = await _dbHelper.database;
    final result = await db.query('products');
    debugPrint('✅ Produk diambil dari database: ${result.length} item');
    return result.map((e) => Product.fromMap(e)).toList();
  }

  /// 📌 **Mengambil Order Berdasarkan Rentang Tanggal**
  Future<List<Order>> getOrders(DateRange range) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'orders',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [
        range.start.toIso8601String(),
        range.end.toIso8601String(),
      ],
    );
    debugPrint('✅ Order ditemukan dalam rentang: ${result.length} order');
    return result.map((e) => Order.fromMap(e)).toList();
  }

  /// 📌 **Mengambil Order Berdasarkan ID**
  Future<Order> getOrderById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) {
      throw Exception('❌ Order dengan ID $id tidak ditemukan');
    }
    return Order.fromMap(result.first);
  }

  /// 📌 **Menandai Order Sudah Dibuat Laporan**
  Future<void> markOrderReported(int orderId) async {
    final db = await _dbHelper.database;
    try {
      await db.update(
        'orders',
        {'reportGenerated': 1}, // ✅ Pastikan nilai bool dikonversi ke int
        where: 'id = ?',
        whereArgs: [orderId],
      );
      debugPrint('✅ Order ID $orderId telah ditandai sebagai sudah dilaporkan');
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR di markOrderReported: $e');
      debugPrint('🔍 StackTrace: $stackTrace');
      throw Exception('Gagal menandai order sebagai dilaporkan: ${e.toString()}');
    }
  }

  /// 📌 **Mengambil Semua Order**
  Future<List<Order>> getAllOrders() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('orders');
    return List.generate(maps.length, (i) {
      return Order.fromMap(maps[i]);
    });
  }

  /// 📌 **Memperbarui Order**
  Future<void> updateOrder(int orderId, Map<String, dynamic> data) async {
    final db = await _dbHelper.database;
    try {
      // ✅ Pastikan bool dikonversi ke int sebelum diinput ke database
      final sanitizedData = data.map((key, value) {
        if (value is bool) return MapEntry(key, value ? 1 : 0);
        return MapEntry(key, value);
      });

      await db.update(
        'orders',
        sanitizedData,
        where: 'id = ?',
        whereArgs: [orderId],
      );

      debugPrint('✅ Order ID $orderId berhasil diperbarui');
    } catch (e) {
      debugPrint('❌ ERROR di updateOrder: $e');
      throw Exception('Gagal memperbarui order: ${e.toString()}');
    }
  }
}
