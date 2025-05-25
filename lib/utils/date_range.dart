// File: lib/utils/date_range.dart
import 'package:flutter/material.dart';

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});

  // Converter dari Flutter's DateTimeRange ke DateRange
  factory DateRange.fromDateTimeRange(DateTimeRange range) {
    return DateRange(
      start: range.start,
      end: range.end,
    );
  }

  // Mengonversi kembali ke DateTimeRange (opsional)
  DateTimeRange toDateTimeRange() {
    return DateTimeRange(start: start, end: end);
  }
}
