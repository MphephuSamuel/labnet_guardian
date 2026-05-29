import 'dart:convert';
import 'api_client.dart';

class AiService {
  Future<Map<String, dynamic>> queryAI(
    String prompt,
    List<Map<String, dynamic>> chatHistory,
  ) async {
    // Map client chat history to backend AIConversationMessage format
    final messages = chatHistory.map((msg) {
      return {
        'role': msg['isBot'] == true ? 'assistant' : 'user',
        'content': msg['text'],
      };
    }).toList();

    final body = {
      'prompt': prompt,
      'messages': messages,
    };

    final res = await ApiClient.post('/api/ai/query', body);
    if (res.statusCode != 200) {
      print('AiService.queryAI failed: ${res.statusCode} ${res.body}');
      throw Exception('Failed to get response from AI Assistant');
    }

    try {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      print('AiService.queryAI JSON decode error: $e');
      rethrow;
    }
  }
}
