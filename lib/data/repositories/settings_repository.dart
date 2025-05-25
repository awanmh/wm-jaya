import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsRepository {
  Future<ThemeMode> getThemePreference();
  Future<void> saveThemePreference(ThemeMode mode);
  Future<String> getBackupData();
  Future<void> restoreFromBackup(String data);
}

class SettingsRepositoryImpl implements SettingsRepository {
  final SharedPreferences prefs;
  final String _themeKey = 'theme_mode';

  SettingsRepositoryImpl(this.prefs);

  @override
  Future<ThemeMode> getThemePreference() async {
    try {
      final mode = prefs.getString(_themeKey);
      return ThemeMode.values.firstWhere(
        (e) => e.toString() == 'ThemeMode.$mode',
        orElse: () => ThemeMode.system,
      );
    } catch (e) {
      throw Exception('Gagal memuat preferensi tema');
    }
  }

  @override
  Future<void> saveThemePreference(ThemeMode mode) async {
    try {
      await prefs.setString(_themeKey, mode.toString().split('.').last);
    } catch (e) {
      throw Exception('Gagal menyimpan preferensi tema');
    }
  }

  @override
  @override
Future<String> getBackupData() async {
  try {
    final themeMode = await getThemePreference();
    final data = {
      'version': '1.0',
      'last_backup': DateTime.now().toIso8601String(),
      'theme_mode': themeMode.toString().split('.').last,
      // Tambahkan data lain yang perlu di-backup
    };
    return jsonEncode(data);
  } catch (e) {
    throw Exception('Gagal membuat data backup');
  }
}

  @override
  Future<void> restoreFromBackup(String data) async {
  try {
    final jsonData = jsonDecode(data);
    
    // Validasi struktur data
    if (jsonData['version'] == null || jsonData['theme_mode'] == null) {
      throw FormatException('Format backup tidak valid');
    }

    // Restore tema
    final themeMode = ThemeMode.values.firstWhere(
      (e) => e.toString().split('.').last == jsonData['theme_mode'],
      orElse: () => ThemeMode.system,
    );
    await saveThemePreference(themeMode);

    // Tambahkan logika restore data lain di sini
    // Contoh: await restoreProducts(jsonData['products']);

  } on FormatException catch (e) {
    throw Exception('Format backup tidak valid: ${e.message}');
  } catch (e) {
    throw Exception('Gagal memulihkan backup: ${e.toString()}');
  }
}
}