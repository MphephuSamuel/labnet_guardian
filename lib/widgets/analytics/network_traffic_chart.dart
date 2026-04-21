import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class NetworkTrafficChart extends StatelessWidget {
  final String range;
  const NetworkTrafficChart({super.key, required this.range});

  List<FlSpot> getData() {
    switch (range) {
      case "Day":
        return [FlSpot(0, 1), FlSpot(1, 2), FlSpot(2, 1.5)];
      case "Month":
        return [FlSpot(0, 3), FlSpot(1, 4), FlSpot(2, 5)];
      case "Year":
        return [FlSpot(0, 5), FlSpot(1, 6), FlSpot(2, 7)];
      default:
        return [
          FlSpot(0, 2),
          FlSpot(1, 3),
          FlSpot(2, 2.5),
          FlSpot(3, 4),
        ];
    }
  }

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
          Text("Network Traffic ($range)",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded(
            child: LineChart(
              LineChartData(
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
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    spots: getData(),
                    barWidth: 3,
                    color: Colors.blue,
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