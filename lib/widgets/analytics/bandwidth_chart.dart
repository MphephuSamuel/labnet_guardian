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
          Text("$range Bandwidth Usage",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded(
            child: BarChart(
              BarChartData(
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
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