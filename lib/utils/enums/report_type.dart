
enum ReportType {
  daily,
  weekly,
  monthly,
  yearly,
  custom;

  String get label {
    switch (this) {
      case ReportType.daily:
        return 'Harian';
      case ReportType.weekly:
        return 'Mingguan';
      case ReportType.monthly:
        return 'Bulanan';
      case ReportType.yearly:
        return 'Tahunan';
      case ReportType.custom:
        return 'Kustom';
    }
  }

  String get value => name;

  static ReportType fromString(String value) {
    return ReportType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReportType.custom,
    );
  }
}