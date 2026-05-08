import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get role => _profile?['role'];

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.login(email, password);
      if (user != null) {
        _profile = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = 'Invalid email or password.';
    } catch (e) {
      _errorMessage = 'Connection error. Make sure Laragon is running.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await _authService.logout();
    _profile = null;
    notifyListeners();
  }

  Future<void> loadProfile() async {
    _profile = await _authService.getCurrentProfile();
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final cached = await _authService.getCachedUser();
    if (cached != null) {
      _profile = cached;
      notifyListeners();
      return true;
    }
    return false;
  }
}
