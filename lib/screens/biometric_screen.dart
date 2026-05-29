
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../services/biometric_service.dart';
import '../screens/authentication_screen.dart';
import '../layout/main_layout.dart';
import '../providers/auth_provider.dart';

class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key});

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen> {
  final BiometricService _biometricService = BiometricService();
  bool _isLoading = false;
  String? _errorMessage;
  List<BiometricType> _availableBiometrics = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableBiometrics();
  }

  Future<void> _loadAvailableBiometrics() async {
    final biometrics = await _biometricService.getAvailableBiometrics();
    if (mounted) {
      setState(() => _availableBiometrics = biometrics);
    }
  }

  bool get _hasFaceID => _availableBiometrics.contains(BiometricType.face);
  bool get _hasFingerprint =>
      _availableBiometrics.contains(BiometricType.fingerprint) ||
      _availableBiometrics.contains(BiometricType.strong);

  Future<void> _authenticate() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final BiometricResult result =
        await _biometricService.authenticateWithBiometrics();

    if (!mounted) return;

    if (result.success) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.signInWithStoredCredentials();
        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthSuccessScreen()),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = 'Biometrics accepted, but could not authenticate session: $e';
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage =
            result.errorMessage ?? 'Biometric authentication failed';
      });
    }
  }

  void _skip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainLayout(initialIndex: 0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEEF8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // ── Icon: shows face or fingerprint based on availability ──
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9B59B6), Color(0xFFE91E8C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9B59B6).withValues(alpha: 0.35),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Icon(
                  _hasFaceID && _hasFingerprint
                      ? Icons.security
                      : _hasFaceID
                          ? Icons.face_retouching_natural
                          : Icons.fingerprint,
                  size: 90,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 48),

              // ── Title ──
              const Text(
                'Biometric\nAuthentication',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1A2E),
                  height: 1.25,
                ),
              ),

              const SizedBox(height: 16),

              // ── Subtitle ──
              const Text(
                'Use your fingerprint or face ID to securely\naccess the dashboard',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9E9EB8),
                  height: 1.6,
                ),
              ),

              const Spacer(),

              // ── Error Message ──
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.redAccent,
                    ),
                  ),
                ),

              // ── Fingerprint Button (shown if available) ──
              if (_hasFingerprint) ...[
                _buildGradientButton(
                  icon: Icons.fingerprint,
                  label: 'Use Fingerprint',
                  onPressed: _isLoading ? null : _authenticate,
                ),
                const SizedBox(height: 14),
              ],

              // ── Face ID Button (shown if available) ──
              if (_hasFaceID) ...[
                _buildGradientButton(
                  icon: Icons.face_retouching_natural,
                  label: 'Use Face ID',
                  onPressed: _isLoading ? null : _authenticate,
                ),
                const SizedBox(height: 14),
              ],

              // ── Fallback if no biometrics detected yet ──
              if (!_hasFingerprint && !_hasFaceID) ...[
                _buildGradientButton(
                  icon: Icons.security,
                  label: 'Authenticate with Biometrics',
                  onPressed: _isLoading ? null : _authenticate,
                ),
                const SizedBox(height: 14),
              ],

              // ── Loading indicator ──
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 14),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF9B59B6),
                    ),
                  ),
                ),

              // ── Skip for Now Button ──
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _skip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text(
                    'Skip for Now',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9E9EB8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B3DCA), Color(0xFFE91E8C)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white),
          label: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ),
      ),
    );
  }
}