import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/analytics/stats_card.dart';
import '../widgets/analytics/network_traffic_chart.dart';
import '../widgets/analytics/bandwidth_bar_chart.dart';
import '../widgets/analytics/threat_timeline_chart.dart';
import '../services/pdf_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String selectedRange = "Week";
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = AppColors.getBgColor(isDarkMode);
    final cardColor = AppColors.getCardColor(isDarkMode);
    final textPrimary = AppColors.getTextPrimary(isDarkMode);
    final textSecondary = AppColors.getTextSecondary(isDarkMode);

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
          style: TextStyle(color: textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: textPrimary,
            ),
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // 🔥 TIME FILTER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ["Day", "Week", "Month", "Year"].map((range) {
                final selected = selectedRange == range;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedRange = range;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: selected
                          ? const LinearGradient(
                              colors: [
                                AppColors.gradientStart,
                                AppColors.gradientEnd,
                              ],
                            )
                          : null,
                      color: selected ? null : cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      range,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // 📊 KPI CARDS
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                StatsCard(
                  title: "Avg Bandwidth",
                  value: "428 GB",
                  change: "+12.5%",
                  icon: Icons.wifi,
                  color: AppColors.iconBlue,
                  isDarkMode: isDarkMode,
                ),
                StatsCard(
                  title: "Active Devices",
                  value: "87",
                  change: "+5",
                  icon: Icons.devices,
                  color: AppColors.connection,
                  isDarkMode: isDarkMode,
                ),
                StatsCard(
                  title: "Threats Blocked",
                  value: "55",
                  change: "-8",
                  icon: Icons.security,
                  color: AppColors.critical,
                  isDarkMode: isDarkMode,
                ),
                StatsCard(
                  title: "Anomalies",
                  value: "12",
                  change: "+2",
                  icon: Icons.warning,
                  color: AppColors.warning,
                  isDarkMode: isDarkMode,
                ),
              ],
            ),

            const SizedBox(height: 25),

            // 📊 NETWORK TRAFFIC CHART (FIXED)
            NetworkTrafficChart(
              range: selectedRange,
              isDarkMode: isDarkMode,
            ),

            const SizedBox(height: 25),

            // 📊 BANDWIDTH CHART (FIXED)
            BandwidthBarChart(
              range: selectedRange,
              isDarkMode: isDarkMode,
            ),

            const SizedBox(height: 25),

            // 📊 THREAT TIMELINE CHART (FIXED)
            ThreatTimelineChart(
              range: selectedRange,
              isDarkMode: isDarkMode,
            ),

            const SizedBox(height: 25),

            // 📥 PDF BUTTON
            ElevatedButton.icon(
              onPressed: () {
                PdfService.generateAdvancedReport(range: selectedRange);
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Download Report"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.critical,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
            ),

            const SizedBox(height: 20),

            // 📄 REPORT SUMMARY
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Report Summary",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("• Data analysed across all time ranges.",
                      style: TextStyle(color: textSecondary)),
                  Text("• Bandwidth usage shows consistent growth.",
                      style: TextStyle(color: textSecondary)),
                  Text("• Active devices stable.",
                      style: TextStyle(color: textSecondary)),
                  Text("• Threat detection peaks at busy hours.",
                      style: TextStyle(color: textSecondary)),
                  Text("• System anomalies handled effectively.",
                      style: TextStyle(color: textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}