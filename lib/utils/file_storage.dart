import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:wm_jaya/data/models/report.dart';

class FileStorage {
  static final DateFormat _dateFormat = DateFormat('yyyyMMdd_HHmmss');

  static Future<File> saveReport(Report report) async {
    final content = _formatContent(report);
    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'REPORT_${report.type.name}_${_dateFormat.format(report.createdAt)}.txt';
    final file = File('${dir.path}/$fileName');
    return file.writeAsString(content);
  }

  static String _formatContent(Report report) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return '''
=== LAPORAN ${report.type.name.toUpperCase()} ===
Periode: ${DateFormat('dd MMM yyyy', 'id_ID').format(report.period)}
Total Penjualan: Rp${formatter.format(report.data['sales']['totalSales'])}
Total Bensin: ${report.data['fuel']['totalLiters']} Liter
Detail:
${_formatDetails(report.data)}
Dibuat pada: ${DateFormat('dd/MM/yyyy HH:mm', 'id_ID').format(report.createdAt)}
''';
  }

  static String _formatDetails(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    
    // Sales details
    buffer.writeln('Penjualan:');
    for (final category in data['sales']['byCategory'].keys) {
      buffer.writeln('- $category: ${data['sales']['byCategory'][category]['quantity']} pcs');
    }
    
    // Fuel details
    buffer.writeln('\nBensin:');
    for (final type in data['fuel']['byType'].keys) {
      buffer.writeln('- $type: ${data['fuel']['byType'][type]['liters']}L');
    }
    
    return buffer.toString();
  }

  static Future<List<File>> getSavedReports() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = await dir.list()
      .where((f) => f.path.endsWith('.txt'))
      .cast<File>()
      .toList();
    return files;
  }
}