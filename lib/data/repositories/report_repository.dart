// lib/data/repositories/report_repository.dart
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:wm_jaya/data/local_db/database_helper.dart';
import 'package:wm_jaya/data/models/report.dart';
import 'package:wm_jaya/utils/date_range.dart';

class ReportRepository {
  final DatabaseHelper _dbHelper;

  ReportRepository(this._dbHelper);

  // ==================== CORE REPORT OPERATIONS ====================
  Future<Report> generateReport(Report report) async {
    final db = await _dbHelper.database;
    final id = await db.insert('reports', report.toMap());
    return report.copyWith(id: id);
  }

  Future<List<Report>> getReports(DateRange range) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'reports',
      where: 'createdAt BETWEEN ? AND ?',
      whereArgs: [
        range.start.millisecondsSinceEpoch,
        range.end.millisecondsSinceEpoch,
      ],
    );
    return result.map((map) => Report.fromMap(map)).toList();
  }

  // ==================== SALES REPORT ====================
  Future<Map<String, dynamic>> getSalesReport(DateRange range) async {
    final salesData = await _getRawSalesData(range);
    return _processSalesData(salesData);
  }

  Future<List<Map<String, dynamic>>> _getRawSalesData(DateRange range) async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT 
        strftime('%Y-%m-%d', datetime(o.date / 1000, 'unixepoch')) as date,
        p.category,
        SUM(oi.quantity) as total_quantity,
        SUM(oi.quantity * p.price) as total_sales
      FROM orders o
      JOIN order_items oi ON o.id = oi.order_id
      JOIN products p ON oi.product_id = p.id
      WHERE o.date BETWEEN ? AND ?
      GROUP BY date, p.category
    ''', [
      range.start.millisecondsSinceEpoch,
      range.end.millisecondsSinceEpoch,
    ]);
  }

  // ==================== FUEL REPORT ====================
  Future<Map<String, dynamic>> getFuelReport(DateRange range) async {
    final fuelData = await _getRawFuelData(range);
    return _processFuelData(fuelData);
  }

  Future<List<Map<String, dynamic>>> getFuelHistory(DateRange range) async {
    final db = await _dbHelper.database;
    return await db.query(
      'fuel_purchases',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [
        range.start.millisecondsSinceEpoch,
        range.end.millisecondsSinceEpoch,
      ],
    );
  }

  Future<List<Map<String, dynamic>>> _getRawFuelData(DateRange range) async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT 
        type,
        SUM(liters) as total_liters,
        SUM(price * liters) as total_cost
      FROM fuel_purchases
      WHERE date BETWEEN ? AND ?
      GROUP BY type
    ''', [
      range.start.millisecondsSinceEpoch,
      range.end.millisecondsSinceEpoch,
    ]);
  }

  // ==================== DATA PROCESSING ====================
  Map<String, dynamic> _processSalesData(List<Map<String, dynamic>> data) {
    final result = _initializeSalesReport();
    
    for (final row in data) {
      final date = row['date'] as String;
      final category = row['category'] as String;
      final quantity = (row['total_quantity'] as int?) ?? 0;
      final sales = (row['total_sales'] as num?)?.toDouble() ?? 0.0;

      _updateSalesResult(result, date, category, quantity, sales);
    }
    
    return result;
  }

  Map<String, dynamic> _initializeSalesReport() {
    return {
      'totalSales': 0.0,
      'totalItemsSold': 0,
      'dailySales': {},
    };
  }

  void _updateSalesResult(
    Map<String, dynamic> result,
    String date,
    String category,
    int quantity,
    double sales,
  ) {
    // Initialize date entry if not exists
    if (!result['dailySales'].containsKey(date)) {
      result['dailySales'][date] = {
        'total': 0.0,
        'categories': {},
      };
    }

    // Update daily totals
    result['dailySales'][date]['total'] += sales;
    result['dailySales'][date]['categories'][category] = {
      'quantity': quantity,
      'sales': sales,
    };

    // Update global totals
    result['totalSales'] += sales;
    result['totalItemsSold'] += quantity;
  }

  Map<String, dynamic> _processFuelData(List<Map<String, dynamic>> data) {
    final result = _initializeFuelReport();
    
    for (final row in data) {
      final type = row['type'] as String;
      final liters = (row['total_liters'] as num?)?.toDouble() ?? 0.0;
      final cost = (row['total_cost'] as num?)?.toDouble() ?? 0.0;

      _updateFuelResult(result, type, liters, cost);
    }
    
    return result;
  }

  Map<String, dynamic> _initializeFuelReport() {
    return {
      'totalLiters': 0.0,
      'totalCost': 0.0,
      'types': {},
    };
  }

  void _updateFuelResult(
    Map<String, dynamic> result,
    String type,
    double liters,
    double cost,
  ) {
    result['types'][type] = {
      'liters': liters,
      'cost': cost,
    };
    result['totalLiters'] += liters;
    result['totalCost'] += cost;
  }

  // ==================== FILE OPERATIONS ====================
  Future<void> exportReportToFile(Report report) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final reportDir = Directory('${directory.path}/reports');
      
      if (!await reportDir.exists()) {
        await reportDir.create(recursive: true);
      }
      
      final file = File('${reportDir.path}/${report.id}.json');
      await file.writeAsString(json.encode(report.toMap()));
    } catch (e) {
      throw Exception('Gagal ekspor laporan: ${e.toString()}');
    }
  }

  Future<List<Report>> getSavedReportsFromFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final reportDir = Directory('${directory.path}/reports');
      
      if (!await reportDir.exists()) return [];
      
      final entities = await reportDir.list().toList();
      final files = entities.whereType<File>().toList();
      final reports = await Future.wait(
        files.map((file) => _parseReportFile(file)),
      );
      return reports;
    } catch (e) {
      throw Exception('Gagal memuat laporan: ${e.toString()}');
    }
  }

  Future<Report> _parseReportFile(File file) async {
    try {
      final contents = await file.readAsString();
      return Report.fromMap(json.decode(contents));
    } catch (e) {
      throw Exception('File korup: ${file.path}');
    }
  }

  Future<void> deleteReport(Report report) async {
    final db = await _dbHelper.database;
    
    await db.delete(
      'reports',
      where: 'id = ?',
      whereArgs: [report.id],
    );

    await _deleteReportFile(report.id!);
  }

  Future<void> _deleteReportFile(int reportId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/reports/$reportId.json');
      if (await file.exists()) await file.delete();
    } catch (e) {
      throw Exception('Gagal hapus file laporan: ${e.toString()}');
    }
  }
}