import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/alert.dart';
import '../models/device.dart';

class NetworkScanConfig {
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

    final fallbackUrl = Platform.isAndroid
        ? 'http://10.0.2.2:5000'
        : 'http://localhost:5000';
    debugPrint('⚠️ SCAN_API_URL not set, using fallback $fallbackUrl');
    return fallbackUrl;
  }

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Duration get timeout => const Duration(seconds: 60);
}

class NetworkScanService {
  static Future<http.Response> _get(String path) {
    return http
        .get(
          Uri.parse('${NetworkScanConfig.baseUrl}$path'),
          headers: NetworkScanConfig.headers,
        )
        .timeout(NetworkScanConfig.timeout);
  }

  static Future<ApiResult<List<AlertItem>>> fetchAlerts() async {
    try {
      final res = await _get('/api/alerts');
      if (res.statusCode == 200) {
        final List<dynamic> payload = jsonDecode(res.body);
        final items = payload
            .map((json) => AlertItem.fromJson(json as Map<String, dynamic>))
            .toList();
        return ApiResult.success(items);
      }
      return ApiResult.failure('Server error ${res.statusCode}');
    } catch (e) {
      return ApiResult.failure(_friendlyError(e));
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> fetchSummary() async {
    try {
      final res = await _get('/api/summary');
      if (res.statusCode == 200) {
        final Map<String, dynamic> payload = jsonDecode(res.body);
        return ApiResult.success(payload);
      }
      return ApiResult.failure('Server error ${res.statusCode}');
    } catch (e) {
      return ApiResult.failure(_friendlyError(e));
    }
  }

  static Future<ApiResult<List<Device>>> fetchDevices() async {
    try {
      final url = '${NetworkScanConfig.baseUrl}/api/devices';
      debugPrint('🔵 Fetching devices from: $url');
      final res = await _get('/api/devices');
      debugPrint('🟢 Response status: ${res.statusCode}');
      if (res.statusCode == 200) {
        final List<dynamic> payload = jsonDecode(res.body);
        debugPrint('🟢 Received ${payload.length} devices');
        return ApiResult.success(
          payload
              .map((json) => Device.fromJson(json as Map<String, dynamic>))
              .toList(),
        );
      }
      debugPrint('🔴 Server error: ${res.statusCode}');
      return ApiResult.failure('Server error ${res.statusCode}');
    } catch (e) {
      debugPrint('🔴 Exception: ${_friendlyError(e)}');
      return ApiResult.failure(_friendlyError(e));
    }
  }

  static String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('SocketException') ||
        msg.contains('Connection refused') ||
        msg.contains('Network')) {
      return 'Cannot reach the scan server. Check your connection or SCAN_API_URL.';
    }
    if (msg.contains('TimeoutException')) {
      return 'Scan request timed out. The scanner server is not responding.';
    }
    return 'Unexpected error: $msg';
  }
}

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
