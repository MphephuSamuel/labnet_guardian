import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/theme_provider.dart';
import '../services/analytics_service.dart';
import '../models/analytics_model.dart';
import 'analytics_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  AnalyticsModel? analytics;
  bool isLoading = true;
  String? userName;
  List<Map<String, dynamic>> recentThreats = [];
  List<Map<String, dynamic>> recentAnomalies = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAnalytics();
    _loadRecentData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userName = user.email?.split('@').first ?? 'Admin';
      });
    }
  }

  Future<void> _loadAnalytics() async {
    try {
      setState(() => isLoading = true);
      final data = await AnalyticsService.getAnalytics("Week");
      if (mounted) {
        setState(() {
          analytics = data;
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading dashboard analytics: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _loadRecentData() async {
    try {
      final anomalies = await AnalyticsService.getAnomalies();
      if (mounted) {
        setState(() {
          recentAnomalies = anomalies.take(3).toList();
        });
      }
    } catch (e) {
      print('❌ Error loading recent data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final bgColor = isDarkMode ? const Color(0xFF0F0F1E) : const Color(0xFFEFEEF8);
    final cardBg = isDarkMode ? const Color(0xFF1A1A2E) : Colors.white;
    final textPrimary = isDarkMode ? Colors.white : const Color(0xFF1A1A2E);
    final textSecondary = isDarkMode ? const Color(0xFF9E9EB8) : const Color(0xFF9E9EB8);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _loadAnalytics();
            await _loadRecentData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // ── Header with User (No Notification Icon) ──
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome back,',
                        style: TextStyle(fontSize: 13, color: textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      userName ?? 'Admin',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── 4 Stat Cards (No Percentage Indicators) ──
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  _buildStatsGrid(isDarkMode, cardBg, textPrimary, textSecondary),

                const SizedBox(height: 20),

                // ── Network Activity Card ──
                _buildNetworkActivityCard(),

                const SizedBox(height: 24),

                // ── Security Status Section ──
                _buildSecurityStatusSection(textPrimary, textSecondary, cardBg),

                const SizedBox(height: 24),

                // ── Recent Activity Section ──
                _buildRecentActivitySection(textPrimary, textSecondary, cardBg),

                const SizedBox(height: 24),

                // ── Quick Actions ──
                _buildQuickActionsSection(textPrimary),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(bool isDarkMode, Color cardBg, Color textPrimary, Color textSecondary) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                isDark: isDarkMode,
                cardBg: cardBg,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                icon: Icons.wifi,
                iconColor: const Color(0xFF8B3DCA),
                iconBg: const Color(0xFF8B3DCA).withOpacity(0.15),
                value: analytics?.activeDevices.toString() ?? '0',
                label: 'Total Devices',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _StatCard(
                isDark: isDarkMode,
                cardBg: cardBg,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                icon: Icons.speed,
                iconColor: const Color(0xFF2EAD60),
                iconBg: const Color(0xFF2EAD60).withOpacity(0.15),
                value: '${analytics?.averageBandwidth.toStringAsFixed(0) ?? 0}',
                label: 'Avg Bandwidth',
                suffix: ' MB/s',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                isDark: isDarkMode,
                cardBg: cardBg,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                icon: Icons.warning_amber_rounded,
                iconColor: const Color(0xFFFFB347),
                iconBg: const Color(0xFFFFB347).withOpacity(0.15),
                value: analytics?.threatsBlocked.toString() ?? '0',
                label: 'Threats Blocked',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _StatCard(
                isDark: isDarkMode,
                cardBg: cardBg,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                icon: Icons.bug_report,
                iconColor: Colors.redAccent,
                iconBg: Colors.redAccent.withOpacity(0.15),
                value: analytics?.anomalies.toString() ?? '0',
                label: 'Anomalies',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNetworkActivityCard() {
    final usagePercent = ((analytics?.averageBandwidth ?? 0) / 100).clamp(0.0, 1.0);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B3DCA), Color(0xFFE91E8C)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.monitor_heart_outlined, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Network Health',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('Current status',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${(usagePercent * 100).toInt()}%',
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    const Text('Bandwidth Usage',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: usagePercent,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Network Status: ${usagePercent > 0.7 ? "High Load" : usagePercent > 0.3 ? "Normal" : "Optimal"}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
              Text('Last updated: just now',
                  style: const TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityStatusSection(Color textPrimary, Color textSecondary, Color cardBg) {
    final threatCount = analytics?.threatsBlocked ?? 0;
    final anomalyCount = analytics?.anomalies ?? 0;
    final securityScore = ((1 - (threatCount + anomalyCount) / 100) * 100).clamp(0, 100).toInt();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Security Status',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: securityScore > 80 ? Colors.green.withOpacity(0.1) : 
                             securityScore > 50 ? Colors.orange.withOpacity(0.1) : 
                             Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      securityScore > 80 ? Icons.shield : 
                      securityScore > 50 ? Icons.warning : 
                      Icons.dangerous,
                      color: securityScore > 80 ? Colors.green : 
                             securityScore > 50 ? Colors.orange : 
                             Colors.red,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Security Score',
                            style: TextStyle(fontSize: 14, color: textSecondary)),
                        Text('$securityScore%',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: securityScore > 80 ? Colors.green.withOpacity(0.1) : 
                             securityScore > 50 ? Colors.orange.withOpacity(0.1) : 
                             Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      securityScore > 80 ? 'Good' : securityScore > 50 ? 'Fair' : 'Poor',
                      style: TextStyle(
                        color: securityScore > 80 ? Colors.green : 
                               securityScore > 50 ? Colors.orange : 
                               Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: securityScore / 100,
                  minHeight: 6,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    securityScore > 80 ? Colors.green : 
                    securityScore > 50 ? Colors.orange : 
                    Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSecurityMetric('Threats', threatCount, Colors.red),
                  _buildSecurityMetric('Anomalies', anomalyCount, Colors.orange),
                  _buildSecurityMetric('Devices', analytics?.activeDevices ?? 0, Colors.blue),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityMetric(String label, int value, Color color) {
    return Column(
      children: [
        Text(value.toString(),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildRecentActivitySection(Color textPrimary, Color textSecondary, Color cardBg) {
    final hasAnomalies = recentAnomalies.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Activity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
            if (hasAnomalies)
              TextButton(
                onPressed: () {},
                child: const Text('View All', style: TextStyle(fontSize: 12, color: Color(0xFF8B5CF6))),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (!hasAnomalies)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 48),
                const SizedBox(height: 12),
                Text('No recent anomalies',
                    style: TextStyle(color: textSecondary, fontSize: 14)),
                const SizedBox(height: 4),
                Text('Your network is secure',
                    style: TextStyle(color: textSecondary, fontSize: 12)),
              ],
            ),
          )
        else
          ...recentAnomalies.map((anomaly) => _ActivityItem(
                title: anomaly['message'] ?? 'Unknown anomaly',
                subtitle: anomaly['deviceId'] ?? 'Unknown device',
                time: 'Just now',
                severity: anomaly['severity'] ?? 'medium',
                cardBg: cardBg,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              )),
      ],
    );
  }

  Widget _buildQuickActionsSection(Color textPrimary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.analytics,
                title: 'Analytics',
                subtitle: 'View reports',
                color: const Color(0xFF8B5CF6),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                icon: Icons.refresh,
                title: 'Refresh',
                subtitle: 'Update data',
                color: const Color(0xFF2EAD60),
                onTap: () async {
                  await _loadAnalytics();
                  await _loadRecentData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data refreshed'), duration: Duration(seconds: 1)),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatChange(double change) {
    if (change == 0) return "0%";
    final sign = change > 0 ? "+" : "";
    return "$sign${change.toStringAsFixed(1)}%";
  }
}

// ── Stat Card Widget (No Percentage/Delta) ──
class _StatCard extends StatelessWidget {
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String label;
  final String? suffix;

  const _StatCard({
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textPrimary)),
              if (suffix != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 4),
                  child: Text(suffix!, style: TextStyle(fontSize: 12, color: textSecondary)),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 12, color: textSecondary)),
        ],
      ),
    );
  }
}

// ── Activity Item Widget ──
class _ActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final String severity;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;

  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.severity,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    Color severityColor;
    IconData severityIcon;
    
    switch (severity.toLowerCase()) {
      case 'high':
      case 'critical':
        severityColor = Colors.red;
        severityIcon = Icons.error;
        break;
      case 'medium':
        severityColor = Colors.orange;
        severityIcon = Icons.warning;
        break;
      default:
        severityColor = Colors.green;
        severityIcon = Icons.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: severityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(severityIcon, color: severityColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(fontSize: 11, color: textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(severity,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: severityColor)),
              ),
              const SizedBox(height: 4),
              Text(time,
                  style: TextStyle(fontSize: 10, color: textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Action Card Widget ──
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(title,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}