import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter/services.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _biometricEnabledKey = 'biometric_enabled';

  /// Check if the device supports biometrics at all
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  /// Check if biometrics are available AND enrolled on the device
  Future<bool> canAuthenticate() async {
    try {
      final bool isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported) return false;

      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) return false;

      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();

      return availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Returns the list of available biometric types on this device
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Perform the actual biometric authentication prompt
  /// Returns true if authentication succeeded, false otherwise
  Future<bool> authenticate() async {
    try {
      final bool canAuth = await canAuthenticate();
      if (!canAuth) return false;

      final bool authenticated = await _localAuth.authenticate(
        localizedReason:
            'Use your fingerprint or face ID to securely access the dashboard',
        options: const AuthenticationOptions(
          stickyAuth: true,       // keeps the prompt alive if app goes to background
          biometricOnly: false,   // allow PIN/pattern fallback on Android
          useErrorDialogs: true,  // show system error dialogs automatically
          sensitiveTransaction: false,
        ),
      );

      return authenticated;
    } on PlatformException catch (e) {
      // Handle specific error codes
      if (e.code == auth_error.notAvailable) {
        // Biometrics not available on this device
        return false;
      } else if (e.code == auth_error.notEnrolled) {
        // User has not enrolled any biometrics
        return false;
      } else if (e.code == auth_error.lockedOut ||
          e.code == auth_error.permanentlyLockedOut) {
        // Too many failed attempts
        return false;
      } else if (e.code == auth_error.passcodeNotSet) {
        // Device has no lock screen set up
        return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Save user preference: biometrics enabled
  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(
      key: _biometricEnabledKey,
      value: enabled.toString(),
    );
  }

  /// Read user preference: did user opt in to biometrics?
  Future<bool> isBiometricEnabled() async {
    try {
      final String? value =
          await _secureStorage.read(key: _biometricEnabledKey);
      return value == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Full flow: check preference + hardware + authenticate
  /// Use this in your biometric_screen.dart
  Future<BiometricResult> authenticateWithBiometrics() async {
    // 1. Check hardware support
    final bool supported = await isDeviceSupported();
    if (!supported) {
      return BiometricResult(
        success: false,
        errorMessage: 'This device does not support biometric authentication.',
      );
    }

    // 2. Check if biometrics are enrolled
    final bool canAuth = await canAuthenticate();
    if (!canAuth) {
      return BiometricResult(
        success: false,
        errorMessage:
            'No biometrics enrolled. Please set up fingerprint or face ID in your device settings.',
      );
    }

    // 3. Prompt the user
    try {
      final bool result = await authenticate();

      if (result) {
        // Optionally save preference so next launch auto-prompts
        await setBiometricEnabled(true);
        return BiometricResult(success: true);
      } else {
        return BiometricResult(
          success: false,
          errorMessage: 'Biometric authentication failed.',
        );
      }
    } catch (e) {
      return BiometricResult(
        success: false,
        errorMessage: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Cancel any in-progress authentication
  Future<void> cancelAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (_) {}
  }
}

/// Simple result model returned from authenticateWithBiometrics()
class BiometricResult {
  final bool success;
  final String? errorMessage;

  BiometricResult({
    required this.success,
    this.errorMessage,
  });
}