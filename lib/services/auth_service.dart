import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        String? token = await user.getIdToken();
        await _storage.write(key: 'firebase_id_token', value: token);
        // Store credentials for biometric login
        await _storage.write(key: 'email', value: email);
        await _storage.write(key: 'password', value: password);
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _storage.delete(key: 'firebase_id_token');
  }

  // Get stored token
  Future<String?> getToken() async {
    return await _storage.read(key: 'firebase_id_token');
  }

  // Get stored email
  Future<String?> getStoredEmail() async {
    return await _storage.read(key: 'email');
  }

  // Get stored password
  Future<String?> getStoredPassword() async {
    return await _storage.read(key: 'password');
  }

  // Sign in with stored credentials (for biometric)
  Future<User?> signInWithStoredCredentials() async {
    try {
      String? email = await getStoredEmail();
      String? password = await getStoredPassword();
      if (email != null && password != null) {
        return await signIn(email, password);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
