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
    final textSecondary = AppColors.getTextSecondary(isDarkMode);

    final data = threatData ?? [];
    
    // Check if there's any actual data (non-zero values)
    final hasData = data.any((value) => value > 0);
    
    final maxValue = hasData ? data.reduce((a, b) => a > b ? a : b) : 0;
    final yMax = maxValue > 0 ? maxValue * 1.3 : 10.0;
    
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
                decoration: const BoxDecoration(
                  color: Color(0xFFFF4D6D),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Threat Timeline",
                style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Number of threats detected",
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
                    Icon(Icons.shield_outlined, size: 48, color: textSecondary),
                    const SizedBox(height: 16),
                    Text(
                      "No threats detected",
                      style: TextStyle(color: textSecondary, fontSize: 14),
                    ),
                    Text(
                      "Your network is secure. No threats found.",
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
                            '$label: ${touchedSpot.y.toInt()} threats',
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
                      color: const Color(0xFFFF4D6D),
                      barWidth: 4,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 5,
                            color: const Color(0xFFFF4D6D),
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
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

  List<int> _getShowingLabels(String range, int dataLength) {
    switch (range) {
      case "Day":
        return [0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22];
      case "Week":
        return [0, 1, 2, 3, 4, 5, 6];
      case "Month":
        return [0, 5, 10, 15, 20, 25];
      case "Year":
        return [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
      default:
        return [0, 1, 2, 3, 4, 5, 6];
    }
  }
}