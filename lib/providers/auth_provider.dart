import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  String? _token;
  bool _isAuthenticated = true;

  // Temporary development mode: bypass auth and let users log in by pressing the button.
  // Set to false when real authentication should be restored.
  static const bool useMockAuth = true;
  static const String mockToken = 'dev-token';

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;

  Future<void> signIn(String email, String password) async {
    try {
      if (useMockAuth) {
        _token = mockToken;
        _isAuthenticated = true;
        notifyListeners();
        return;
      }
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
