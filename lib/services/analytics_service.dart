import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/analytics_model.dart';
import '../config/app_config.dart';

class AnalyticsService {
  static const String baseUrl = AppConfig.backendUrl;
  
  static Future<AnalyticsModel> getAnalytics(String range) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      final token = await user.getIdToken();
      final url = '$baseUrl/api/analytics?range=$range';
      print('🌐 Calling: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('📊 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('✅ Analytics data received');
        return AnalyticsModel.fromJson(data);
      } else {
        throw Exception('Failed to load analytics: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ AnalyticsService error: $e');
      return AnalyticsModel.empty();
    }
  }

  // ADD THIS METHOD - Get anomalies from backend
  static Future<List<Map<String, dynamic>>> getAnomalies() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];
      
      final token = await user.getIdToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/anomalies'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('📊 Anomalies response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final anomaliesList = data['anomalies'] ?? [];
        print('✅ Retrieved ${anomaliesList.length} anomalies');
        return List<Map<String, dynamic>>.from(anomaliesList);
      }
      return [];
    } catch (e) {
      print('❌ AnomaliesService error: $e');
      return [];
    }
  }
}