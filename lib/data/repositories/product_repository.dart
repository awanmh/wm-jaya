// lib/data/repositories/product_repository.dart
import 'package:flutter/foundation.dart';
import 'package:wm_jaya/data/local_db/database_helper.dart';
import 'package:wm_jaya/data/models/product.dart';

class ProductRepository {
  final DatabaseHelper _dbHelper;

  ProductRepository(this._dbHelper);

  /// Mengambil semua produk dari database.
  /// Fungsi ini sekarang menjadi satu-satunya sumber untuk mengambil daftar produk.
  Future<List<Product>> getProducts() async {
    final db = await _dbHelper.database;
    final result = await db.query('products', orderBy: 'name ASC'); // Urutkan berdasarkan nama
    return result.map((e) => Product.fromMap(e)).toList();
  }

  /// Menambahkan produk baru ke database.
  /// Dibuat lebih efisien dengan langsung mengembalikan produk dengan ID baru
  /// tanpa perlu melakukan query ulang.
  Future<Product> addProduct(Product product) async {
    final db = await _dbHelper.database;
    final id = await db.insert('products', product.toMap());
    return product.copyWith(id: id);
  }

  /// Memperbarui produk yang sudah ada.
  /// Dibuat lebih efisien dengan tidak melakukan query ulang setelah update.
  /// Cukup melakukan update dan melempar error jika gagal.
  Future<void> updateProduct(Product product) async {
    if (product.id == null) {
      throw Exception('Gagal memperbarui: ID produk tidak boleh null.');
    }
    final db = await _dbHelper.database;
    final affectedRows = await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );

    if (affectedRows == 0) {
      throw Exception('Gagal memperbarui: Produk dengan ID ${product.id} tidak ditemukan.');
    }
  }

  /// Menghapus satu produk berdasarkan ID.
  Future<int> deleteProduct(int id) async {
    final db = await _dbHelper.database;
    return db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  /// Menghapus semua produk dalam satu kategori.
  Future<int> deleteProductsByCategory(String category) async {
    final db = await _dbHelper.database;
    return db.delete(
      'products',
      where: 'category = ?',
      whereArgs: [category],
    );
  }

  /// Memperbarui nama kategori untuk semua produk yang relevan.
  Future<void> updateCategoryName(String oldCategory, String newCategory) async {
    final db = await _dbHelper.database;
    try {
      await db.update(
        'products',
        {'category': newCategory},
        where: 'category = ?',
        whereArgs: [oldCategory],
      );
      debugPrint('✅ Kategori "$oldCategory" berhasil diubah menjadi "$newCategory"');
    } catch (e) {
      debugPrint('❌ ERROR di updateCategoryName: $e');
      throw Exception('Gagal memperbarui nama kategori di database.');
    }
  }

  /// Mencari produk berdasarkan nama.
  Future<List<Product>> searchProducts(String query) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'products',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
    return result.map((e) => Product.fromMap(e)).toList();
  }

  /// Memperbarui stok untuk satu produk.
  Future<void> updateStock(int productId, int newStock) async {
    final db = await _dbHelper.database;
    await db.update(
      'products',
      {'stock': newStock},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  /// Mengambil satu produk berdasarkan ID.
  Future<Product> getProductById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) {
      throw Exception('Produk dengan id $id tidak ditemukan');
    }
    return Product.fromMap(result.first);
  }
}
