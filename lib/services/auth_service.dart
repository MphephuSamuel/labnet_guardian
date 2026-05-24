import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// ================================
  /// SIGN IN USER
  /// ================================
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // 🔥 FORCE REFRESH TOKEN (IMPORTANT FIX)
        final String token = (await user.getIdToken(true)) ?? "";

        // Save token securely
        await _storage.write(key: 'firebase_id_token', value: token);

        // Save credentials (for biometric login)
        await _storage.write(key: 'email', value: email);
        await _storage.write(key: 'password', value: password);

        print("✅ User signed in successfully");
        print("🔥 Token saved to secure storage");
      }

      return user;
    } catch (e) {
      print("❌ SignIn Error: $e");
      rethrow;
    }
  }

  /// ================================
  /// SIGN OUT USER
  /// ================================
  Future<void> signOut() async {
    await _auth.signOut();
    await _storage.delete(key: 'firebase_id_token');

    print("✅ User signed out");
  }

  /// ================================
  /// GET STORED TOKEN (FOR POSTMAN)
  /// ================================
  Future<String?> getToken() async {
    return await _storage.read(key: 'firebase_id_token');
  }

  /// ================================
  /// PRINT TOKEN (DEBUG TOOL 🔥)
  /// ================================
  Future<void> printToken() async {
    final token = await _storage.read(key: 'firebase_id_token');

    print("================================");
    print("🔥 FIREBASE ID TOKEN:");
    print(token);
    print("================================");
  }

  /// ================================
  /// GET STORED EMAIL
  /// ================================
  Future<String?> getStoredEmail() async {
    return await _storage.read(key: 'email');
  }

  /// ================================
  /// GET STORED PASSWORD
  /// ================================
  Future<String?> getStoredPassword() async {
    return await _storage.read(key: 'password');
  }

  /// ================================
  /// BIOMETRIC / AUTO LOGIN
  /// ================================
  Future<User?> signInWithStoredCredentials() async {
    try {
      String? email = await getStoredEmail();
      String? password = await getStoredPassword();

      if (email != null && password != null) {
        return await signIn(email, password);
      }

      print("❌ No stored credentials found");
      return null;
    } catch (e) {
      print("❌ Biometric Login Error: $e");
      rethrow;
    }
  }

  /// ================================
  /// FORCE TOKEN REFRESH (VERY USEFUL)
  /// ================================
  Future<String?> refreshToken() async {
    final user = _auth.currentUser;

    if (user == null) return null;

    final String token = (await user.getIdToken(true)) ?? "";

    await _storage.write(key: 'firebase_id_token', value: token);

    print("🔄 Token refreshed");

    return token;
  }
}