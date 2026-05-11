import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    print('Error loading .env: $e');
  }

  final scanApiUrl = dotenv.env['SCAN_API_URL'] ?? 'NOT FOUND';
  print('SCAN_API_URL: $scanApiUrl');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('SCAN_API_URL: ${dotenv.env['SCAN_API_URL']}'),
        ),
      ),
    );
  }
}
