import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wm_jaya/data/models/order.dart';
import 'dart:io';

class PDFService {
  /// **Generate Receipt PDF sebagai Uint8List**
  static Future<Uint8List> generateReceipt(Order order) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Struk Pembelian', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('Tanggal: ${order.date}'),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['No', 'Item', 'Qty', 'Harga'],
              data: order.items.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final item = entry.value;
                return [
                  index.toString(),
                  item.product.name,
                  item.quantity.toString(),
                  'Rp ${item.product.price * item.quantity}',
                ];
              }).toList(),
            ),
            pw.Divider(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text('Total: Rp ${order.total}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  /// **Generate PDF dan Simpan ke File**
  static Future<File> generatePdf({
    required String title,
    required List<Map<String, dynamic>> data,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          children: [
            pw.Header(level: 0, child: pw.Text(title)),
            pw.TableHelper.fromTextArray(
              headers: ['No', 'Item', 'Quantity'],
              data: data.map((e) => [
                e['no'].toString(),
                e['item'].toString(),
                e['qty'].toString(),
              ]).toList(),
            ),
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$title.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }
}
