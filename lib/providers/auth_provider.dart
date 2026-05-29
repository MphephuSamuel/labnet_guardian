import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import 'dart:developer';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  String? _token;
  bool _isAuthenticated = false;

  String _tokenPreview(String token) {
    const previewLength = 20;
    if (token.length <= previewLength) {
      return token;
    }
    return '${token.substring(0, previewLength)}...';
  }

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;

  Future<void> signIn(String email, String password) async {
    try {
      final user = await _authService.signIn(email, password);
      if (user != null) {
        _token = await _authService.getToken();
        if (_token != null) {
          ApiClient.setToken(_token!);
        }
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

  Future<void> signInWithStoredCredentials() async {
    try {
      final user = await _authService.signInWithStoredCredentials();
      if (user != null) {
        _token = await _authService.getToken();
        if (_token != null) {
          ApiClient.setToken(_token!);
        }
        log('User logged in with stored credentials', name: 'auth');
        _isAuthenticated = true;
        notifyListeners();
      } else {
        throw Exception('No stored credentials found.');
      }
    } catch (e) {
      log('Stored credential login failed: $e', name: 'auth', error: e);
      _isAuthenticated = false;
      ApiClient.clearToken();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _token = null;
    _isAuthenticated = false;
    ApiClient.clearToken();
    notifyListeners();
  }

  Future<void> loadToken() async {
    _token = await _authService.getToken();
    if (_token != null) {
      // Set token in ApiClient for all requests
      // ignore: avoid_print
      print('Loaded ApiClient token preview: ${_tokenPreview(_token!)}');
      ApiClient.setToken(_token!);
      _isAuthenticated = true;
    } else {
      ApiClient.clearToken();
      _isAuthenticated = false;
    }
    notifyListeners();
  }
}
