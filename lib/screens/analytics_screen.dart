import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F7FB),

      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Analytics And Reports "),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
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
                      color: selected ? Colors.blue : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Text(
                      range,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.blue,
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
              children: const [
                StatsCard(
                  title: "Avg Bandwidth",
                  value: "428 GB",
                  change: "+12.5%",
                  icon: Icons.wifi,
                  color: Colors.blue,
                ),
                StatsCard(
                  title: "Active Devices",
                  value: "87",
                  change: "+5",
                  icon: Icons.devices,
                  color: Colors.green,
                ),
                StatsCard(
                  title: "Threats Blocked",
                  value: "55",
                  change: "-8",
                  icon: Icons.security,
                  color: Colors.red,
                ),
                StatsCard(
                  title: "Anomalies",
                  value: "12",
                  change: "+2",
                  icon: Icons.warning,
                  color: Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 25),

            NetworkTrafficChart(range: selectedRange),

            const SizedBox(height: 25),

            BandwidthBarChart(range: selectedRange),

            const SizedBox(height: 25),

            ThreatTimelineChart(range: selectedRange),

            const SizedBox(height: 25),

            ElevatedButton.icon(
  onPressed: () {
    PdfService.generateAdvancedReport(range: selectedRange);
  },
  icon: const Icon(Icons.picture_as_pdf),
  label: const Text("Download Report"),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.red,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  ),
),

            // 📄 REPORT SUMMARY
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Report Summary",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text("• Data analysed across Day, Week, Month, Year."),
                  Text("• Bandwidth usage shows consistent growth."),
                  Text("• Active devices stable."),
                  Text("• Threat detection increased at peak times."),
                  Text("• System anomalies detected successfully."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}