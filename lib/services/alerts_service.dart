import 'dart:convert';
import '../models/alert.dart';
import 'api_client.dart';

class AlertService {
  Future<List<AlertItem>> fetchAlerts() async {
    final res = await ApiClient.get('/api/alerts');
    if (res.statusCode != 200) {
      print('AlertService.fetchAlerts failed: ${res.statusCode} ${res.body}');
      throw Exception('Failed to load alerts');
    }
    try {
      final List data = jsonDecode(res.body);
      return data.map((e) => AlertItem.fromJson(e)).toList();
    } catch (e) {
      print('AlertService.fetchAlerts JSON decode error: $e');
      rethrow;
    }
  }

  Future<List<AlertItem>> fetchBySeverity(String severity) async {
    final res = await ApiClient.get('/api/alerts?severity=$severity');
    if (res.statusCode != 200) {
      print(
        'AlertService.fetchBySeverity failed: ${res.statusCode} ${res.body}',
      );
      throw Exception('Failed to load alerts');
    }
    try {
      final List data = jsonDecode(res.body);
      return data.map((e) => AlertItem.fromJson(e)).toList();
    } catch (e) {
      print('AlertService.fetchBySeverity JSON decode error: $e');
      rethrow;
    }
  }
}
