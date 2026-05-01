import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/history.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — swap baseUrl to your real backend when ready
// ─────────────────────────────────────────────────────────────────────────────
class ApiConfig {
  /// Change this to your backend base URL, e.g.
  ///   'http://192.168.1.10:8000'   (local dev)
  ///   'https://api.mynetwork.com'  (production)
  static const String baseUrl = 'http://YOUR_BACKEND_URL';

  /// Add auth headers here once your backend requires them, e.g.
  ///   'Authorization': 'Bearer $token'
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // 'Authorization': 'Bearer YOUR_TOKEN',
      };

  static Duration get timeout => const Duration(seconds: 15);
}

// ─────────────────────────────────────────────────────────────────────────────
// RESULT WRAPPER — every API call returns ApiResult<T>
// ─────────────────────────────────────────────────────────────────────────────
class ApiResult<T> {
  final T? data;
  final String? error;
  final bool isLoading;

  const ApiResult.loading() : data = null, error = null, isLoading = true;
  const ApiResult.success(this.data) : error = null, isLoading = false;
  const ApiResult.failure(this.error) : data = null, isLoading = false;

  bool get hasData => data != null;
  bool get hasError => error != null;
}

// ─────────────────────────────────────────────────────────────────────────────
// API SERVICE
// ─────────────────────────────────────────────────────────────────────────────
class ApiService {
  // ── Shared HTTP helper ────────────────────────────────────────────────────
  static Future<http.Response> _get(String path) {
    return http
        .get(
          Uri.parse('${ApiConfig.baseUrl}$path'),
          headers: ApiConfig.headers,
        )
        .timeout(ApiConfig.timeout);
  }

  static Future<http.Response> _post(String path, Map<String, dynamic> body) {
    return http
        .post(
          Uri.parse('${ApiConfig.baseUrl}$path'),
          headers: ApiConfig.headers,
          body: jsonEncode(body),
        )
        .timeout(ApiConfig.timeout);
  }

  // ── HISTORY ───────────────────────────────────────────────────────────────
  /// GET /api/history?q=<query>
  /// Expected JSON: [ { "id", "title", "device", "ip", "time",
  ///                    "date_group", "type": "connection"|"disconnection"|
  ///                    "anomaly"|"update"|"scan" } ]
  static Future<ApiResult<List<HistoryItem>>> fetchHistory(
      {String query = ''}) async {
    try {
      final path = query.isEmpty
          ? '/api/history'
          : '/api/history?q=${Uri.encodeComponent(query)}';
      final res = await _get(path);
      if (res.statusCode == 200) {
        final List<dynamic> json = jsonDecode(res.body);
        return ApiResult.success(
            json.map((j) => HistoryItem.fromJson(j)).toList());
      }
      return ApiResult.failure('Server error ${res.statusCode}');
    } catch (e) {
      return ApiResult.failure(_friendlyError(e));
    }
  }

  static String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('SocketException') ||
        msg.contains('Connection refused') ||
        msg.contains('Network')) {
      return 'Cannot reach the server. Check your connection or backend URL.';
    }
    if (msg.contains('TimeoutException')) {
      return 'Request timed out. The server is not responding.';
    }
    return 'Unexpected error: $msg';
  }
}