// lib/widgets/reports/report_card.dart
import 'package:flutter/material.dart';
import 'package:wm_jaya/utils/enums/report_type.dart';
import 'package:wm_jaya/utils/helpers/currency_formatter.dart';
import 'package:wm_jaya/utils/extensions/datetime_extension.dart';

class ReportCard extends StatelessWidget {
  final String title;
  final DateTime date;
  final double amount;
  final ReportType type;

  const ReportCard({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Chip(
                  label: Text(type.label),
                  backgroundColor: _getTypeColor(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
             Text('Tanggal: ${date.toFormattedString()}'), // Sekarang sudah valid
            Text('Jumlah: ${CurrencyFormatter.format(amount)}'), //undefined name 'CurrencyFormatter'.Try correcting the name to one that is defined
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(BuildContext context) {
    switch (type) {
      case ReportType.daily:
        return Colors.blue.shade100;
      case ReportType.weekly:
        return Colors.green.shade100;
      case ReportType.monthly:
        return Colors.orange.shade100;
      default:
        return Theme.of(context).colorScheme.surfaceContainerHighest;
    }
  }
}
