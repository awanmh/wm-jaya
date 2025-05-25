// lib/utils/helpers/date_formatter.dart
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class DateFormatter {
  // Format dasar dengan locale Indonesia
  static DateFormat _baseFormatter(String pattern, [String? locale]) => 
    DateFormat(pattern, locale ?? 'id_ID');

  /* *********************
   * FORMAT TANGGAL STANDAR
   * *********************/
  
  static String format(
    DateTime? date, {
    String pattern = 'dd/MM/yyyy',
    String? locale,
  }) {
    return date != null 
        ? _baseFormatter(pattern, locale).format(date)
        : 'Tanggal tidak valid';
  }

  static String formatDateTime(
    DateTime? date, {
    String pattern = 'dd/MM/yyyy, HH:mm:ss',
    String? locale,
  }) {
    return date != null 
        ? _baseFormatter(pattern, locale).format(date)
        : 'Tanggal tidak valid';
  }

  static String formatTime(
    DateTime? date, {
    String pattern = 'HH:mm:ss',
    String? locale,
  }) {
    return date != null 
        ? _baseFormatter(pattern, locale).format(date)
        : 'Waktu tidak valid';
  }

  /* *********************
   * MANIPULASI RENTANG WAKTU
   * *********************/
  
  // Mendapatkan rentang minggu (default mulai Senin)
  static DateTimeRange currentWeek({bool startWithMonday = true}) {
    final now = DateTime.now();
    return _calculateWeekRange(now, startWithMonday);
  }

  static DateTimeRange getWeekRange(DateTime date, {bool startWithMonday = true}) {
    return _calculateWeekRange(date, startWithMonday);
  }

  static DateTimeRange _calculateWeekRange(DateTime date, bool startWithMonday) {
    DateTime start;
    
    if (startWithMonday) {
      start = date.subtract(Duration(days: date.weekday - 1));
    } else {
      // Jika minggu dimulai Minggu (weekday=7)
      start = date.subtract(Duration(days: date.weekday % 7));
    }

    final end = start.add(const Duration(days: 6)).endOfDay;
    return DateTimeRange(start: start.startOfDay, end: end);
  }

  // Header untuk tampilan mingguan (contoh: "24 Mar - 30 Mar 2024")
  static String formatWeeklyHeader(DateTimeRange week, {String? locale}) {
    final startFormat = week.start.month == week.end.month ? 'dd MMM' : 'dd MMM yyyy';
    return '${_baseFormatter(startFormat, locale).format(week.start)} - '
           '${_baseFormatter('dd MMM yyyy', locale).format(week.end)}';
  }

  /* *********************
   * RELATIVE DATE FORMATTER
   * *********************/
  
  static String relativeDate(DateTime date, {bool shortForm = false}) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return _handleToday(date, now, shortForm);
    } else if (difference.inDays == 1) {
      return shortForm ? 'Kemarin' : 'Kemarin';
    } else if (difference.inDays > 1) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inDays == -1) {
      return 'Besok';
    } else {
      return 'Dalam ${difference.inDays.abs()} hari';
    }
  }

  static String _handleToday(DateTime date, DateTime now, bool shortForm) {
    final timeDiff = now.difference(date);
    
    if (timeDiff.inHours > 1) return '${timeDiff.inHours} jam lalu';
    if (timeDiff.inMinutes > 1) return '${timeDiff.inMinutes} menit lalu';
    if (timeDiff.inSeconds > 10) return '${timeDiff.inSeconds} detik lalu';
    return shortForm ? 'Baru saja' : 'Beberapa detik lalu';
  }

  /* *********************
   * UTILITAS TAMBAHAN
   * *********************/
  
  // Format rentang tanggal (contoh: "24 Mar 2024 - 30 Mar 2024")
  static String formatDateRange(
    DateTime? startDate,
    DateTime? endDate, {
    String pattern = 'dd MMM yyyy',
    String? locale,
  }) {
    if (startDate == null || endDate == null) return 'Rentang tidak valid';
    return '${format(startDate, pattern: pattern, locale: locale)} - '
           '${format(endDate, pattern: pattern, locale: locale)}';
  }

  // Mendapatkan awal hari (00:00:00.000)
  static DateTime get startOfDay => DateTime.now().startOfDay;

  // Mendapatkan akhir hari (23:59:59.999)
  static DateTime get endOfDay => DateTime.now().endOfDay;

  // Mendapatkan tanggal awal bulan
  static DateTime get startOfMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  // Mendapatkan tanggal akhir bulan
  static DateTime get endOfMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0);
  }
}

/* *********************
 * EXTENSION UNTUK DATETIME
 * *********************/
extension DateTimeExtensions on DateTime {
  DateTime get startOfDay => DateTime(year, month, day);

  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  DateTime get startOfMonth => DateTime(year, month, 1);

  DateTime get endOfMonth => DateTime(year, month + 1, 0);
}