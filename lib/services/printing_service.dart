// lib/services/printing_service.dart
import 'package:printing/printing.dart';
import 'dart:typed_data';

class PrintingService {
  static Future<void> printPdf(Uint8List pdfBytes) async {
    final info = await Printing.info();
    
    if (info.canPrint) {
      await Printing.layoutPdf(
        onLayout: (format) => pdfBytes,
      );
    } else {
      throw Exception('Printing not supported');
    }
  }
}