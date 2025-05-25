// lib/features/auth/presentation/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:wm_jaya/data/models/user.dart';
import 'package:wm_jaya/data/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository;
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._authRepository);

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> login(String username, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authRepository.login(username, password);
      _currentUser = user;
      _notifyListeners();
    } catch (e) {
      _handleError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepository.logout();
      _currentUser = null;
      _notifyListeners();
    } catch (e) {
      _handleError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> checkAuthStatus() async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        _notifyListeners();
      }
    } catch (e) {
      _handleError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  // di auth_provider.dart
Future<void> resetPassword({
  required String username,
  required String newPassword,
}) async {
  _setLoading(true);
  _clearError();

  try {
    await _authRepository.resetPassword(
      username: username,
      newPassword: newPassword,
    );
    _notifyListeners();
  } catch (e) {
    _handleError(e.toString());
    rethrow;
  } finally {
    _setLoading(false);
  }
}

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    _notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    _notifyListeners();
  }

  void _handleError(String message) {
    _errorMessage = message;
    _notifyListeners();
  }

  void _notifyListeners() {
    if (!_isLoading) {
      notifyListeners();
    }
  }
}