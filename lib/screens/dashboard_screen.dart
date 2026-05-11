import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/network_scan_service.dart';
import '../models/device.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<ApiResult<List<Device>>> _devicesFuture;

  @override
  void initState() {
    super.initState();
    _refreshDevices();
  }

  void _refreshDevices() {
    setState(() {
      _devicesFuture = NetworkScanService.fetchDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final bgColor = isDarkMode
        ? const Color(0xFF0F0F1E)
        : const Color(0xFFEFEEF8);
    final cardBg = isDarkMode ? const Color(0xFF1A1A2E) : Colors.white;
    final textPrimary = isDarkMode ? Colors.white : const Color(0xFF1A1A2E);
    final textSecondary = isDarkMode
        ? const Color(0xFF9E9EB8)
        : const Color(0xFF9E9EB8);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _refreshDevices(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // ── Header ──
                Text(
                  'Welcome back',
                  style: TextStyle(fontSize: 13, color: textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: textPrimary,
                  ),
                ),

                const SizedBox(height: 24),

                // ── Dynamic Stats from Real Devices ──
                FutureBuilder<ApiResult<List<Device>>>(
                  future: _devicesFuture,
                  builder: (context, snapshot) {
                    int totalDevices = 0;
                    int activeDevices = 0;
                    int suspiciousDevices = 0;
                    double totalBandwidth = 0;

                    if (snapshot.hasData && snapshot.data?.hasData == true) {
                      final devices = snapshot.data!.data!;
                      totalDevices = devices.length;
                      activeDevices = devices
                          .where((d) => d.status == DeviceStatus.active)
                          .length;
                      suspiciousDevices = devices
                          .where((d) => d.isSuspicious)
                          .length;
                      totalBandwidth = devices.fold(
                        0.0,
                        (sum, d) => sum + d.speedBps.toDouble(),
                      );
                    }

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
                                iconBg: const Color(
                                  0xFF8B3DCA,
                                ).withValues(alpha: 0.15),
                                value: '$totalDevices',
                                label: 'Total Devices',
                                delta: '+0',
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
                                iconBg: const Color(
                                  0xFF2EAD60,
                                ).withValues(alpha: 0.15),
                                value: '$activeDevices',
                                label: 'Active Now',
                                delta: '+0',
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
                                iconBg: const Color(
                                  0xFFFFB347,
                                ).withValues(alpha: 0.15),
                                value: '$suspiciousDevices',
                                label: 'Suspicious',
                                delta: '+0',
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
                                icon: Icons.speed,
                                iconColor: Colors.blueAccent,
                                iconBg: Colors.blueAccent.withValues(
                                  alpha: 0.15,
                                ),
                                value: _formatBandwidth(totalBandwidth),
                                label: 'Total Speed',
                                delta: '+0',
                                isPositive: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
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
                          const Icon(
                            Icons.monitor_heart_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Network Scan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Real-time device monitoring',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      FutureBuilder<ApiResult<List<Device>>>(
                        future: _devicesFuture,
                        builder: (context, snapshot) {
                          String statusText = 'Scanning...';
                          String deviceCountText = '0 devices';

                          if (snapshot.hasData &&
                              snapshot.data?.hasData == true) {
                            final count = snapshot.data!.data!.length;
                            statusText = 'Active';
                            deviceCountText =
                                '$count device${count != 1 ? 's' : ''} found';
                          } else if (snapshot.hasError) {
                            statusText = 'Error';
                            deviceCountText = 'Connection failed';
                          }

                          return Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      statusText,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Scanner Status',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      deviceCountText,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Connected',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Devices Section ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Connected Devices',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: _refreshDevices,
                      child: Text(
                        'Refresh',
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF8B5CF6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                FutureBuilder<ApiResult<List<Device>>>(
                  future: _devicesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDarkMode ? 0.3 : 0.06,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            snapshot.data?.error ?? 'Error loading devices',
                            style: TextStyle(color: textSecondary),
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData || !snapshot.data!.hasData) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            'No devices found',
                            style: TextStyle(color: textSecondary),
                          ),
                        ),
                      );
                    }

                    final devices = snapshot.data!.data!;
                    return Column(
                      children: devices.map((device) {
                        return _buildDeviceCard(
                          isDarkMode: isDarkMode,
                          cardBg: cardBg,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          device: device,
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatBandwidth(double bps) {
    if (bps >= 1_000_000_000) {
      return '${(bps / 1_000_000_000).toStringAsFixed(1)} GB/s';
    }
    if (bps >= 1_000_000) {
      return '${(bps / 1_000_000).toStringAsFixed(1)} MB/s';
    }
    if (bps >= 1_000) {
      return '${(bps / 1_000).toStringAsFixed(1)} KB/s';
    }
    return '${bps.toStringAsFixed(0)} B/s';
  }

  Widget _buildDeviceCard({
    required bool isDarkMode,
    required Color cardBg,
    required Color textPrimary,
    required Color textSecondary,
    required Device device,
  }) {
    IconData getIconForType(DeviceType type) {
      switch (type) {
        case DeviceType.laptop:
          return Icons.laptop;
        case DeviceType.phone:
          return Icons.phone_android;
        case DeviceType.tablet:
          return Icons.tablet_mac;
        case DeviceType.other:
          return Icons.devices;
      }
    }

    Color getIconColor(DeviceType type) {
      if (device.isSuspicious) return Colors.orange;
      switch (type) {
        case DeviceType.laptop:
        case DeviceType.phone:
          return Colors.purple;
        case DeviceType.tablet:
          return Colors.orange;
        case DeviceType.other:
          return Colors.blue;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: device.isSuspicious
            ? Border.all(
                color: Colors.orange.withValues(alpha: 0.3),
                width: 1.5,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                  color: getIconColor(device.type).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  getIconForType(device.type),
                  color: getIconColor(device.type),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      device.ipAddress,
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                  ],
                ),
              ),
              if (device.isSuspicious)
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Speed: ${device.speedText}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: textSecondary,
                ),
              ),
              Text(
                device.status == DeviceStatus.active ? '● Active' : '● Offline',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: device.status == DeviceStatus.active
                      ? const Color(0xFF2EAD60)
                      : Colors.grey,
                ),
              ),
            ],
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
          // Value and label
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: textSecondary)),
          const SizedBox(height: 8),
          // Delta indicator
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                size: 14,
                color: isPositive ? const Color(0xFF2EAD60) : Colors.redAccent,
              ),
              const SizedBox(width: 4),
              Text(
                delta,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isPositive
                      ? const Color(0xFF2EAD60)
                      : Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
