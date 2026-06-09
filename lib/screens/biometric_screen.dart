import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../services/biometric_service.dart';
import '../screens/authentication_screen.dart';
import '../providers/auth_provider.dart';

class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key});

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen> {
  final BiometricService _biometricService = BiometricService();
  bool _isLoading = false;
  bool _isLoadingCapabilities = true;
  bool _isDeviceSupported = true;
  String? _errorMessage;
  String? _supportMessage;
  List<BiometricType> _availableBiometrics = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableBiometrics();
  }

  Future<void> _loadAvailableBiometrics() async {
    final bool isSupported = await _biometricService.isDeviceSupported();
    final biometrics = isSupported
        ? await _biometricService.getAvailableBiometrics()
        : <BiometricType>[];

    if (mounted) {
      setState(() {
        _isDeviceSupported = isSupported;
        _availableBiometrics = biometrics;
        _isLoadingCapabilities = false;
        _supportMessage = !isSupported
            ? 'This device does not support biometric authentication. You cannot use this app on this phone.'
            : biometrics.isEmpty
            ? 'Biometrics are not set up on this device. Please enable fingerprint or face recognition in Settings to continue.'
            : null;
      });
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

    final BiometricResult result = await _biometricService
        .authenticateWithBiometrics();

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
          _errorMessage =
              'Biometrics accepted, but could not authenticate session: $e';
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

              if (_isLoadingCapabilities) ...[
                const SizedBox(height: 28),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9B59B6)),
                ),
              ],

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

              if (_supportMessage != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F4FC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2DDF2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF7B2FBE),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _supportMessage!,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: Color(0xFF4B4B63),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Fingerprint Button (shown if available) ──
              if (_isDeviceSupported && _hasFingerprint) ...[
                _buildGradientButton(
                  icon: Icons.fingerprint,
                  label: 'Use Fingerprint',
                  onPressed: _isLoading ? null : _authenticate,
                ),
                const SizedBox(height: 14),
              ],

              // ── Face ID Button (shown if available) ──
              if (_isDeviceSupported && _hasFaceID) ...[
                _buildGradientButton(
                  icon: Icons.face_retouching_natural,
                  label: 'Use Face ID',
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
