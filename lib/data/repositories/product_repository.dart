// lib/data/repositories/product_repository.dart
import 'package:wm_jaya/data/local_db/database_helper.dart';
import 'package:wm_jaya/data/models/product.dart';
import 'package:wm_jaya/constants/app_constants.dart';

class ProductRepository {
  final DatabaseHelper _dbHelper;

  ProductRepository(this._dbHelper);

  Future<List<Product>> getProducts({int page = 1}) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'products',
      limit: AppConstants.dbPageLimit,
      offset: (page - 1) * AppConstants.dbPageLimit,
    );
    return result.map((e) => Product.fromMap(e)).toList();
  }

  Future<Product> addProduct(Product product) async {
    final db = await _dbHelper.database;
    final id = await db.insert('products', product.toMap());
    final result = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    return Product.fromMap(result.first);
  }

  Future<Product> updateProduct(Product product) async {
    final db = await _dbHelper.database;
    final affectedRows = await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );

    if (affectedRows > 0) {
      if (product.id == null) {
        throw Exception('Gagal memperbarui produk: ID produk tidak ditemukan');
      }
      final updatedProduct = await getProductById(product.id!);
      return updatedProduct;
    } else {
      throw Exception('Gagal memperbarui produk');
    }
  }

  Future<int> deleteProduct(int id) async {
    final db = await _dbHelper.database;
    return db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Product>> searchProducts(String query) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'products',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
    return result.map((e) => Product.fromMap(e)).toList();
  }

  Future<void> updateStock(int productId, int newStock) async {
    final db = await _dbHelper.database;
    await db.update(
      'products',
      {'stock': newStock},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  Future<Product> getProductById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) {
      throw Exception('Product with id $id not found');
    }
    return Product.fromMap(result.first);
  }

  Future<int> deleteProductsByCategory(String category) async {
    final db = await _dbHelper.database;
    return db.delete(
      'products',
      where: 'category = ?',
      whereArgs: [category],
    );
  }


  // Menambahkan fungsi getAllProducts()
  Future<List<Product>> getAllProducts() async {
    final db = await _dbHelper.database;
    final result = await db.query('products');
    return result.map((e) => Product.fromMap(e)).toList();
  }
}