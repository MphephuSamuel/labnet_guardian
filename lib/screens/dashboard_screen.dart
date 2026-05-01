import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // ── Header ──
              Text('Welcome back',
                  style: TextStyle(fontSize: 13, color: textSecondary)),
              const SizedBox(height: 4),
              Text('Admin Dashboard',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: textPrimary)),

              const SizedBox(height: 24),

              // ── 4 Stat Cards ──
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
                      iconBg: const Color(0xFF8B3DCA).withValues(alpha: 0.15),
                      value: '342',
                      label: 'Total Devices',
                      delta: '+12',
                      isPositive: true,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _StatCard(
                      isDark: isDarkMode,
                      cardBg: cardBg,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      icon: Icons.wifi,
                      iconColor: const Color(0xFF2EAD60),
                      iconBg: const Color(0xFF2EAD60).withValues(alpha: 0.15),
                      value: '298',
                      label: 'Active Now',
                      delta: '+5',
                      isPositive: true,
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
                      iconBg: const Color(0xFFFFB347).withValues(alpha: 0.15),
                      value: '8',
                      label: 'Suspicious',
                      delta: '-2',
                      isPositive: false,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _StatCard(
                      isDark: isDarkMode,
                      cardBg: cardBg,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      icon: Icons.wifi_off_rounded,
                      iconColor: Colors.redAccent,
                      iconBg: Colors.redAccent.withValues(alpha: 0.15),
                      value: '23',
                      label: 'Blocked',
                      delta: '+3',
                      isPositive: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Network Activity Card ──
              Container(
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
                        const Icon(Icons.monitor_heart_outlined,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Network Activity',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                            Text('Real-time monitoring',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
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
                            children: const [
                              Text('87%',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900)),
                              SizedBox(height: 4),
                              Text('Bandwidth Usage',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('1.2TB',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900)),
                              SizedBox(height: 4),
                              Text('Total Traffic',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Lab Status Section ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Lab Status',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: textPrimary)),
                  Text('View All',
                      style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF8B5CF6),
                          fontWeight: FontWeight.w600)),
                ],
              ),

              const SizedBox(height: 16),

              // ── Lab Cards ──
              _buildLabCard(
                  isDarkMode: isDarkMode,
                  cardBg: cardBg,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  labName: 'Engineering Lab',
                  devicesActive: '42/45',
                  percentage: 85),
              const SizedBox(height: 12),
              _buildLabCard(
                  isDarkMode: isDarkMode,
                  cardBg: cardBg,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  labName: 'Computer Science Lab',
                  devicesActive: '36/38',
                  percentage: 72),
              const SizedBox(height: 12),
              _buildLabCard(
                  isDarkMode: isDarkMode,
                  cardBg: cardBg,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  labName: 'Physics Lab',
                  devicesActive: '25/28',
                  percentage: 58),
              const SizedBox(height: 12),
              _buildLabCard(
                  isDarkMode: isDarkMode,
                  cardBg: cardBg,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  labName: 'Chemistry Lab',
                  devicesActive: '30/32',
                  percentage: 65),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabCard({
    required bool isDarkMode,
    required Color cardBg,
    required Color textPrimary,
    required Color textSecondary,
    required String labName,
    required String devicesActive,
    required int percentage,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.dns_outlined,
                    color: Color(0xFF8B5CF6), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(labName,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textPrimary)),
                    const SizedBox(height: 4),
                    Text('$devicesActive devices active',
                        style: TextStyle(
                            fontSize: 12, color: textSecondary)),
                  ],
                ),
              ),
              Text('$percentage%',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 6,
              backgroundColor: textSecondary.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage >= 80
                    ? const Color(0xFFFF6B35)
                    : percentage >= 60
                        ? const Color(0xFF8B5CF6)
                        : const Color(0xFF3B82F6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Card Widget ──
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
  final String delta;
  final bool isPositive;

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
    required this.delta,
    required this.isPositive,
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
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon badge
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

          // Value
          Text(value,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: textPrimary)),
          const SizedBox(height: 2),

          // Label
          Text(label,
              style: TextStyle(fontSize: 12, color: textSecondary)),
          const SizedBox(height: 8),

          // Delta
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                size: 14,
                color: isPositive ? const Color(0xFF2EAD60) : Colors.redAccent,
              ),
              const SizedBox(width: 4),
              Text(
                delta,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? const Color(0xFF2EAD60) : Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

