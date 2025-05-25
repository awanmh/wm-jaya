// lib/data/models/app_settings.dart
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final ThemeMode themeMode;
  final DateTime lastBackup;
  final String? backupLocation;
  final bool autoBackupEnabled;

  const AppSettings({
    required this.themeMode,
    required this.lastBackup,
    this.backupLocation,
    this.autoBackupEnabled = false,
  });

  factory AppSettings.initial() => AppSettings(
        themeMode: ThemeMode.system,
        lastBackup: DateTime(1970),
        autoBackupEnabled: false,
      );

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        themeMode: _parseThemeMode(json['theme_mode']),
        lastBackup: DateTime.parse(json['last_backup']),
        backupLocation: json['backup_location'],
        autoBackupEnabled: json['auto_backup_enabled'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'theme_mode': themeMode.name,
        'last_backup': lastBackup.toIso8601String(),
        'backup_location': backupLocation,
        'auto_backup_enabled': autoBackupEnabled,
      };

  AppSettings copyWith({
    ThemeMode? themeMode,
    DateTime? lastBackup,
    String? backupLocation,
    bool? autoBackupEnabled,
  }) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        lastBackup: lastBackup ?? this.lastBackup,
        backupLocation: backupLocation ?? this.backupLocation,
        autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      );

  static ThemeMode _parseThemeMode(String mode) => ThemeMode.values.firstWhere(
        (e) => e.name == mode,
        orElse: () => ThemeMode.system,
      );

  @override
  List<Object?> get props => [
        themeMode,
        lastBackup,
        backupLocation,
        autoBackupEnabled,
      ];

  @override
  String toString() => '''
AppSettings {
  themeMode: $themeMode,
  lastBackup: $lastBackup,
  backupLocation: $backupLocation,
  autoBackupEnabled: $autoBackupEnabled
}
''';
}