import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../utils/colors.dart';

class BandwidthLineChart extends StatelessWidget {
  final String range;
  final bool isDarkMode;
  final List<double>? bandwidthData;

  const BandwidthLineChart({
    super.key,
    required this.range,
    required this.isDarkMode,
    this.bandwidthData,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = AppColors.getCardColor(isDarkMode);
    final textColor = AppColors.getTextPrimary(isDarkMode);
    final textSecondary = AppColors.getTextSecondary(isDarkMode);

    final data = bandwidthData ?? [];
    
    // Check if there's any actual data (non-zero values)
    final hasData = data.any((value) => value > 0);
    
    final maxValue = hasData ? data.reduce((a, b) => a > b ? a : b) : 0;
    final yMax = maxValue > 0 ? maxValue * 1.2 : 500.0;
    
    final xLabels = _getXLabels(range, data.length);
    final showingLabels = _getShowingLabels(range, data.length);

    final spots = List.generate(
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
                decoration: BoxDecoration(
                  color: const Color(0xFF8A5CFF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Bandwidth Usage",
                style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Total bandwidth usage in GB",
            style: TextStyle(color: textSecondary, fontSize: 10),
          ),
          const SizedBox(height: 20),
          
          // Show No Data message if no data exists
          if (!hasData)
            Container(
              height: 260,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, size: 48, color: textSecondary),
                    const SizedBox(height: 16),
                    Text(
                      "No bandwidth data available",
                      style: TextStyle(color: textSecondary, fontSize: 14),
                    ),
                    Text(
                      "Data will appear once bandwidth is measured",
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 260,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: yMax,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: isDarkMode ? Colors.white24 : Colors.black12,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < xLabels.length && showingLabels.contains(index)) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                xLabels[index],
                                style: TextStyle(color: textColor, fontSize: 10),
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
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}',
                            style: TextStyle(color: textColor, fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: isDarkMode ? Colors.white24 : Colors.black12, width: 1),
                  ),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) => Colors.black,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((touchedSpot) {
                          final index = touchedSpot.x.toInt();
                          final label = index < xLabels.length ? xLabels[index] : '';
                          return LineTooltipItem(
                            '$label: ${touchedSpot.y.toStringAsFixed(1)} GB',
                            const TextStyle(color: Colors.white, fontSize: 12),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: false,
                      color: const Color(0xFF8A5CFF),
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: const Color(0xFF8A5CFF),
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(show: false),
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
        return ['12AM', '4AM', '8AM', '12PM', '4PM', '8PM'];
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

  List<int> _getShowingLabels(String range, int dataLength) {
    switch (range) {
      case "Day":
        return [0, 4, 8, 12, 16, 20];
      case "Week":
        return [0, 1, 2, 3, 4, 5, 6];
      case "Month":
        return [0, 7, 14, 21];
      case "Year":
        return [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
      default:
        return [0, 1, 2, 3, 4, 5, 6];
    }
  }
}