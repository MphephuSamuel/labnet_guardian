import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../utils/colors.dart';

class BandwidthBarChart extends StatelessWidget {
  final String range;
  final bool isDarkMode;
  final List<double>? bandwidthData;

  const BandwidthBarChart({
    super.key,
    required this.range,
    required this.isDarkMode,
    this.bandwidthData,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = AppColors.getCardColor(isDarkMode);
    final textColor = AppColors.getTextPrimary(isDarkMode);

    final data = bandwidthData ?? [];

    final bars = data.isEmpty
        ? <BarChartGroupData>[]
        : data.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value,
                  width: 14,
                  borderRadius: BorderRadius.circular(6),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF8A5CFF),
                      Color(0xFFB06CFF),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ],
            );
          }).toList();

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
            "Weekly Bandwidth Usage",
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 600,

                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDarkMode ? Colors.white12 : Colors.black12,
                    strokeWidth: 1,
                  ),
                ),

                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),

                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),

                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        const labels = [
                          "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
                        ];
                        return Text(labels[value.toInt() % labels.length]);
                      },
                    ),
                  ),
                ),

                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.black,
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, _, rod, __) {
                      return BarTooltipItem(
                        "${rod.toY} GB",
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),

                barGroups: bars,
              ),
            ),
          ),
        ],
      ),
    );
  }
}