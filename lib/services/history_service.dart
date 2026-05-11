import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/history.dart';

class HistoryConfig {
  static String get baseUrl {
    final envUrl = dotenv.env['SCAN_API_URL']?.trim();
    if (envUrl != null && envUrl.isNotEmpty) {
      if (Platform.isAndroid &&
          (envUrl.startsWith('http://localhost') ||
              envUrl.startsWith('http://127.0.0.1'))) {
        return 'http://10.0.2.2:5000';
      }
      return envUrl;
    }

    return Platform.isAndroid
        ? 'http://10.0.2.2:5000'
        : 'http://localhost:5000';
  }

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
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
class HistoryService {
  // ── Shared HTTP helper ────────────────────────────────────────────────────
  static Future<http.Response> _get(String path) {
    return http
        .get(
          Uri.parse('${HistoryConfig.baseUrl}$path'),
          headers: HistoryConfig.headers,
        )
        .timeout(HistoryConfig.timeout);
  }

  // ── HISTORY ───────────────────────────────────────────────────────────────
  /// GET `/api/history?q=<query>`
  /// Expected JSON: [ { "id", "title", "device", "ip", "time",
  ///                    "date_group", "type": "connection"|"disconnection"|
  ///                    "anomaly"|"update"|"scan" } ]
  static Future<ApiResult<List<HistoryItem>>> fetchHistory({
    String query = '',
  }) async {
    try {
      final path = query.isEmpty
          ? '/api/history'
          : '/api/history?q=${Uri.encodeComponent(query)}';
      final res = await _get(path);
      if (res.statusCode == 200) {
        final List<dynamic> json = jsonDecode(res.body);
        return ApiResult.success(
          json.map((j) => HistoryItem.fromJson(j)).toList(),
        );
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
