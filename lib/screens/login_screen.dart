import 'package:flutter/material.dart';
import 'biometric_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _token; // Add a variable to store the token

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFEFEEF8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // ── Logo + App Name ──
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF9B59B6), Color(0xFFE91E8C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(Icons.wifi, color: Colors.white, size: 26),
                        Positioned(
                          bottom: 8,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB347),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'LabNet',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7B2FBE),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // ── Heading ──
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Login to monitor your lab network',
                style: TextStyle(fontSize: 14, color: Color(0xFF9E9EB8)),
              ),

              const SizedBox(height: 60),

              // ── Login Card ──
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card title
                    const Text(
                      'Admin Login',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Username / Email Field ──
                    TextField(
                      controller: _usernameController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Username or Email',
                        hintStyle: const TextStyle(color: Color(0xFFBDBDD8)),
                        prefixIcon: const Icon(
                          Icons.mail_outline_rounded,
                          color: Color(0xFFBDBDD8),
                          size: 20,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F5FC),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: const BorderSide(
                            color: Color(0xFF9B59B6),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Password Field ──
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: const TextStyle(color: Color(0xFFBDBDD8)),
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: Color(0xFFBDBDD8),
                          size: 20,
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          child: Icon(
                            _obscurePassword
                                ? Icons.remove_red_eye_outlined
                                : Icons.visibility_off_outlined,
                            color: const Color(0xFFBDBDD8),
                            size: 20,
                          ),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F5FC),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: const BorderSide(
                            color: Color(0xFF9B59B6),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Error Message ──
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Center(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    // ── Token Display ──
                    if (authProvider.isAuthenticated && authProvider.token != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Token: ${authProvider.token}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1A1A2E),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, color: Color(0xFF7B2FBE)),
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: authProvider.token!),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Token copied to clipboard!'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                    // ── Redirect Button ──
                    if (authProvider.isAuthenticated && authProvider.token != null)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const BiometricScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7B2FBE),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: const Text(
                            'Redirect',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                    // ── Login Button or Loading ──
                    if (!authProvider.isAuthenticated)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B3DCA), Color(0xFFE91E8C)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: () async {
                                    final email = _usernameController.text
                                        .trim();
                                    final password = _passwordController.text
                                        .trim();
                                    setState(() {
                                      _errorMessage = null;
                                    });
                                    if (email.isEmpty || password.isEmpty) {
                                      setState(() {
                                        _errorMessage =
                                            'Please enter email and password';
                                      });
                                      return;
                                    }
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    try {
                                      await authProvider.signIn(
                                        email,
                                        password,
                                      );
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    } catch (e) {
                                      setState(() {
                                        _isLoading = false;
                                        _errorMessage = e.toString();
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // ── Forgot Password ──
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // TODO: handle forgot password
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Color(0xFF7B2FBE),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
