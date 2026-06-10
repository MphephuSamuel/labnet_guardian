import 'dart:convert';

import '../models/app_user.dart';
import 'api_client.dart';

class UsersService {
  Future<void> requestPasswordReset(String email) async {
    final response = await ApiClient.post('/api/users/password/forgot', {
      'email': email,
    });

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        _extractError(
          response.body,
          fallback: 'Failed to request password reset',
        ),
      );
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await ApiClient.put('/api/users/me/password', {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    });

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        _extractError(response.body, fallback: 'Failed to change password'),
      );
    }
  }

  Future<List<AppUser>> fetchUsers() async {
    final response = await ApiClient.get('/users');

    if (response.statusCode != 200) {
      throw Exception(
        _extractError(response.body, fallback: 'Failed to load users'),
      );
    }

    final decoded = jsonDecode(response.body);
    final rawUsers = (decoded is Map<String, dynamic>)
        ? decoded['users']
        : null;

    if (rawUsers is! List) {
      return [];
    }

    return rawUsers
        .whereType<Map<String, dynamic>>()
        .map(AppUser.fromJson)
        .toList();
  }

  Future<void> createAdmin({
    required String firstName,
    required String secondName,
    required String lastName,
    required String role,
    required String email,
  }) async {
    final response = await ApiClient.post('/users/signup', {
      'firstName': firstName,
      'secondName': secondName,
      'lastName': lastName,
      'role': role,
      'email': email,
    });

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        _extractError(response.body, fallback: 'Failed to create admin'),
      );
    }
  }

  String _extractError(String body, {required String fallback}) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
      }
    } catch (_) {
      // ignore parse errors and use fallback
    }
    return fallback;
  }
}
