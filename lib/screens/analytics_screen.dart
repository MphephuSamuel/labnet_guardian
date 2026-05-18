import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/analytics/stats_card.dart';
import '../widgets/analytics/network_traffic_chart.dart';
import '../widgets/analytics/bandwidth_bar_chart.dart';
import '../widgets/analytics/threat_timeline_chart.dart';
import '../services/pdf_service.dart';
import '../services/analytics_service.dart';
import '../models/analytics_model.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String selectedRange = "Week";
  bool isDarkMode = true;

  AnalyticsModel? analytics;

  List<dynamic> anomalies = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    try {
      setState(() {
        isLoading = true;
      });

      final data =
          await AnalyticsService.getAnalytics(selectedRange);

      final anomalyData =
          await AnalyticsService.getAnomalies();

      if (!mounted) return;

      setState(() {
        analytics = data;
        anomalies = anomalyData;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Analytics Error: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = AppColors.getBgColor(isDarkMode);

    final cardColor =
        AppColors.getCardColor(isDarkMode);

    final textPrimary =
        AppColors.getTextPrimary(isDarkMode);

    final textSecondary =
        AppColors.getTextSecondary(isDarkMode);

    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Analytics & Reports",
          style: TextStyle(color: textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: textPrimary,
            ),
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
          ),
        ],
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: fetchAnalytics,
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),

                child: Column(
                  children: [

                    // ================= FILTER =================
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,

                      children:
                          ["Day", "Week", "Month", "Year"]
                              .map((range) {
                        final selected =
                            selectedRange == range;

                        return GestureDetector(
                          onTap: () async {
                            setState(() {
                              selectedRange = range;
                            });

                            await fetchAnalytics();
                          },

                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),

                            decoration: BoxDecoration(
                              gradient: selected
                                  ? const LinearGradient(
                                      colors: [
                                        AppColors
                                            .gradientStart,
                                        AppColors
                                            .gradientEnd,
                                      ],
                                    )
                                  : null,

                              color:
                                  selected ? null : cardColor,

                              borderRadius:
                                  BorderRadius.circular(20),
                            ),

                            child: Text(
                              range,
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : AppColors.primary,

                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // ================= KPI =================
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,

                      physics:
                          const NeverScrollableScrollPhysics(),

                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.0,

                      children: [

                        StatsCard(
  title: "Avg Bandwidth",

  value:
      "${analytics?.averageBandwidth ?? 0} GB",

  change:
      "${analytics?.averageBandwidthChange ?? 0}%",

  icon: Icons.wifi,

  color: AppColors.iconBlue,

  isDarkMode: isDarkMode,
),

                        StatsCard(
  title: "Active Devices",

  value:
      "${analytics?.activeDevices ?? 0}",

  change:
      "${analytics?.activeDevicesChange ?? 0}",

  icon: Icons.devices,

  color: AppColors.connection,

  isDarkMode: isDarkMode,
),

                        StatsCard(
  title: "Threats Blocked",

  value:
      "${analytics?.threatsBlocked ?? 0}",

  change:
      "${analytics?.threatsChange ?? 0}",

  icon: Icons.security,

  color: AppColors.critical,

  isDarkMode: isDarkMode,
),

                        StatsCard(
  title: "Anomalies",

  value:
      "${analytics?.anomalies ?? 0}",

  change:
      "${analytics?.anomaliesChange ?? 0}",

  icon: Icons.warning,

  color: AppColors.warning,

  isDarkMode: isDarkMode,
),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // ================= TRAFFIC =================
                    NetworkTrafficChart(
                      range: selectedRange,

                      isDarkMode: isDarkMode,

                      trafficData:
                          analytics?.traffic ?? [],
                    ),

                    const SizedBox(height: 25),

                    // ================= BANDWIDTH =================
                    BandwidthBarChart(
                      range: selectedRange,

                      isDarkMode: isDarkMode,

                      bandwidthData:
                          analytics?.bandwidth ?? [],
                    ),

                    const SizedBox(height: 25),

                    // ================= THREATS =================
                    ThreatTimelineChart(
                      range: selectedRange,

                      isDarkMode: isDarkMode,

                      threatData:
                          analytics?.threats ?? [],
                    ),

                    const SizedBox(height: 25),

                    // ================= PDF =================
                    ElevatedButton.icon(
                      onPressed: () {
                        PdfService.generateAdvancedReport(
                          range: selectedRange,

                          bandwidthData: {
                            "averageBandwidth":
                                analytics
                                        ?.averageBandwidth ??
                                    0,
                          },

                          threats:
                              analytics?.threats ?? [],

                          anomalies: anomalies,
                        );
                      },

                      icon:
                          const Icon(Icons.picture_as_pdf),

                      label:
                          const Text("Download Report"),

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.critical,

                        foregroundColor: Colors.white,

                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),

                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ================= SUMMARY =================
                    Container(
                      width: double.infinity,

                      padding:
                          const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: cardColor,

                        borderRadius:
                            BorderRadius.circular(16),
                      ),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          Text(
                            "Report Summary",

                            style: TextStyle(
                              fontSize: 18,

                              fontWeight:
                                  FontWeight.bold,

                              color: textPrimary,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "• Analytics connected to backend.",
                            style: TextStyle(
                              color: textSecondary,
                            ),
                          ),

                          Text(
                            "• Charts render only when backend data exists.",
                            style: TextStyle(
                              color: textSecondary,
                            ),
                          ),

                          Text(
                            "• Empty backend returns empty axes only.",
                            style: TextStyle(
                              color: textSecondary,
                            ),
                          ),

                          Text(
                            "• Real-time analytics architecture ready.",
                            style: TextStyle(
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}