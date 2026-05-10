import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../layout/main_layout.dart';
import '../providers/auth_provider.dart';

class AuthSuccessScreen extends StatefulWidget {
  const AuthSuccessScreen({super.key});

  @override
  State<AuthSuccessScreen> createState() => _AuthSuccessScreenState();
}

class _AuthSuccessScreenState extends State<AuthSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Retrieve and print the token for debugging purposes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.loadToken(); // Load the token to ensure it is available
      debugPrint('Token: ${authProvider.token}');
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    // ── Auto-redirect to the dashboard tab after 2.5 seconds ──
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainLayout(initialIndex: 0)),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFEFEEF8),
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Green Circle with Checkmark ──
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CD080), Color(0xFF2EAD60)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF2EAD60,
                          ).withValues(alpha: 0.35),
                          blurRadius: 40,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // ── Title ──
                const Text(
                  'Authentication\nSuccessful!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A2E),
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: 14),

                // ── Subtitle ──
                const Text(
                  'Redirecting to dashboard...',
                  style: TextStyle(fontSize: 14, color: Color(0xFF9E9EB8)),
                ),

                const SizedBox(height: 14),

                // Display the token
                if (authProvider.token != null)
                  Text(
                    'Token: ${authProvider.token}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
