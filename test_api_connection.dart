import 'package:http/http.dart' as http;

void main() async {
  print('Testing API connection...');
  print('Endpoint: http://localhost:5000/api/status');

  try {
    final response = await http
        .get(Uri.parse('http://localhost:5000/api/status'))
        .timeout(const Duration(seconds: 10));

    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
  } catch (e) {
    print('Error: $e');
  }
}
