// lib/data/repositories/auth_repository.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wm_jaya/data/local_db/database_helper.dart';
import 'package:wm_jaya/data/models/user.dart';
import 'package:wm_jaya/utils/helpers/security_helper.dart';

class AuthRepository {
  final DatabaseHelper _dbHelper;
  final FlutterSecureStorage _secureStorage;
  static const _authTokenKey = 'auth_token';
  static const _currentUserIdKey = 'current_user_id';

  AuthRepository(this._dbHelper, this._secureStorage);

  Future<User> login(String username, String password) async {
    try {
      final user = await _dbHelper.getUserByUsername(username);
      if (user == null) throw Exception('User tidak ditemukan');

      final isValidPassword = SecurityHelper.validatePassword(user, password);
      if (!isValidPassword) throw Exception('Password salah');

      final token = _generateAuthToken();
      await Future.wait([
        _secureStorage.write(key: _authTokenKey, value: token),
        _secureStorage.write(key: _currentUserIdKey, value: user.id.toString()),
      ]);

      final updatedUser = user.copyWith(authToken: token, lastLogin: DateTime.now());
      await _dbHelper.updateUser(updatedUser);

      return updatedUser;
    } catch (e) {
      throw Exception('Login gagal: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<void> logout() async {
    await Future.wait([
      _secureStorage.delete(key: _authTokenKey),
      _secureStorage.delete(key: _currentUserIdKey),
    ]);
  }

  Future<User?> getCurrentUser() async {
    try {
      final userId = await _secureStorage.read(key: _currentUserIdKey);
      if (userId == null || userId.isEmpty) return null;
      return await _dbHelper.getUserById(int.tryParse(userId) ?? 0);
    } catch (e) {
      throw Exception('Gagal mengambil data user: ${e.toString()}');
    }
  }

  Future<void> resetPassword({required String username, required String newPassword}) async {
    try {
      final user = await _dbHelper.getUserByUsername(username);
      if (user == null) throw Exception('User tidak ditemukan');

      final newSalt = SecurityHelper.generateSalt();
      final newHash = SecurityHelper.hashPassword(newPassword, newSalt);
      
      await _dbHelper.updatePassword(user.id, newHash, newSalt);
    } catch (e) {
      throw Exception('Gagal reset password: ${e.toString()}');
    }
  }

  String _generateAuthToken() {
    return base64UrlEncode(List<int>.generate(32, (_) => Random.secure().nextInt(256)));
  }
}
