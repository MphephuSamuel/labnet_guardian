import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dart:developer';

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
        log('User logged in', name: 'auth');
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (e) {
      log('Login failed: $e', name: 'auth', error: e);
      throw Exception(
        'Login failed. Please check your credentials and try again.',
      );
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
    debugPrint('Loaded Token: $_token'); // Debug print to confirm token loading
    _isAuthenticated = _token != null;
    notifyListeners();
  }
}
