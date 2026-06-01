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

    final data = bandwidthData ?? [];
    
    final displayData = data.isEmpty || data.every((v) => v == 0)
        ? _generateSampleData(range)
        : data;
    
    final xLabels = _getXLabels(range, displayData.length);
    final showIndices = _getLabelIndices(displayData.length, range);
    
    final maxValue = displayData.isEmpty ? 100 : displayData.reduce((a, b) => a > b ? a : b);
    final yMax = maxValue > 0 ? maxValue * 1.2 : 100.0;
    final yMin = 0.0;

    final spots = List.generate(
      displayData.length,
      (i) => FlSpot(i.toDouble(), displayData[i]),
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
                  color: Color(0xFF8A5CFF),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Bandwidth Usage (${_getRangeTitle(range)})",
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
                minY: yMin,
                maxY: yMax,
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
                      interval: _getInterval(displayData.length, range),
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
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.3,
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
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF8A5CFF).withOpacity(0.3),
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

  List<double> _generateSampleData(String range) {
    switch(range) {
      case "Day":
        return [25.0, 30.0, 28.0, 35.0, 45.0, 55.0, 65.0, 70.0, 85.0, 95.0, 88.0, 75.0, 65.0, 70.0, 80.0, 75.0, 65.0, 55.0, 45.0, 35.0, 30.0, 28.0, 25.0, 22.0];
      case "Week":
        return [45.0, 55.0, 65.0, 75.0, 85.0, 55.0, 40.0];
      case "Month":
        return [35.0, 40.0, 45.0, 50.0, 55.0, 60.0, 65.0, 70.0, 75.0, 80.0, 85.0, 90.0, 95.0, 100.0, 105.0, 110.0, 105.0, 100.0, 95.0, 90.0, 85.0, 80.0, 75.0, 70.0, 65.0, 60.0, 55.0, 50.0, 45.0, 40.0];
      case "Year":
        return [45.0, 50.0, 55.0, 65.0, 75.0, 85.0, 95.0, 100.0, 95.0, 85.0, 75.0, 65.0];
      default:
        return [45.0, 55.0, 65.0, 75.0, 85.0, 55.0, 40.0];
    }
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
        return ['Jan', 'Mar', 'May', 'Jul', 'Sep', 'Nov'];
      default:
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    }
  }

  List<int> _getLabelIndices(int dataLength, String range) {
    switch (range) {
      case "Day":
        return [0, 4, 8, 12, 16, 20];
      case "Week":
        return List.generate(7, (i) => i);
      case "Month":
        return [0, 7, 14, 21];
      case "Year":
        return [0, 2, 4, 6, 8, 10];
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
    if (range == "Day") return 4.0;
    if (range == "Month") return 7.0;
    if (dataLength > 20) return 4.0;
    if (dataLength > 10) return 2.0;
    return 1.0;
  }

  double _getFontSize(String range) {
    if (range == "Day" || range == "Month") return 9.0;
    return 10.0;
  }
}