// lib/utils/helpers/currency_formatter.dart
import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _format = NumberFormat.currency(
    symbol: 'Rp',
    decimalDigits: 0,
    locale: 'id_ID',
  );

  static String format(num value) {
    return _format.format(value);
  }
}