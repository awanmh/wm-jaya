// lib/data/repositories/order_repository.dart
import 'dart:convert'; // Import dart:convert untuk menggunakan json.decode
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
          // Perhitungan stok sudah ditangani di provider, di sini kita hanya menyimpan
          await txn.update(
            'products',
            {'stock': item.product.stock}, // Simpan stok terbaru
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
  
  // === FUNGSI YANG DIPERBAIKI SECARA MENYELURUH ===
  /// 📌 **Menghapus Order dan Mengembalikan Stok**
  Future<void> deleteOrderAndRestoreStock(int orderId) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      try {
        // 1. Ambil data order yang akan dihapus
        final orderData = await txn.query(
          'orders',
          where: 'id = ?',
          whereArgs: [orderId],
          limit: 1,
        );

        if (orderData.isEmpty) {
          throw Exception('Pesanan dengan ID $orderId tidak ditemukan.');
        }

        // 2. Decode item-item dari string JSON
        final List<dynamic> items = json.decode(orderData.first['items'] as String);

        // 3. Kembalikan stok untuk setiap produk
        for (final item in items) {
          // PERBAIKAN: Cara membaca 'product_id' dan 'quantity' dibuat lebih aman
          // Ini untuk menangani kasus jika 'item' berisi map 'product' di dalamnya.
          final Map<String, dynamic>? productMap = item['product'] as Map<String, dynamic>?;
          final int? productId = productMap?['id'] as int? ?? item['product_id'] as int?;
          final int? quantity = item['quantity'] as int?;

          // Lanjutkan hanya jika productId dan quantity valid
          if (productId != null && quantity != null && quantity > 0) {
            // Tambahkan kembali stok yang dibatalkan
            await txn.rawUpdate(
              'UPDATE products SET stock = stock + ? WHERE id = ?',
              [quantity, productId],
            );
            debugPrint('✅ Stok dikembalikan untuk produk ID $productId sebanyak $quantity');
          } else {
            debugPrint('⚠️ Gagal mengembalikan stok: productId atau quantity tidak valid. Item: $item');
          }
        }

        // 4. Hapus pesanan dari tabel 'orders'
        await txn.delete(
          'orders',
          where: 'id = ?',
          whereArgs: [orderId],
        );
        debugPrint('✅ Pesanan ID $orderId berhasil dibatalkan dan dihapus.');

      } catch (e) {
        debugPrint('❌ ERROR di deleteOrderAndRestoreStock: $e');
        rethrow; // Lempar kembali error agar bisa ditangani oleh provider
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
