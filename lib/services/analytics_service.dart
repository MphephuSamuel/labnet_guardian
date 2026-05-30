import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/analytics_model.dart';

class AnalyticsService {
  // Read from .env file only - no hardcoded fallback
  static String get baseUrl {
    final url = dotenv.env['BACKEND_URL'];
    if (url == null) {
      print('❌ BACKEND_URL not found in .env file!');
      throw Exception('BACKEND_URL not configured in .env');
    }
    print('📍 BACKEND_URL from .env: $url');
    return url;
  }
  
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
        return AnalyticsModel.fromJson(data);
      } else {
        throw Exception('Failed to load analytics: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ AnalyticsService error: $e');
      return AnalyticsModel.empty();
    }
  }

  static Future<List<Map<String, dynamic>>> getAnomalies() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];
      
      final token = await user.getIdToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/anomalies'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['anomalies'] ?? []);
      }
      return [];
    } catch (e) {
      print('❌ AnomaliesService error: $e');
      return [];
    }
  }
}