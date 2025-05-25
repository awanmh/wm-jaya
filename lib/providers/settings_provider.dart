import 'package:flutter/material.dart';
import 'package:wm_jaya/data/repositories/settings_repository.dart';
import 'package:wm_jaya/services/google_drive_service.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsRepository _repository;
  final GoogleDriveService _driveService;
  
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  SettingsProvider(this._repository, this._driveService);

  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;

  Future<void> initialize() async {
    try {
      _themeMode = await _repository.getThemePreference();
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> toggleTheme(ThemeMode newMode) async {
    try {
      await _repository.saveThemePreference(newMode);
      _themeMode = newMode;
      _successMessage = 'Tema berhasil diubah';
      _error = null;
    } catch (e) {
      _error = e.toString();
      _successMessage = null;
    }
    notifyListeners();
  }

  Future<void> backupToDrive() async {
    _setLoading(true);
    try {
      final data = await _repository.getBackupData();
      await _driveService.uploadFile(data);
      _successMessage = 'Backup berhasil ke Google Drive';
      _error = null;
    } catch (e) {
      _error = 'Gagal backup: ${e.toString()}';
      _successMessage = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> restoreFromDrive() async {
    _setLoading(true);
    try {
      final data = await _driveService.downloadFile();
      await _repository.restoreFromBackup(data);
      _successMessage = 'Restore data berhasil';
      _error = null;
    } catch (e) {
      _error = 'Gagal restore: ${e.toString()}';
      _successMessage = null;
    } finally {
      _setLoading(false);
    }
  }

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}