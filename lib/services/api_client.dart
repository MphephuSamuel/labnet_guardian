import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiClient {
  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static void clearToken() {
    _token = null;
  }

  static String get baseUrl =>
      dotenv.env['BACKEND_URL'] ?? 'http://10.0.2.2:3000';

  static Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  static Future<http.Response> get(String path) async {
    final url = Uri.parse('$baseUrl$path');
    try {
      final response = await http.get(url, headers: _headers());
      if (response.statusCode != 200) {
        print('GET $url failed: ${response.statusCode} ${response.body}');
      }
      return response;
    } catch (e) {
      print('GET request error: $e');
      rethrow;
    }
  }

  static Future<http.Response> post(String path, dynamic body) async {
    final url = Uri.parse('$baseUrl$path');
    try {
      final response = await http.post(
        url,
        headers: _headers(),
        body: body != null ? jsonEncode(body) : null,
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        print('POST $url failed: ${response.statusCode} ${response.body}');
      }
      return response;
    } catch (e) {
      print('POST request error: $e');
      rethrow;
    }
  }

  static Future<http.Response> put(String path, dynamic body) async {
    final url = Uri.parse('$baseUrl$path');
    try {
      final response = await http.put(
        url,
        headers: _headers(),
        body: body != null ? jsonEncode(body) : null,
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        print('PUT $url failed: ${response.statusCode} ${response.body}');
      }
      return response;
    } catch (e) {
      print('PUT request error: $e');
      rethrow;
    }
  }

  static Future<http.Response> delete(String path) async {
    final url = Uri.parse('$baseUrl$path');
    try {
      final response = await http.delete(url, headers: _headers());
      if (response.statusCode < 200 || response.statusCode >= 300) {
        print('DELETE $url failed: ${response.statusCode} ${response.body}');
      }
      return response;
    } catch (e) {
      print('DELETE request error: $e');
      rethrow;
    }
  }
}
