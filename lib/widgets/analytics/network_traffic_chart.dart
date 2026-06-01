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
    final xLabels = _getXLabels(range, data.length);
    final showIndices = _getLabelIndices(data.length, range);
    
    final maxValue = data.isEmpty ? 100 : data.reduce((a, b) => a > b ? a : b);
    final yMax = maxValue > 0 ? maxValue * 1.2 : 100;

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
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF6C63FF),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Network Traffic (${_getRangeTitle(range)})",
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 260,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: yMax.toDouble(),
                clipData: FlClipData.all(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: yMax / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDarkMode ? Colors.white12 : Colors.black12,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: _getInterval(data.length, range),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (showIndices.contains(index) && index < xLabels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              xLabels[index],
                              style: TextStyle(
                                color: textColor,
                                fontSize: _getFontSize(range),
                              ),
                              textAlign: TextAlign.center,
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
                      reservedSize: 45,
                      interval: yMax / 4,
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
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: isDarkMode ? Colors.white24 : Colors.black12,
                    width: 0.5,
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => Colors.black,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) {
                        final index = touchedSpot.x.toInt();
                        final label = index < xLabels.length ? xLabels[index] : '';
                        return LineTooltipItem(
                          '$label: ${touchedSpot.y.toStringAsFixed(1)} MB/s',
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
                          curveSmoothness: 0.3,
                          color: const Color(0xFF6C63FF),
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: const Color(0xFF6C63FF),
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
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

  List<String> _getXLabels(String range, int dataLength) {
    switch (range) {
      case "Day":
        return ['12AM', '2AM', '4AM', '6AM', '8AM', '10AM', '12PM', '2PM', '4PM', '6PM', '8PM', '10PM'];
      case "Week":
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      case "Month":
        return ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
      case "Year":
        return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      default:
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    }
  }

  List<int> _getLabelIndices(int dataLength, String range) {
    switch (range) {
      case "Day":
        return List.generate(12, (i) => i * 2);
      case "Week":
        return List.generate(7, (i) => i);
      case "Month":
        return [0, 7, 14, 21];
      case "Year":
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
    if (range == "Month") return 7;
    if (dataLength > 20) return 4;
    if (dataLength > 10) return 2;
    return 1;
  }

  double _getFontSize(String range) {
    if (range == "Day" || range == "Month") return 9;
    return 10;
  }
}