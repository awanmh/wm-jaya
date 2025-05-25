// lib/data/local_db/database_helper.dart
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:synchronized/synchronized.dart';
import 'package:wm_jaya/constants/app_constants.dart';
import 'package:wm_jaya/data/models/user.dart';
import 'package:wm_jaya/data/models/product.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  static final Lock _lock = Lock();

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    await _lock.synchronized(() async {
      _database ??= await _initDatabase();
    });
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'wm_jaya.db');

    return await openDatabase(
      dbPath,
      version: AppConstants.dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    print("📌 Creating database...");

    try {
      await db.execute('''
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT UNIQUE NOT NULL COLLATE NOCASE,
          passwordHash TEXT NOT NULL,
          salt TEXT NOT NULL,
          role TEXT NOT NULL CHECK(role IN ('admin', 'owner', 'cashier')),
          authToken TEXT,
          lastLogin INTEGER NOT NULL,
          createdAt INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
        )
      ''');

      await db.execute('''
        CREATE TABLE products(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category TEXT NOT NULL,
          name TEXT NOT NULL,
          stock INTEGER NOT NULL,
          price REAL NOT NULL,
          qrCode TEXT NOT NULL UNIQUE,
          imageUrl TEXT DEFAULT 'no_image',
          createdAt INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
        )
      ''');

      await db.execute('''
        CREATE TABLE orders(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          items TEXT NOT NULL,
          total REAL NOT NULL,
          payment REAL NOT NULL,
          "change" REAL NOT NULL,
          date TEXT NOT NULL,
          reportGenerated INTEGER NOT NULL DEFAULT 0
        )
      ''');

      await db.execute('''
        CREATE TABLE fuel_purchases (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          type TEXT NOT NULL,
          price REAL NOT NULL,
          liters REAL NOT NULL,
          date INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
        )
      ''');

      await db.execute('''
        CREATE TABLE reports (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          type TEXT NOT NULL,
          data TEXT NOT NULL,
          total REAL NOT NULL,
          date INTEGER NOT NULL,
          period INTEGER NOT NULL, // TAMBAHKAN KOLOM INI
          createdAt INTEGER NOT NULL
        )
      ''');

      await db.execute("CREATE INDEX IF NOT EXISTS idx_products_category ON products(category)");
      await db.execute("CREATE INDEX IF NOT EXISTS idx_users_username ON users(username)");

      print("✅ Database created successfully!");
    } catch (e) {
      print("❌ Error creating database: $e");
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print("🚀 Upgrading database from $oldVersion to $newVersion");

    try {
      if (oldVersion < 2) {
        await db.execute(
          "ALTER TABLE users ADD COLUMN createdAt INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))",
        );
        await db.execute(
          "ALTER TABLE products ADD COLUMN createdAt INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))",
        );
      }

      if (oldVersion < 3) {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS orders(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            items TEXT NOT NULL,
            total REAL NOT NULL,
            payment REAL NOT NULL,
            "change" REAL NOT NULL,
            date TEXT NOT NULL,
            reportGenerated INTEGER NOT NULL DEFAULT 0
          )
        ''');
        print("✅ Orders table created successfully!");
      }

      if (oldVersion < 4) {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS fuel_purchases (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            price REAL NOT NULL,
            liters REAL NOT NULL,
            date INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
          )
        ''');
        print("✅ Fuel Purchases table created successfully!");
      }

      if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS reports(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          type TEXT NOT NULL,
          data TEXT NOT NULL,
          total REAL NOT NULL,
          date INTEGER NOT NULL,
          period INTEGER NOT NULL, // PASTIKAN KOLOM INI ADA
          createdAt INTEGER NOT NULL
        )
      ''');
        print("✅ Reports table created successfully!");
      }
      if (oldVersion < 6) {
        // Tambahkan kolom yang mungkin hilang
        await db.execute('ALTER TABLE reports ADD COLUMN period INTEGER NOT NULL DEFAULT 0');
        await db.execute('ALTER TABLE reports ADD COLUMN data TEXT NOT NULL DEFAULT ""');
        print('✅ Added missing columns to reports table');
      }
    } catch (e) {
      print("❌ Error upgrading database: $e");
    }
  }

  // ==================== USER OPERATIONS ====================
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert(
      'users',
      user.toMap()..putIfAbsent('createdAt', () => DateTime.now().millisecondsSinceEpoch),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<User>> getUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return maps.map((map) => User.fromMap(map)).toList();
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final maps = await db.query('users', where: 'username = ?', whereArgs: [username], limit: 1);
    return maps.isNotEmpty ? User.fromMap(maps.first) : null;
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    return maps.isNotEmpty ? User.fromMap(maps.first) : null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> updatePassword(int id, String newPasswordHash, String salt) async {
    final db = await database;
    return await db.update(
      'users',
      {'passwordHash': newPasswordHash, 'salt': salt},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== PRODUCT OPERATIONS ====================
  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert(
      'products',
      product.toMap()..putIfAbsent('createdAt', () => DateTime.now().millisecondsSinceEpoch),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    final db = await database;
    final maps = await db.query('products', where: 'category = ?', whereArgs: [category]);
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  // ==================== ORDER OPERATIONS ====================
  Future<int> insertOrder(Map<String, dynamic> order) async {
    final db = await database;
    return await db.insert('orders', order);
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    final db = await database;
    return await db.query('orders');
  }

  Future<void> close() async {
    if (_database != null) await _database!.close();
    _database = null;
  }

  // ==================== FUEL PURCHASES OPERATIONS ====================
  Future<int> insertFuelPurchase(Map<String, dynamic> purchase) async {
    final db = await database;
    return await db.insert('fuel_purchases', purchase);
  }

  Future<List<Map<String, dynamic>>> getFuelPurchases() async {
    final db = await database;
    return await db.query('fuel_purchases');
  }

  Future<List<Map<String, dynamic>>> getFuelPurchasesByDate(int startDate, int endDate) async {
    final db = await database;
    return await db.query('fuel_purchases', where: 'date >= ? AND date <= ?', whereArgs: [startDate, endDate]);
  }

  // ==================== REPORT OPERATIONS ====================
  Future<List<Map<String, dynamic>>> getReportsByDate(DateTime start, DateTime end) async {
    final db = await database;
    return await db.query(
      'reports',
      where: 'createdAt BETWEEN ? AND ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
    );
  }
  Future<int> deleteReport(int id) async {
    final db = await database;
    return await db.delete(
      'reports',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}