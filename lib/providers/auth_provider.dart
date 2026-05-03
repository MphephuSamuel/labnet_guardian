import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  String? _token;
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;

  Future<void> signIn(String email, String password) async {
    try {
      final user = await _authService.signIn(email, password);
      if (user != null) {
        _token = await _authService.getToken();
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _token = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> loadToken() async {
    _token = await _authService.getToken();
    _isAuthenticated = _token != null;
    notifyListeners();
  }
}
