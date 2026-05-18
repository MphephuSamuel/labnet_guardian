import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../utils/colors.dart';

class NetworkTrafficChart extends StatelessWidget {
  final String range;
  final bool isDarkMode;
  final List<double>? trafficData;

  const NetworkTrafficChart({
    super.key,
    required this.range,
    required this.isDarkMode,
    this.trafficData,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = AppColors.getCardColor(isDarkMode);
    final textColor = AppColors.getTextPrimary(isDarkMode);

    final data = trafficData ?? [];

    final spots = data.isEmpty
        ? <FlSpot>[]
        : List.generate(
            data.length,
            (i) => FlSpot(i.toDouble(), data[i]),
          );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Network Traffic",
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDarkMode ? Colors.white12 : Colors.black12,
                    strokeWidth: 1,
                  ),
                ),

                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const labels = [
                          "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
                        ];
                        return Text(
                          labels[value.toInt() % labels.length],
                          style: TextStyle(color: textColor, fontSize: 10),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),

                borderData: FlBorderData(show: false),

                lineBarsData: spots.isEmpty
                    ? []
                    : [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: const Color(0xFF6C63FF),
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6C63FF).withOpacity(0.3),
                                Colors.transparent,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}