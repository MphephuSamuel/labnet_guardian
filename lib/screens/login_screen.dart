import 'package:flutter/material.dart';
import 'authentication_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AuthenticationScreen()),
            );
          },
          child: const Text('Login'),
        ),
      ),
    );
  }
}
