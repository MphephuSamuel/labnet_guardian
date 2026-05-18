import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../utils/colors.dart';

class ThreatTimelineChart extends StatelessWidget {
  final String range;
  final bool isDarkMode;
  final List<double>? threatData;

  const ThreatTimelineChart({
    super.key,
    required this.range,
    required this.isDarkMode,
    this.threatData,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = AppColors.getCardColor(isDarkMode);
    final textColor = AppColors.getTextPrimary(isDarkMode);

    final data = threatData ?? [];

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
            "Threat Detection Timeline",
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDarkMode ? Colors.white12 : Colors.black12,
                    strokeWidth: 1,
                  ),
                ),

                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        const months = [
                          "Jan", "Feb", "Mar", "Apr", "May", "Jun"
                        ];
                        return Text(
                          months[value.toInt() % months.length],
                          style: TextStyle(color: textColor, fontSize: 10),
                        );
                      },
                    ),
                  ),

                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
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
                          color: const Color(0xFFFF4D6D),
                          barWidth: 3,
                          dotData: FlDotData(show: true),
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