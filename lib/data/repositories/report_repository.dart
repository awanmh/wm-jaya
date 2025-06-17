// lib/data/repositories/report_repository.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wm_jaya/data/local_db/database_helper.dart';
import 'package:wm_jaya/data/models/report.dart';
import 'package:wm_jaya/utils/date_range.dart';
import 'package:wm_jaya/utils/helpers/date_formatter.dart';

class ReportRepository {
  final DatabaseHelper _dbHelper;

  ReportRepository(this._dbHelper);

  // =================================================================
  // === FUNGSI YANG DIPERBAIKI SECARA MENYELURUH ===
  // =================================================================
  /// Mengambil detail laporan dan memastikan rincian transaksi (sales & fuel)
  /// ikut terbaca dan diproses dengan benar.
  Future<Report> getReportById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'reports',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      throw Exception('Laporan dengan ID $id tidak ditemukan.');
    }

    // 1. Ambil data mentah dari database
    final rawReportMap = maps.first;
    
    // 2. Buat objek Report ringkasan terlebih dahulu
    final summaryReport = Report.fromMap(rawReportMap);

    // 3. Decode string JSON dari kolom 'data' menjadi Map
    final Map<String, dynamic> dataMap = json.decode(rawReportMap['data'] as String);

    // 4. Proses dan validasi item dari 'sales' dan 'fuel'
    final List<Map<String, dynamic>> salesItems = _parseItems(dataMap['sales']?['items']);
    final List<Map<String, dynamic>> fuelItems = _parseItems(dataMap['fuel']?['items']);

    // 5. Buat ulang map 'data' dengan rincian yang sudah diproses
    final sanitizedData = {
      'sales': {'items': salesItems},
      'fuel': {'items': fuelItems},
    };
    
    // 6. Kembalikan objek Report lengkap dengan data yang sudah bersih
    return summaryReport.copyWith(data: sanitizedData);
  }

  /// Helper untuk mem-parsing dan membersihkan daftar item (sales/fuel).
  List<Map<String, dynamic>> _parseItems(dynamic items) {
    if (items == null || items is! List) {
      return []; // Kembalikan list kosong jika tidak ada item atau format salah
    }
    
    final List<Map<String, dynamic>> parsedList = [];
    for (final item in items) {
      if (item is Map) {
        parsedList.add({
          'product': item['product']?.toString() ?? 'N/A',
          'quantity': (item['quantity'] as num?)?.toDouble() ?? 0.0,
          'price': (item['price'] as num?)?.toDouble() ?? 0.0,
        });
      }
    }
    return parsedList;
  }
  
  // =================================================================
  // === SISA KODE (Tidak ada perubahan) ===
  // =================================================================

  Future<List<Report>> getReports(DateRange range) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'reports',
      where: 'createdAt >= ? AND createdAt < ?',
      whereArgs: [
        range.start.millisecondsSinceEpoch,
        range.end.millisecondsSinceEpoch,
      ],
       orderBy: 'createdAt DESC',
    );
    return result.map((map) => Report.fromMap(map)).toList();
  }
  
  Future<void> deleteReport(Report report) async {
    final db = await _dbHelper.database;
    await db.delete('reports', where: 'id = ?', whereArgs: [report.id]);
    await _deleteReportFile(report.id!);
  }
  
  Future<Report> generateReport(Report report) async {
    final db = await _dbHelper.database;
    final id = await db.insert('reports', report.toMap());
    return report.copyWith(id: id);
  }

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
      final reports = await Future.wait(files.map((file) => _parseReportFile(file)));
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
