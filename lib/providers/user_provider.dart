import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../models/user_settings.dart';
import '../models/user_profile.dart';

class UserProvider with ChangeNotifier {
  UserProfile? _profile;
  UserSettings? _settings;
  List<String> _trustedIpRanges = [];
  List<String> _trustedMacAddresses = [];
  bool _isLoading = false;
  String? _error;

  UserProfile? get profile => _profile;
  UserSettings? get settings => _settings;
  List<String> get trustedIpRanges => _trustedIpRanges;
  List<String> get trustedMacAddresses => _trustedMacAddresses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all user profile, settings, and whitelist data
  Future<void> loadUserData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        loadProfile(),
        loadSettings(),
        loadWhitelist(),
      ]);
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user profile
  Future<void> loadProfile() async {
    try {
      final response = await ApiClient.get('/me');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['profile'] != null) {
          _profile = UserProfile.fromJson(data['profile']);
          notifyListeners();
        }
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in loadProfile: $e');
      rethrow;
    }
  }

  // Load settings
  Future<void> loadSettings() async {
    try {
      final response = await ApiClient.get('/api/users/me/settings');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['settings'] != null) {
          _settings = UserSettings.fromJson(data['settings']);
          notifyListeners();
        }
      } else {
        throw Exception('Failed to load settings: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in loadSettings: $e');
      rethrow;
    }
  }

  // Save full settings object
  Future<void> saveSettings(UserSettings newSettings) async {
    try {
      final response = await ApiClient.put('/api/users/me/settings', newSettings.toJson());
      if (response.statusCode == 200) {
        _settings = newSettings;
        notifyListeners();
      } else {
        throw Exception('Failed to save settings: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in saveSettings: $e');
      rethrow;
    }
  }

  // Update security configuration
  Future<void> updateSecuritySettings({
    required bool anomaly,
    required double sensitivity,
    required bool autoBlock,
    required bool simulation,
  }) async {
    try {
      final body = {
        'anomalyDetectionEnabled': anomaly,
        'detectionSensitivity': sensitivity,
        'autoBlockThreats': autoBlock,
        'simulationMode': simulation,
      };
      final response = await ApiClient.put('/api/users/me/settings/security', body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['securitySettings'] != null) {
          _settings?.security = SecuritySettings.fromJson(data['securitySettings']);
        } else {
          _settings?.security.anomalyDetectionEnabled = anomaly;
          _settings?.security.detectionSensitivity = sensitivity;
          _settings?.security.autoBlockThreats = autoBlock;
          _settings?.security.simulationMode = simulation;
        }
        notifyListeners();
      } else {
        throw Exception('Failed to update security settings: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in updateSecuritySettings: $e');
      rethrow;
    }
  }

  // Update notifications configuration
  Future<void> updateNotificationSettings({
    required bool email,
    required bool push,
  }) async {
    try {
      final body = {
        'emailAlerts': email,
        'pushNotifications': push,
      };
      final response = await ApiClient.put('/api/users/me/settings/notifications', body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['notificationSettings'] != null) {
          _settings?.notifications = NotificationSettings.fromJson(data['notificationSettings']);
        } else {
          _settings?.notifications.emailAlerts = email;
          _settings?.notifications.pushNotifications = push;
        }
        notifyListeners();
      } else {
        throw Exception('Failed to update notification settings: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in updateNotificationSettings: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String displayName,
    required String avatar,
  }) async {
    try {
      final body = {
        'firstName': firstName,
        'lastName': lastName,
        'displayName': displayName,
        'avatar': avatar,
      };
      final response = await ApiClient.put('/api/users/me/profile', body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['profile'] != null) {
          _profile = UserProfile.fromJson(data['profile']);
        } else {
          _profile?.firstName = firstName;
          _profile?.lastName = lastName;
          _profile?.displayName = displayName;
          _profile?.avatar = avatar;
        }
        notifyListeners();
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in updateProfile: $e');
      rethrow;
    }
  }

  // Load whitelist
  Future<void> loadWhitelist() async {
    try {
      final response = await ApiClient.get('/api/users/me/whitelist');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['whitelist'] != null) {
          final whitelistData = data['whitelist'];
          _trustedIpRanges = List<String>.from(whitelistData['trustedIpRanges'] ?? []);
          _trustedMacAddresses = List<String>.from(whitelistData['trustedMacAddresses'] ?? []);
          notifyListeners();
        }
      } else {
        throw Exception('Failed to load whitelist: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in loadWhitelist: $e');
      rethrow;
    }
  }

  // Add item to whitelist
  Future<void> addWhitelistItem({
    required String type,
    required String value,
  }) async {
    try {
      final body = {
        'type': type,
        'value': value,
      };
      final response = await ApiClient.post('/api/users/me/whitelist', body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['whitelist'] != null) {
          final whitelistData = data['whitelist'];
          _trustedIpRanges = List<String>.from(whitelistData['trustedIpRanges'] ?? []);
          _trustedMacAddresses = List<String>.from(whitelistData['trustedMacAddresses'] ?? []);
          notifyListeners();
        }
      } else {
        final errorMsg = jsonDecode(response.body)['message'] ?? 'Failed to add item to whitelist';
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('Error in addWhitelistItem: $e');
      rethrow;
    }
  }

  // Remove item from whitelist
  Future<void> removeWhitelistItem({
    required String type,
    required String value,
  }) async {
    try {
      final encodedValue = Uri.encodeComponent(value);
      final response = await ApiClient.delete('/api/users/me/whitelist/$encodedValue?type=$type');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['whitelist'] != null) {
          final whitelistData = data['whitelist'];
          _trustedIpRanges = List<String>.from(whitelistData['trustedIpRanges'] ?? []);
          _trustedMacAddresses = List<String>.from(whitelistData['trustedMacAddresses'] ?? []);
          notifyListeners();
        }
      } else {
        throw Exception('Failed to remove item from whitelist: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in removeWhitelistItem: $e');
      rethrow;
    }
  }
}
