// lib/widgets/reports/report_table.dart
import 'package:flutter/material.dart';
import 'package:wm_jaya/utils/helpers/currency_formatter.dart';

class ReportTable extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final List<String> columns;

  const ReportTable({
    super.key,
    required this.data,
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columns.map((col) => DataColumn(label: Text(col))).toList(),
        rows: data.map((row) {
          return DataRow(
            cells: columns.map((col) {
              final value = row[col.toLowerCase()];
              return DataCell(
                Text(
                  value is num 
                  ? CurrencyFormatter.format(value) 
                  : value.toString(),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}