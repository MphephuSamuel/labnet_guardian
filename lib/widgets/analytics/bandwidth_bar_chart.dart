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
    
    // Get x-axis labels based on range
    final xLabels = _getXLabels(range, data.length);
    
    // Get which indices to show labels for (to avoid overcrowding)
    final showIndices = _getLabelIndices(data.length, range);

    final bars = data.isEmpty
        ? <BarChartGroupData>[]
        : data.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value,
                  width: _getBarWidth(data.length),
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
            "Bandwidth Usage (${_getRangeTitle(range)})",
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 260,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxY(data),
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
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: _getInterval(data.length, range),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        // Only show labels at specific indices to avoid overlap
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
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.black,
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, _, rod, __) {
                      final index = group.x;
                      final label = index < xLabels.length ? xLabels[index] : '';
                      return BarTooltipItem(
                        "$label: ${rod.toY.toStringAsFixed(1)} MB/s",
                        const TextStyle(color: Colors.white, fontSize: 12),
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

  List<String> _getXLabels(String range, int dataLength) {
    switch (range) {
      case "Day":
        // Show every 2 hours
        return [
          '12AM', '2AM', '4AM', '6AM', '8AM', '10AM', 
          '12PM', '2PM', '4PM', '6PM', '8PM', '10PM'
        ];
      case "Week":
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      case "Month":
        // Show every 5 days for month view
        return ['Day 1', 'Day 5', 'Day 10', 'Day 15', 'Day 20', 'Day 25', 'Day 30'];
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
        // Show every 5 days (0, 4, 9, 14, 19, 24, 29)
        return [0, 4, 9, 14, 19, 24, 29];
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

  double _getBarWidth(int dataLength) {
    if (dataLength > 20) return 6;
    if (dataLength > 10) return 10;
    return 18;
  }

  double _getMaxY(List<double> data) {
    if (data.isEmpty) return 100;
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    return maxValue + (maxValue * 0.2);
  }

  double _getInterval(int dataLength, String range) {
    if (range == "Day") return 2;
    if (range == "Month") return 5;
    if (dataLength > 20) return 4;
    if (dataLength > 10) return 2;
    return 1;
  }

  double _getRotationAngle(String range) {
    // Rotate labels for Day and Month to prevent overlap
    if (range == "Day" || range == "Month") return -0.5;
    return 0;
  }

  double _getFontSize(String range) {
    if (range == "Day" || range == "Month") return 9;
    return 10;
  }
}