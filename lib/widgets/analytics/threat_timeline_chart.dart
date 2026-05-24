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
    
    // Get x-axis labels based on range
    final xLabels = _getXLabels(range, data.length);
    
    // Get which indices to show labels for
    final showIndices = _getLabelIndices(data.length, range);

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
            "Threat Detection Timeline (${_getRangeTitle(range)})",
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 260,
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
                      reservedSize: 45,
                      interval: _getInterval(data.length, range),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (showIndices.contains(index) && index < xLabels.length) {
                          return Transform.rotate(
                            angle: _getRotationAngle(range),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                xLabels[index],
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: _getFontSize(range),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 10,
                          ),
                        );
                      },
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
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => Colors.black,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) {
                        final index = touchedSpot.x.toInt();
                        final label = index < xLabels.length ? xLabels[index] : '';
                        return LineTooltipItem(
                          '$label: ${touchedSpot.y.toInt()} threats',
                          const TextStyle(color: Colors.white, fontSize: 12),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: spots.isEmpty
                    ? []
                    : [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: const Color(0xFFFF4D6D),
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFFF4D6D).withOpacity(0.3),
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

  List<String> _getXLabels(String range, int dataLength) {
    switch (range) {
      case "Day":
        return ['12AM', '2AM', '4AM', '6AM', '8AM', '10AM', '12PM', '2PM', '4PM', '6PM', '8PM', '10PM'];
      case "Week":
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      case "Month":
        return ['Day 1', 'Day 6', 'Day 11', 'Day 16', 'Day 21', 'Day 26'];
      case "Year":
        return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      default:
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    }
  }

  List<int> _getLabelIndices(int dataLength, String range) {
    switch (range) {
      case "Day":
        // Show every 2 hours (0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22)
        return List.generate(12, (i) => i * 2);
      case "Week":
        // Show all 7 days
        return List.generate(7, (i) => i);
      case "Month":
        // Show every 5 days (0, 5, 10, 15, 20, 25)
        return [0, 5, 10, 15, 20, 25];
      case "Year":
        // Show all 12 months
        return List.generate(12, (i) => i);
      default:
        return List.generate(7, (i) => i);
    }
  }

  String _getRangeTitle(String range) {
    switch (range) {
      case "Day": return "Last 24 Hours";
      case "Week": return "Last 7 Days";
      case "Month": return "Last 30 Days";
      case "Year": return "Last 12 Months";
      default: return "Last 7 Days";
    }
  }

  double _getInterval(int dataLength, String range) {
    if (range == "Day") return 2;
    if (range == "Month") return 5;
    if (dataLength > 20) return 4;
    if (dataLength > 10) return 2;
    return 1;
  }

  double _getRotationAngle(String range) {
    if (range == "Day" || range == "Month") return -0.3;
    return 0;
  }

  double _getFontSize(String range) {
    if (range == "Day" || range == "Month") return 9;
    return 10;
  }
}