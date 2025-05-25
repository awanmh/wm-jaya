import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

mixin DBOperations {
  final DatabaseHelper dbHelper = DatabaseHelper();

  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await dbHelper.database;
    return db.insert(table, values);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await dbHelper.database;
    return db.query(
      table,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await dbHelper.database;
    return db.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await dbHelper.database;
    return db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await dbHelper.database;
    return db.transaction(action);
  }

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    final db = await dbHelper.database;
    return db.rawQuery(sql, arguments);
  }

  Future<int> rawInsert(String sql, [List<Object?>? arguments]) async {
    final db = await dbHelper.database;
    return db.rawInsert(sql, arguments);
  }

  Future<void> bulkInsert(
    String table,
    List<Map<String, dynamic>> valuesList,
  ) async {
    final db = await dbHelper.database;
    final batch = db.batch();
    for (final values in valuesList) {
      batch.insert(table, values);
    }
    await batch.commit();
  }

  Future<List<Map<String, dynamic>>> joinTables({
    required List<String> tables,
    required String joinCondition,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await dbHelper.database;
    final query = '''
      SELECT ${columns?.join(',') ?? '*'}
      FROM ${tables.join(' ')}
      ${where != null ? 'WHERE $where' : ''}
      ${orderBy != null ? 'ORDER BY $orderBy' : ''}
      ${limit != null ? 'LIMIT $limit' : ''}
    ''';
    
    return db.rawQuery(query, whereArgs);
  }

  Future<int> count(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM $table ${where != null ? 'WHERE $where' : ''}',
      whereArgs,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}