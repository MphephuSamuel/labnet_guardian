import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BandwidthBarChart extends StatelessWidget {
  final String range;

  const BandwidthBarChart({super.key, required this.range});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Bandwidth Usage",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: true),
                borderData: FlBorderData(show: false),

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
      interval: 1,
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
        const labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
        return Text(labels[value.toInt() % 7]);
      },
    ),
  ),
),

                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.black,
tooltipRoundedRadius: 8,
                    getTooltipItem: (group, _, rod, __) {
                      return BarTooltipItem(
                        "${rod.toY} GB",
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),

                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 5)]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 7)]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 4)]),
                  BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 6)]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}