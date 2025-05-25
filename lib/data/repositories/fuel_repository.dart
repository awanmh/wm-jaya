// lib/data/repositories/fuel_repository.dart
import 'package:wm_jaya/data/local_db/database_helper.dart';
import 'package:wm_jaya/data/models/fuel.dart';
import 'package:wm_jaya/utils/date_range.dart';

class FuelRepository {
  final DatabaseHelper _dbHelper;

  FuelRepository(this._dbHelper);

  Future<int> addFuelPurchase(Fuel fuel) async {
    final db = await _dbHelper.database;
    return db.insert('fuels', fuel.toMap());
  }

  Future<List<Fuel>> getFuelHistory() async {
    final db = await _dbHelper.database;
    final result = await db.query('fuels');
    return result.map((e) => Fuel.fromMap(e)).toList();
  }

  Future<List<Fuel>> getFuelPurchases(DateRange range) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'fuels',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [
        range.start.toIso8601String(),
        range.end.toIso8601String(),
      ],
    );
    return result.map((e) => Fuel.fromMap(e)).toList();
  }

  Future<void> deleteFuelPurchase(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'fuels',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markFuelReported(int fuelId) async {
    final db = await _dbHelper.database;
    await db.update(
      'fuels',
      {'reportGenerated': 1},
      where: 'id = ?',
      whereArgs: [fuelId],
    );
  }
}
