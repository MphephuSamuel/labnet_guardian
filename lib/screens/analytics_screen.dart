import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/analytics/stats_card.dart';
import '../widgets/analytics/network_traffic_chart.dart';
import '../widgets/analytics/bandwidth_line_chart.dart';  // Changed from bandwidth_bar_chart
import '../widgets/analytics/threat_timeline_chart.dart';
import '../services/pdf_service.dart';
import '../services/analytics_service.dart';
import '../models/analytics_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String selectedRange = "Week";
  bool isDarkMode = true;
  bool isLoading = true;
  AnalyticsModel? analytics;
  List<Map<String, dynamic>> anomalies = [];

  @override
  void initState() {
    super.initState();
    _checkAuthAndFetch();
  }

  Future<void> _checkAuthAndFetch() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('❌ No user logged in');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }
    await fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    try {
      setState(() => isLoading = true);
      
      print('🔄 Fetching analytics for range: $selectedRange');
      
      final data = await AnalyticsService.getAnalytics(selectedRange);
      final anomalyData = await AnalyticsService.getAnomalies();

      print("🔥 Analytics received - Avg Bandwidth: ${data.averageBandwidth}");
      print("🔥 Active Devices: ${data.activeDevices}");
      print("🔥 Threats Blocked: ${data.threatsBlocked}");

      if (!mounted) return;

      setState(() {
        analytics = data;
        anomalies = anomalyData;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Analytics Error: $e");
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load analytics: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = AppColors.getBgColor(isDarkMode);
    final cardColor = AppColors.getCardColor(isDarkMode);
    final textPrimary = AppColors.getTextPrimary(isDarkMode);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Analytics & Reports",
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: textPrimary,
            ),
            onPressed: () => setState(() => isDarkMode = !isDarkMode),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: textPrimary),
            onPressed: fetchAnalytics,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchAnalytics,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterRow(cardColor),
                    const SizedBox(height: 20),
                    _buildStatsGrid(),
                    const SizedBox(height: 25),
                    Text(
                      "Network Traffic",
                      style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    NetworkTrafficChart(
                      range: selectedRange,
                      isDarkMode: isDarkMode,
                      trafficData: analytics?.traffic ?? [],
                    ),
                    const SizedBox(height: 25),
                    Text(
                      "Bandwidth Usage",
                      style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    BandwidthLineChart(  // Changed from BandwidthBarChart
                      range: selectedRange,
                      isDarkMode: isDarkMode,
                      bandwidthData: analytics?.bandwidth ?? [],
                    ),
                    const SizedBox(height: 25),
                    Text(
                      "Threat Timeline",
                      style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ThreatTimelineChart(
                      range: selectedRange,
                      isDarkMode: isDarkMode,
                      threatData: analytics?.threats ?? [],
                    ),
                    const SizedBox(height: 25),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          PdfService.generateAdvancedReport(
                            range: selectedRange,
                            bandwidthData: {
                              "averageBandwidth": analytics?.averageBandwidth ?? 0,
                            },
                            threats: analytics?.threats ?? [],
                            anomalies: anomalies,
                          );
                        },
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text("Download Report"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.critical,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFilterRow(Color cardColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ["Day", "Week", "Month", "Year"].map((range) {
          final selected = selectedRange == range;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => selectedRange = range);
                fetchAnalytics();
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? null : cardColor,
                  gradient: selected ? const LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd]) : null,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  range,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        StatsCard(
          title: "Avg Bandwidth",
          value: "${analytics?.averageBandwidth.toStringAsFixed(1) ?? 0} MB/s",
          change: _formatChange(analytics?.averageBandwidthChange ?? 0.0),
          icon: Icons.wifi,
          color: AppColors.iconBlue,
          isDarkMode: isDarkMode,
        ),
        StatsCard(
          title: "Active Devices",
          value: "${analytics?.activeDevices ?? 0}",
          change: _formatChange((analytics?.activeDevicesChange ?? 0).toDouble()),
          icon: Icons.devices,
          color: AppColors.connection,
          isDarkMode: isDarkMode,
        ),
        StatsCard(
          title: "Threats Blocked",
          value: "${analytics?.threatsBlocked ?? 0}",
          change: _formatChange((analytics?.threatsChange ?? 0).toDouble()),
          icon: Icons.security,
          color: AppColors.critical,
          isDarkMode: isDarkMode,
        ),
        StatsCard(
          title: "Anomalies",
          value: "${analytics?.anomalies ?? 0}",
          change: _formatChange((analytics?.anomaliesChange ?? 0).toDouble()),
          icon: Icons.warning,
          color: AppColors.warning,
          isDarkMode: isDarkMode,
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