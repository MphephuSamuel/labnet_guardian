import 'package:flutter/material.dart';
import '../layout/main_layout.dart';

class AuthenticationScreen extends StatelessWidget {
  const AuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Replace navigation stack with main layout
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainLayout()),
            );
          },
          child: const Text('Log in'),
        ),
      ),
    );
  }
}
