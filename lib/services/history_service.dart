import 'dart:convert';
import '../models/history.dart';
import 'api_client.dart';

class HistoryService {
  Future<List<HistoryItem>> fetchHistories({String query = ''}) async {
    final path = query.isEmpty
        ? '/api/history'
        : '/api/history?q=${Uri.encodeComponent(query)}';
    final res = await ApiClient.get(path);
    if (res.statusCode != 200) {
      print(
        'HistoryService.fetchHistories failed: ${res.statusCode} ${res.body}',
      );
      throw Exception('Failed to load histories');
    }
    try {
      final decoded = jsonDecode(res.body);
      final List data = decoded['history'] ?? [];
      return data.map((e) => HistoryItem.fromJson(e)).toList();
    } catch (e) {
      print('HistoryService.fetchHistories JSON decode error: $e');
      rethrow;
    }
  }
}
