// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:wm_jaya/data/models/user.dart';
import 'package:wm_jaya/data/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _repository;
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._repository);

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> login(String username, String password) async {
    _setLoading(true);
    _clearError();
    try {
      _currentUser = await _repository.login(username, password);
      notifyListeners();
    } catch (e) {
      _handleError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _repository.logout();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _handleError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> checkAuthStatus() async {
    _setLoading(true);
    try {
      _currentUser = await _repository.getCurrentUser();
      notifyListeners();
    } catch (e) {
      _handleError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners(); // Langsung panggil notifyListeners()
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners(); // Langsung panggil notifyListeners()
  }

  void _handleError(String message) {
    _errorMessage = message;
    notifyListeners(); // Langsung panggil notifyListeners()
  }
}
