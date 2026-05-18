import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/analytics_model.dart';

class AnalyticsService {
  static const String baseUrl = "http://10.0.2.2:3000";

  static Future<AnalyticsModel> getAnalytics(String range) async {
    final response = await http.get(
      Uri.parse("$baseUrl/analytics?range=$range"),
    );

    if (response.statusCode == 200) {
      return AnalyticsModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load analytics");
    }
  }

  static Future<List<dynamic>> getThreats() async {
    final res = await http.get(Uri.parse("$baseUrl/threats"));
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getAnomalies() async {
    final res = await http.get(Uri.parse("$baseUrl/anomalies"));
    return jsonDecode(res.body);
  }
}