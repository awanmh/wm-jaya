// lib/data/models/report.dart
import 'dart:convert';
import 'package:flutter/material.dart';

class Report {
  final int? id;
  final ReportType type;
  final Map<String, dynamic> data;
  final double total;
  final DateTime date;
  final DateTime period;
  final DateTime createdAt;

  Report({
    this.id,
    required this.type,
    required this.data,
    required this.total,
    required this.date,
    required this.period,
    required this.createdAt,
  });

  // Salin data dengan perubahan
  Report copyWith({
    int? id,
    ReportType? type,
    Map<String, dynamic>? data,
    double? total,
    DateTime? date,
    DateTime? period,
    DateTime? createdAt,
  }) {
    return Report(
      id: id ?? this.id,
      type: type ?? this.type,
      data: data ?? this.data,
      total: total ?? this.total,
      date: date ?? this.date,
      period: period ?? this.period,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Konversi dari Map ke Report dengan validasi data
  factory Report.fromMap(Map<String, dynamic> map) {
    final rawData = map['data'] != null 
        ? json.decode(map['data']) as Map<String, dynamic>
        : <String, dynamic>{};
    
    return Report(
      id: map['id'] as int?,
      type: ReportType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ReportType.daily,
      ),
      data: _sanitizeData(rawData), // ✅ Proses data items
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int? ?? 0),
      period: DateTime.fromMillisecondsSinceEpoch(map['period'] as int? ?? 0),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int? ?? 0),
    );
  }

  // Konversi ke Map untuk database
  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'type': type.name,
        'data': json.encode(data),
        'total': total,
        'date': date.millisecondsSinceEpoch,
        'period': period.millisecondsSinceEpoch,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  // Sanitasi data items
  static Map<String, dynamic> _sanitizeData(Map<String, dynamic> rawData) {
    final sanitizedData = Map<String, dynamic>.from(rawData);
    
    // Proses items jika ada
    if (sanitizedData.containsKey('items')) {
      sanitizedData['items'] = _parseItems(sanitizedData['items']);
    }
    
    return sanitizedData;
  }

  // Validasi tipe data items
  static List<Map<String, dynamic>> _parseItems(dynamic items) {
    if (items is! List) return [];
    
    return items.map((item) {
      return {
        'product': item['product']?.toString() ?? 'Produk Tidak Diketahui',
        'quantity': (item['quantity'] as num?)?.toInt() ?? 0,
        'price': (item['price'] as num?)?.toDouble() ?? 0.0,
      };
    }).toList();
  }

  // Getter untuk rentang tanggal
  DateTimeRange get dateRange {
    switch (type) {
      case ReportType.daily:
        return DateTimeRange(
          start: period,
          end: period.add(const Duration(days: 1)),
        );
      case ReportType.weekly:
        return DateTimeRange(
          start: period.subtract(Duration(days: period.weekday - 1)),
          end: period.add(Duration(days: DateTime.daysPerWeek - period.weekday)),
        );
      case ReportType.monthly:
        return DateTimeRange(
          start: DateTime(period.year, period.month, 1),
          end: DateTime(period.year, period.month + 1, 1)
              .subtract(const Duration(days: 1)),
        );
    }
  }
}

enum ReportType { daily, weekly, monthly }