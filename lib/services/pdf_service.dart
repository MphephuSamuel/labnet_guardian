import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class PdfService {
  // App colors matching your theme
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
    final pdf = pw.Document();

    // PAGE 1: HEADER & METRICS
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) => [
          _buildHeader(range),
          pw.SizedBox(height: 20),
          _buildExecutiveSummary(range, bandwidthData, threats, anomalies),
          pw.SizedBox(height: 20),
          _buildMetricsGrid(bandwidthData, threats, anomalies),
          pw.SizedBox(height: 20),
          _buildRangeComparison(),
          pw.SizedBox(height: 20),
          _buildFooter(),
        ],
        footer: (pw.Context context) => _buildPageNumber(context),
      ),
    );

    // PAGE 2: CHARTS
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) => [
          _buildChartsSection(bandwidthData, threats, anomalies),
          pw.SizedBox(height: 20),
          _buildThreatTimeline(threats),
          pw.SizedBox(height: 20),
          _buildFooter(),
        ],
        footer: (pw.Context context) => _buildPageNumber(context),
      ),
    );

    // PAGE 3: ANOMALIES
    if (anomalies.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) => [
            _buildAnomaliesSection(anomalies),
            pw.SizedBox(height: 20),
            _buildFooter(),
          ],
          footer: (pw.Context context) => _buildPageNumber(context),
        ),
      );
    }

    final bytes = await pdf.save();
    await _saveAndOpen(bytes);
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
              pw.Text(
                '[L]',
                style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold, color: whiteColor),
              ),
              pw.SizedBox(width: 10),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'LabNet Guardian',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.normal,
                      color: white70Color,
                    ),
                  ),
                  pw.Text(
                    'Security Report',
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                      color: whiteColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            children: [
              _buildBadge('Period: $range', primaryColor),
              pw.SizedBox(width: 10),
              _buildBadge(
                'Generated: ${DateTime.now().toString().substring(0, 19)}',
                successColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildBadge(String text, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: pw.BoxDecoration(
        color: whiteColor,
        borderRadius: pw.BorderRadius.circular(20),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: color,
          fontWeight: pw.FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  static pw.Widget _buildExecutiveSummary(
    String range,
    Map<String, dynamic> bandwidthData,
    List<double> threats,
    List<dynamic> anomalies,
  ) {
    final avgBw = bandwidthData['averageBandwidth']?.toStringAsFixed(1) ?? '0';
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Executive Summary',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: textDark),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Text(
            'Network security assessment completed for the $range period.\n'
            'Total anomalies detected: ${anomalies.length}\n'
            'Threats blocked: ${threats.length}\n'
            'Average bandwidth usage: $avgBw MB/s.',
            style: pw.TextStyle(fontSize: 11, color: textDark),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildMetricsGrid(
    Map<String, dynamic> bandwidthData,
    List<double> threats,
    List<dynamic> anomalies,
  ) {
    final avgBw = bandwidthData['averageBandwidth']?.toStringAsFixed(1) ?? '0';
    final securityScore = _calculateSecurityScore(threats.length, anomalies.length);
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Key Metrics',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: textDark),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _buildMetricCard('Avg Bandwidth', avgBw, 'MB/s', primaryColor),
            _buildMetricCard('Threats Blocked', threats.length.toString(), '', criticalColor),
            _buildMetricCard('Anomalies', anomalies.length.toString(), '', warningColor),
            _buildMetricCard('Security Score', securityScore.toString(), '%', successColor),
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
        color: PdfColor(color.red, color.green, color.blue, 0.1),
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColor(color.red, color.green, color.blue, 0.2)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: color),
          ),
          if (suffix.isNotEmpty)
            pw.Text(suffix, style: pw.TextStyle(fontSize: 10, color: color)),
          pw.SizedBox(height: 4),
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 9, color: textLight),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildRangeComparison() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Time Range Comparison',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: textDark),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: pw.FlexColumnWidth(1),
            1: pw.FlexColumnWidth(1),
            2: pw.FlexColumnWidth(1),
            3: pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColor(0.42, 0.39, 1.0, 0.1)),
              children: [
                _buildTableHeader('Range'),
                _buildTableHeader('Threats'),
                _buildTableHeader('Anomalies'),
                _buildTableHeader('Bandwidth'),
              ],
            ),
            _buildTableRow('Day', '2-5', '1-2', '35-45 MB/s'),
            _buildTableRow('Week', '15-20', '5-10', '40-50 MB/s'),
            _buildTableRow('Month', '45-60', '15-25', '45-55 MB/s'),
            _buildTableRow('Year', '120+', '50+', '50-60 MB/s'),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTableHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.TableRow _buildTableRow(String range, String threats, String anomalies, String bandwidth) {
    return pw.TableRow(
      children: [
        _buildTableCell(range),
        _buildTableCell(threats),
        _buildTableCell(anomalies),
        _buildTableCell(bandwidth),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.center),
    );
  }

  static pw.Widget _buildChartsSection(
    Map<String, dynamic> bandwidthData,
    List<double> threats,
    List<dynamic> anomalies,
  ) {
    final avgBandwidth = bandwidthData['averageBandwidth'] ?? 0.0;
    final usagePercent = (avgBandwidth / 100).clamp(0.0, 1.0);
    final securityScore = _calculateSecurityScore(threats.length, anomalies.length);
    final threatScore = _calculateThreatProtectionScore(threats.length);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Network Analysis',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: textDark),
        ),
        pw.SizedBox(height: 15),
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Column(
            children: [
              pw.Text(
                'Bandwidth Usage',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Text('${avgBandwidth.toStringAsFixed(1)} MB/s',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: primaryColor)),
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
            ],
          ),
        ),
        pw.SizedBox(height: 15),
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Column(
            children: [
              pw.Text(
                'Security Summary',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              _buildSecurityBar('System Security', securityScore),
              _buildSecurityBar('Network Stability', 85),
              _buildSecurityBar('Threat Protection', threatScore),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSecurityBar(String label, int score) {
    final barWidth = (score / 100 * 200).clamp(0.0, 200.0);
    final scoreColor = _getScoreColor(score);
    
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label, style: pw.TextStyle(fontSize: 10)),
            pw.Text('$score%', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Container(
          height: 6,
          decoration: pw.BoxDecoration(
            color: PdfColors.grey300,
            borderRadius: pw.BorderRadius.circular(3),
          ),
          child: pw.Container(
            width: barWidth,
            height: 6,
            decoration: pw.BoxDecoration(
              color: scoreColor,
              borderRadius: pw.BorderRadius.circular(3),
            ),
          ),
        ),
        pw.SizedBox(height: 8),
      ],
    );
  }

  static pw.Widget _buildThreatTimeline(List<double> threats) {
    final displayThreats = threats.length > 7 ? threats.sublist(0, 7) : threats;
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Threat Timeline',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: textDark),
        ),
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
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: List.generate(displayThreats.length, (index) {
                  final count = displayThreats[index].toInt();
                  final barHeight = (count * 3).clamp(5, 50).toDouble();
                  return pw.Column(
                    children: [
                      pw.Container(
                        width: 25,
                        height: barHeight,
                        decoration: pw.BoxDecoration(
                          color: criticalColor,
                          borderRadius: pw.BorderRadius.vertical(top: pw.Radius.circular(3)),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Day ${index + 1}',
                        style: pw.TextStyle(fontSize: 7),
                      ),
                      pw.Text(
                        count.toString(),
                        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  );
                }),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Threats detected over time', style: pw.TextStyle(fontSize: 9, color: textLight)),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildAnomaliesSection(List<dynamic> anomalies) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Anomalies Detected',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: textDark),
        ),
        pw.SizedBox(height: 15),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: pw.FlexColumnWidth(2),
            1: pw.FlexColumnWidth(2),
            2: pw.FlexColumnWidth(3),
            3: pw.FlexColumnWidth(1),
          },
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
            ...anomalies.take(15).map((anomaly) => pw.TableRow(
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
        if (anomalies.length > 15)
          pw.SizedBox(height: 10),
        if (anomalies.length > 15)
          pw.Text(
            '* Showing first 15 anomalies out of ${anomalies.length}',
            style: pw.TextStyle(fontSize: 8, color: textLight),
          ),
      ],
    );
  }

  static pw.Widget _buildTableCellWithColor(String text, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: color),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 30),
      padding: const pw.EdgeInsets.all(10),
      child: pw.Column(
        children: [
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Text(
            'LabNet Guardian - Network Security System',
            style: pw.TextStyle(fontSize: 8, color: textLight),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            '(C) ${DateTime.now().year} All Rights Reserved',
            style: pw.TextStyle(fontSize: 7, color: textLight),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPageNumber(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.center,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: pw.TextStyle(fontSize: 8, color: textLight),
      ),
    );
  }

  static int _calculateSecurityScore(int threats, int anomalies) {
    final score = ((1 - (threats + anomalies) / 200) * 100).clamp(0, 100).toInt();
    return score;
  }

  static int _calculateThreatProtectionScore(int threats) {
    final score = ((1 - threats / 200) * 100).clamp(50, 100).toInt();
    return score;
  }

  static PdfColor _getScoreColor(int score) {
    if (score >= 80) return successColor;
    if (score >= 60) return warningColor;
    return criticalColor;
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

  static Future<void> _saveAndOpen(Uint8List bytes) async {
    try {
      // Save to app's temporary directory (no permission needed)
      final directory = await getTemporaryDirectory();
      final fileName = "LabNet_Report_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final file = File("${directory.path}/$fileName");
      await file.writeAsBytes(bytes);

      print("PDF saved to: ${file.path}");
      
      // Open the file with default PDF viewer
      await OpenFile.open(file.path);
    } catch (e) {
      print("PDF Error: $e");
    }
  }
}