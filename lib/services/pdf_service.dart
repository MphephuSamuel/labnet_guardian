import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfService {
  static const PdfColor primaryColor = PdfColor(0.42, 0.39, 1.0);
  static const PdfColor gradientStart = PdfColor(0.54, 0.36, 1.0);
  static const PdfColor gradientEnd = PdfColor(0.69, 0.42, 1.0);
  static const PdfColor criticalColor = PdfColor(1.0, 0.30, 0.43);
  static const PdfColor warningColor = PdfColor(1.0, 0.70, 0.28);
  static const PdfColor successColor = PdfColor(0.30, 0.69, 0.31);
  static const PdfColor textDark = PdfColor(0.10, 0.10, 0.20);
  static const PdfColor textLight = PdfColor(0.50, 0.50, 0.60);
  static const PdfColor whiteColor = PdfColor(1.0, 1.0, 1.0);
  static const PdfColor white70Color = PdfColor(1.0, 1.0, 1.0, 0.7);

  static Future<void> generateAdvancedReport({
    required String range,
    required Map<String, dynamic> bandwidthData,
    required List<double> threats,
    required List<dynamic> anomalies,
  }) async {
    // Calculate ACTUAL counts from your data
    final actualThreatCount = threats.isEmpty ? 0 : threats.reduce((a, b) => a + b).toInt();
    final actualAnomalyCount = anomalies.length;
    final avgBandwidth = bandwidthData['averageBandwidth'] ?? 0;
    final activeDevices = bandwidthData['activeDevices'] ?? 0;
    
    print("=" * 50);
    print("📄 GENERATING PDF WITH REAL DATA:");
    print("   Range: $range");
    print("   Avg Bandwidth: $avgBandwidth MB/s");
    print("   Active Devices: $activeDevices");
    print("   Threats Blocked: $actualThreatCount");
    print("   Anomalies: $actualAnomalyCount");
    print("=" * 50);
    
    final pdf = pw.Document();

    // PAGE 1: HEADER & METRICS
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) => [
          _buildHeader(range),
          pw.SizedBox(height: 20),
          _buildExecutiveSummary(avgBandwidth, activeDevices, actualThreatCount, actualAnomalyCount),
          pw.SizedBox(height: 20),
          _buildMetricsGrid(avgBandwidth, activeDevices, actualThreatCount, actualAnomalyCount),
          pw.SizedBox(height: 25),
          _buildBandwidthChart(avgBandwidth),
          pw.SizedBox(height: 25),
          _buildFooter(),
        ],
        footer: (pw.Context context) => _buildPageNumber(context),
      ),
    );

    // PAGE 2: THREAT TIMELINE
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) => [
          _buildThreatTimeline(threats, actualThreatCount),
          pw.SizedBox(height: 25),
          _buildFooter(),
        ],
        footer: (pw.Context context) => _buildPageNumber(context),
      ),
    );

    // PAGE 3: ANOMALIES DETAILS
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) => [
          _buildAnomaliesSection(anomalies, actualAnomalyCount),
          pw.SizedBox(height: 25),
          _buildFooter(),
        ],
        footer: (pw.Context context) => _buildPageNumber(context),
      ),
    );

    final bytes = await pdf.save();
    await _saveAndShare(bytes);
  }

  static pw.Widget _buildHeader(String range) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [gradientStart, gradientEnd],
          begin: pw.Alignment.centerLeft,
          end: pw.Alignment.centerRight,
        ),
        borderRadius: pw.BorderRadius.circular(15),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Text('📊', style: pw.TextStyle(fontSize: 40)),
              pw.SizedBox(width: 10),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('LabNet Guardian',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.normal, color: white70Color)),
                  pw.Text('Security Report',
                      style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: whiteColor)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            children: [
              _buildBadge('Period: $range', primaryColor),
              pw.SizedBox(width: 10),
              _buildBadge('Generated: ${DateTime.now().toString().substring(0, 19)}', successColor),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildBadge(String text, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: pw.BoxDecoration(color: whiteColor, borderRadius: pw.BorderRadius.circular(20)),
      child: pw.Text(text, style: pw.TextStyle(color: color, fontWeight: pw.FontWeight.bold, fontSize: 10)),
    );
  }

  static pw.Widget _buildExecutiveSummary(
    double avgBandwidth,
    int activeDevices,
    int threatCount,
    int anomalyCount,
  ) {
    String securityStatus;
    if (threatCount == 0 && anomalyCount == 0) {
      securityStatus = "SECURE - No threats detected";
    } else if (threatCount < 5 && anomalyCount < 3) {
      securityStatus = "GOOD - Minor issues detected";
    } else if (threatCount < 15 && anomalyCount < 8) {
      securityStatus = "MODERATE - Review recommended";
    } else {
      securityStatus = "CRITICAL - Action required";
    }
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Executive Summary',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: textDark)),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Network Security Assessment Report',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                '• Active Devices: $activeDevices\n'
                '• Average Bandwidth: ${avgBandwidth.toStringAsFixed(1)} MB/s\n'
                '• Threats Blocked: $threatCount\n'
                '• Anomalies Detected: $anomalyCount\n\n'
                'Status: $securityStatus\n\n'
                'All systems are operational. The network security system has successfully '
                'blocked $threatCount threats and detected $anomalyCount anomalies during '
                'the reporting period.',
                style: pw.TextStyle(fontSize: 11, color: textDark),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildMetricsGrid(
    double avgBandwidth,
    int activeDevices,
    int threatCount,
    int anomalyCount,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Key Metrics',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: whiteColor)), // WHITE TEXT
        pw.SizedBox(height: 15),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _buildMetricCard('Active Devices', activeDevices.toString(), '', successColor),
            _buildMetricCard('Avg Bandwidth', avgBandwidth.toStringAsFixed(1), 'MB/s', primaryColor),
            _buildMetricCard('Threats Blocked', threatCount.toString(), '', criticalColor),
            _buildMetricCard('Anomalies', anomalyCount.toString(), '', warningColor),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildMetricCard(String title, String value, String suffix, PdfColor color) {
    return pw.Container(
      width: 110,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor(color.red, color.green, color.blue, 0.15),
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColor(color.red, color.green, color.blue, 0.3)),
      ),
      child: pw.Column(
        children: [
          pw.Text(value, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: whiteColor)), // WHITE VALUE
          if (suffix.isNotEmpty) 
            pw.Text(suffix, style: pw.TextStyle(fontSize: 10, color: white70Color)), // WHITE SUFFIX
          pw.SizedBox(height: 8),
          pw.Text(title, style: pw.TextStyle(fontSize: 9, color: white70Color), textAlign: pw.TextAlign.center), // WHITE TITLE
        ],
      ),
    );
  }

  static pw.Widget _buildBandwidthChart(double avgBandwidth) {
    final usagePercent = (avgBandwidth / 100).clamp(0.0, 1.0);
    final dailyTraffic = avgBandwidth * 86.4;
    final weeklyTraffic = dailyTraffic * 7;
    final monthlyTraffic = dailyTraffic * 30;
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Bandwidth Analysis',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: textDark)),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Current Bandwidth:',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.Text('${avgBandwidth.toStringAsFixed(1)} MB/s',
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                height: 10,
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey300,
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Container(
                  width: (usagePercent * 250).clamp(0.0, 250.0),
                  height: 10,
                  decoration: pw.BoxDecoration(
                    color: primaryColor,
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                ),
              ),
              pw.SizedBox(height: 15),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildTrafficCard('Daily', dailyTraffic),
                  _buildTrafficCard('Weekly', weeklyTraffic),
                  _buildTrafficCard('Monthly', monthlyTraffic),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTrafficCard(String period, double value) {
    return pw.Container(
      width: 100,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: whiteColor,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        children: [
          pw.Text(period, style: pw.TextStyle(fontSize: 9, color: textLight)),
          pw.Text('${value.toStringAsFixed(1)} GB',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: primaryColor)),
        ],
      ),
    );
  }

  static pw.Widget _buildThreatTimeline(List<double> threats, int totalThreats) {
    final maxThreat = threats.isEmpty ? 1 : threats.reduce((a, b) => a > b ? a : b).toInt();
    final displayThreats = threats.length > 7 ? threats.sublist(0, 7) : threats;
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Threat Timeline',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: textDark)),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Column(
            children: [
              pw.Text('Total Threats: $totalThreats',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: criticalColor)),
              pw.SizedBox(height: 15),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: List.generate(displayThreats.length, (index) {
                  final count = displayThreats[index].toInt();
                  final barHeight = maxThreat > 0 ? (count / maxThreat * 40).clamp(5.0, 40.0) : 5.0;
                  return pw.Column(
                    children: [
                      pw.Container(
                        width: 20,
                        height: barHeight,
                        decoration: pw.BoxDecoration(
                          color: count > 0 ? criticalColor : PdfColors.grey400,
                          borderRadius: pw.BorderRadius.vertical(top: pw.Radius.circular(3)),
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text('Day ${index + 1}', style: pw.TextStyle(fontSize: 7)),
                      pw.Text(count.toString(), style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    ],
                  );
                }),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Threat distribution over the ${displayThreats.length}-day period',
                  style: pw.TextStyle(fontSize: 9, color: textLight)),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildAnomaliesSection(List<dynamic> anomalies, int totalAnomalies) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Anomalies Report',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: textDark)),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Column(
            children: [
              pw.Text('Total Anomalies: $totalAnomalies',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: warningColor)),
              pw.SizedBox(height: 15),
              if (anomalies.isEmpty)
                pw.Text('No anomalies detected during this period.',
                    style: pw.TextStyle(fontSize: 11, color: successColor))
              else
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  columnWidths: {0: pw.FlexColumnWidth(2), 1: pw.FlexColumnWidth(2), 2: pw.FlexColumnWidth(3), 3: pw.FlexColumnWidth(1)},
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColor(0.42, 0.39, 1.0, 0.1)),
                      children: [
                        _buildTableHeader('Device'),
                        _buildTableHeader('Type'),
                        _buildTableHeader('Message'),
                        _buildTableHeader('Severity'),
                      ],
                    ),
                    ...anomalies.map((anomaly) => pw.TableRow(
                      children: [
                        _buildTableCell(anomaly['deviceId']?.toString() ?? 'N/A'),
                        _buildTableCell(anomaly['deviceType']?.toString() ?? 'N/A'),
                        _buildTableCell(anomaly['message']?.toString() ?? 'N/A'),
                        _buildTableCellWithColor(
                          anomaly['severity']?.toString() ?? 'N/A',
                          _getSeverityColor(anomaly['severity']?.toString()),
                        ),
                      ],
                    )),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text,
          style: pw.TextStyle(
            fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
            fontSize: isHeader ? 11 : 9,
          ),
          textAlign: pw.TextAlign.center),
    );
  }

  static pw.Widget _buildTableHeader(String text) => _buildTableCell(text, isHeader: true);

  static pw.Widget _buildTableCellWithColor(String text, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text,
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: color),
          textAlign: pw.TextAlign.center),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      padding: const pw.EdgeInsets.all(10),
      child: pw.Column(
        children: [
          pw.Divider(thickness: 0.5),
          pw.SizedBox(height: 5),
          pw.Text('LabNet Guardian - Network Security System',
              style: pw.TextStyle(fontSize: 8, color: textLight), textAlign: pw.TextAlign.center),
          pw.Text('© ${DateTime.now().year} All Rights Reserved',
              style: pw.TextStyle(fontSize: 7, color: textLight), textAlign: pw.TextAlign.center),
        ],
      ),
    );
  }

  static pw.Widget _buildPageNumber(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.center,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
          style: pw.TextStyle(fontSize: 8, color: textLight)),
    );
  }

  static PdfColor _getSeverityColor(String? severity) {
    switch (severity?.toLowerCase()) {
      case 'high':
      case 'critical':
        return criticalColor;
      case 'medium':
        return warningColor;
      default:
        return successColor;
    }
  }

  static Future<void> _saveAndShare(Uint8List bytes) async {
    try {
      final directory = await getTemporaryDirectory();
      final fileName = "LabNet_Report_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final file = File("${directory.path}/$fileName");
      await file.writeAsBytes(bytes);
      print("✅ PDF saved to: ${file.path}");
      await Share.shareXFiles([XFile(file.path)], text: 'LabNet Security Report');
    } catch (e) {
      print("❌ PDF Error: $e");
    }
  }
}