import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import '../providers/app_theme.dart';
import '../providers/theme_provider.dart';
import '../models/alert.dart';
import '../utils/colors.dart';
import '../services/alerts_service.dart';
import 'profile_screen.dart';

class SecurityAlertsScreen extends StatefulWidget {
  const SecurityAlertsScreen({super.key});

  @override
  State<SecurityAlertsScreen> createState() => _SecurityAlertsScreenState();
}

class _SecurityAlertsScreenState extends State<SecurityAlertsScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['All', 'Critical', 'Warning', 'Info'];

  // ── State ──────────────────────────────────────────────────────────────────
  List<AlertItem> _alerts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() { _isLoading = true; _error = null; });
    
    // Mockup data for demonstration
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    
    final mockAlerts = [
      AlertItem(
        id: '1',
        title: 'Suspicious Login Attempt',
        description: 'Multiple failed login attempts detected from unknown device',
        device: 'LAB-PC-001',
        ip: '192.168.1.45',
        time: '2 minutes ago',
        severity: AlertSeverity.critical,
      ),
      AlertItem(
        id: '2',
        title: 'Unusual Network Traffic',
        description: 'Abnormal data transfer patterns detected on device',
        device: 'IOT-SENSOR-01',
        ip: '192.168.1.112',
        time: '15 minutes ago',
        severity: AlertSeverity.warning,
      ),
      AlertItem(
        id: '3',
        title: 'New Device Connected',
        description: 'Previously unseen device joined the network',
        device: 'PHONE-CS-023',
        ip: '192.168.1.92',
        time: '1 hour ago',
        severity: AlertSeverity.info,
      ),
      AlertItem(
        id: '4',
        title: 'Firewall Rule Triggered',
        description: 'Blocked connection attempt to restricted port',
        device: 'TABLET-ENG-015',
        ip: '192.168.1.78',
        time: '2 hours ago',
        severity: AlertSeverity.warning,
      ),
      AlertItem(
        id: '5',
        title: 'System Update Available',
        description: 'Security patches ready for installation',
        device: 'LAB-PC-002',
        ip: '192.168.1.46',
        time: '3 hours ago',
        severity: AlertSeverity.info,
      ),
    ];
    
    setState(() {
      _isLoading = false;
      _alerts = mockAlerts;
    });
  }

  List<AlertItem> get _filtered {
    switch (_selectedTab) {
      case 1: return _alerts.where((a) => a.severity == AlertSeverity.critical).toList();
      case 2: return _alerts.where((a) => a.severity == AlertSeverity.warning).toList();
      case 3: return _alerts.where((a) => a.severity == AlertSeverity.info).toList();
      default: return _alerts;
    }
  }

  int get _criticalCount => _alerts.where((a) => a.severity == AlertSeverity.critical).length;
  int get _warningCount  => _alerts.where((a) => a.severity == AlertSeverity.warning).length;
  int get _infoCount     => _alerts.where((a) => a.severity == AlertSeverity.info).length;

  // ── Navigation helpers ─────────────────────────────────────────────────────
  void _openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final isDark = theme.isDarkMode;
    final bgColor = AppColors.getBgColor(isDark);
    final cardColor = AppColors.getCardColor(isDark);
    final textColor = AppColors.getTextPrimary(isDark);
    final subColor = AppColors.getTextSecondary(isDark);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: RefreshIndicator(
                color: AppColors.gradientStart,
                onRefresh: _loadAlerts,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const SizedBox(height: 8),
                    Text('Security Alerts',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        )),
                    const SizedBox(height: 20),
                    _tabsRow(isDark, subColor),
                    const SizedBox(height: 20),
                    _statCards(isDark, cardColor, subColor),
                    const SizedBox(height: 20),
                    if (_isLoading)
                      _loadingState(subColor)
                    else if (_error != null)
                      _errorState(subColor, cardColor)
                    else if (_filtered.isEmpty)
                      _emptyState(subColor)
                    else
                      ..._filtered.asMap().entries.map((e) => Padding(
                            padding: EdgeInsets.only(
                                bottom: e.key < _filtered.length - 1 ? 12 : 20),
                            child: _alertCard(
                              isDark: isDark,
                              cardColor: cardColor,
                              textColor: textColor,
                              subColor: subColor,
                              alert: e.value,
                            ),
                          )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top bar ────────────────────────────────────────────────────────────────
  Widget _topBar(bool isDark, ThemeProvider theme, Color textColor, BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          Icon(Icons.menu, color: textColor, size: 26),
          const Spacer(),
          _circleBtn(
            isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round_outlined,
            isDark, textColor, onTap: theme.toggleTheme,
          ),
          const SizedBox(width: 10),
          // Notification bell — tapping here does nothing extra since we ARE
          // already on the Alerts screen; the dot still shows unread count.
          Stack(
            children: [
              _circleBtn(Icons.notifications_outlined, isDark, textColor),
              if (_criticalCount > 0)
                Positioned(
                  right: 8, top: 8,
                  child: Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.critical, shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          // Avatar — navigates to Profile & Settings
          GestureDetector(
            onTap: () => _openProfile(ctx),
            child: Container(
              width: 40, height: 40,
              decoration: const BoxDecoration(
                color: AppColors.gradientStart, shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('A',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, bool isDark, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
              blurRadius: 8, offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  // ── Tabs ───────────────────────────────────────────────────────────────────
  Widget _tabsRow(bool isDark, Color subColor) {
    return Row(
      children: List.generate(_tabs.length, (i) {
        final isActive = i == _selectedTab;
        return GestureDetector(
          onTap: () => setState(() => _selectedTab = i),
          child: Container(
            margin: const EdgeInsets.only(right: 24),
            padding: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isActive ? AppColors.gradientStart : Colors.transparent,
                  width: 2.5,
                ),
              ),
            ),
            child: Text(_tabs[i],
                style: TextStyle(
                  color: isActive ? AppColors.gradientStart : subColor,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 15,
                )),
          ),
        );
      }),
    );
  }

  // ── Stat cards ─────────────────────────────────────────────────────────────
  Widget _statCards(bool isDark, Color cardColor, Color subColor) {
    return Row(
      children: [
        _statCard(isDark, cardColor, subColor, '$_criticalCount', 'Critical', AppColors.critical, 1),
        const SizedBox(width: 12),
        _statCard(isDark, cardColor, subColor, '$_warningCount',  'Warning',  AppColors.warning,  2),
        const SizedBox(width: 12),
        _statCard(isDark, cardColor, subColor, '$_infoCount',     'Info',     AppColors.info,     3),
      ],
    );
  }

  Widget _statCard(bool isDark, Color cardColor, Color subColor,
      String count, String label, Color color, int tabIndex) {
    final isActive = _selectedTab == tabIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = tabIndex),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: isActive ? color.withValues(alpha: isDark ? 0.2 : 0.08) : cardColor,
            borderRadius: BorderRadius.circular(16),
            border: isActive ? Border.all(color: color.withValues(alpha: 0.5), width: 1.5) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 10, offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: [
            Text(count, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: subColor, fontSize: 12, fontWeight: FontWeight.w500)),
          ]),
        ),
      ),
    );
  }

  // ── States ─────────────────────────────────────────────────────────────────
  Widget _loadingState(Color subColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(children: [
          CircularProgressIndicator(color: AppColors.gradientStart, strokeWidth: 2.5),
          const SizedBox(height: 16),
          Text('Loading alerts…', style: TextStyle(color: subColor, fontSize: 14)),
        ]),
      ),
    );
  }

  Widget _errorState(Color subColor, Color cardColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 4),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.critical.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.critical.withValues(alpha: 0.25)),
        ),
        child: Column(children: [
          Icon(Icons.cloud_off_rounded, color: AppColors.critical.withValues(alpha: 0.7), size: 44),
          const SizedBox(height: 12),
          Text(_error!, textAlign: TextAlign.center,
              style: TextStyle(color: subColor, fontSize: 13, height: 1.5)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _loadAlerts,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.gradientStart,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _emptyState(Color subColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(children: [
          Icon(Icons.check_circle_outline_rounded,
              color: subColor.withValues(alpha: 0.4), size: 56),
          const SizedBox(height: 16),
          Text('No alerts in this category',
              style: TextStyle(color: subColor, fontSize: 15, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }

  // ── Alert card ─────────────────────────────────────────────────────────────
  Widget _alertCard({
    required bool isDark,
    required Color cardColor,
    required Color textColor,
    required Color subColor,
    required AlertItem alert,
  }) {
    final sev = alert.severity;
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: sev.color, width: 3.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10, offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: isDark ? sev.color.withValues(alpha: 0.15) : sev.bgLight,
              shape: BoxShape.circle,
            ),
            child: Icon(sev.icon, color: sev.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(alert.title,
                style: TextStyle(
                  color: textColor, fontSize: 15,
                  fontWeight: FontWeight.w700, height: 1.3,
                )),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: sev.color, borderRadius: BorderRadius.circular(20)),
            child: Text(sev.label,
                style: const TextStyle(
                  color: Colors.white, fontSize: 11,
                  fontWeight: FontWeight.w700, letterSpacing: 0.3,
                )),
          ),
        ]),
        const SizedBox(height: 10),
        Text(alert.description,
            style: TextStyle(color: subColor, fontSize: 13, height: 1.4)),
        const SizedBox(height: 12),
        Row(children: [
          Icon(Icons.show_chart, color: subColor, size: 14),
          const SizedBox(width: 4),
          Text(alert.device,
              style: TextStyle(color: subColor, fontSize: 12, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(alert.time, style: TextStyle(color: subColor, fontSize: 12)),
        ]),
      ]),
    );
  }
}
