import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import '../utils/colors.dart';

class PdfService {
  // Convert hex colors to PdfColor (values 0-1)
  static PdfColor getColor(int hex) {
    return PdfColor(
      ((hex >> 16) & 0xFF) / 255.0,
      ((hex >> 8) & 0xFF) / 255.0,
      (hex & 0xFF) / 255.0,
    );
  }
  
  static const int primaryHex = 0x6C63FF;
  static const int gradientStartHex = 0x8A5CFF;
  static const int gradientEndHex = 0xB06CFF;
  static const int criticalHex = 0xFF4D6D;
  static const int warningHex = 0xFFB347;
  static const int successHex = 0x4CAF50;
  
  static Future<void> generateAdvancedReport({
    required String range,
    required Map<String, dynamic> bandwidthData,
    required List<double> threats,
    required List<dynamic> anomalies,
  }) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          _buildHeader(range),
          _buildStatsSection(bandwidthData, threats, anomalies),
          _buildChartsSection(bandwidthData, threats, anomalies, range),
          _buildFooter(),
        ],
        footer: (pw.Context context) => _buildPageNumber(context),
      ),
    );
    
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'analytics_report_${DateTime.now().toIso8601String()}.pdf',
    );
  }
  
  static pw.Widget _buildHeader(String range) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [
            getColor(gradientStartHex),
            getColor(gradientEndHex),
          ],
          begin: pw.Alignment.centerLeft,
          end: pw.Alignment.centerRight,
        ),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'LabNet Security Report',
            style: pw.TextStyle(
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Network Analytics Dashboard',
            style: pw.TextStyle(
              fontSize: 16,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(20),
            ),
            child: pw.Text(
              'Period: $range',
              style: pw.TextStyle(
                color: getColor(primaryHex),
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildStatsSection(Map<String, dynamic> bandwidthData, List<double> threats, List<dynamic> anomalies) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Key Metrics',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey900,
            ),
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard(
                'Avg Bandwidth',
                '${bandwidthData['averageBandwidth']?.toStringAsFixed(1) ?? '0'} MB/s',
                getColor(primaryHex),
              ),
              _buildStatCard(
                'Threats Detected',
                threats.length.toString(),
                getColor(criticalHex),
              ),
              _buildStatCard(
                'Anomalies',
                anomalies.length.toString(),
                getColor(warningHex),
              ),
              _buildStatCard(
                'Report Date',
                DateTime.now().toString().substring(0, 10),
                getColor(successHex),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildStatCard(String title, String value, PdfColor color) {
    return pw.Container(
      width: 120,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColor(color.red, color.green, color.blue, 0.1),
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(
          color: PdfColor(color.red, color.green, color.blue, 0.3),
        ),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildChartsSection(Map<String, dynamic> bandwidthData, List<double> threats, List<dynamic> anomalies, String range) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Network Traffic Analysis',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey900,
          ),
        ),
        pw.SizedBox(height: 15),
        _buildTrafficChart(bandwidthData),
        pw.SizedBox(height: 30),
        pw.Text(
          'Security Threats',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey900,
          ),
        ),
        pw.SizedBox(height: 15),
        _buildThreatChart(threats),
        pw.SizedBox(height: 30),
        pw.Text(
          'Anomalies Overview',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey900,
          ),
        ),
        pw.SizedBox(height: 15),
        _buildAnomaliesTable(anomalies),
      ],
    );
  }
  
  static pw.Widget _buildTrafficChart(Map<String, dynamic> bandwidthData) {
    final avgBandwidth = (bandwidthData['averageBandwidth'] ?? 45.5).toDouble();
    final chartHeight = 80.0;
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final height = (avgBandwidth / 100) * chartHeight;
              return pw.Column(
                children: [
                  pw.Container(
                    width: 30,
                    height: height.clamp(10.0, chartHeight),
                    decoration: pw.BoxDecoration(
                      color: getColor(primaryHex),
                      borderRadius: pw.BorderRadius.vertical(
                        top: pw.Radius.circular(5),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Day ${index + 1}',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ],
              );
            }),
          ),
          pw.SizedBox(height: 15),
          pw.Text(
            'Bandwidth Usage (MB/s)',
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildThreatChart(List<double> threats) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: List.generate(threats.length > 7 ? 7 : threats.length, (index) {
              final threatCount = index < threats.length ? threats[index].toInt() : 0;
              final height = (threatCount / 20) * 80;
              return pw.Column(
                children: [
                  pw.Container(
                    width: 30,
                    height: height.clamp(5.0, 80.0),
                    decoration: pw.BoxDecoration(
                      color: getColor(criticalHex),
                      borderRadius: pw.BorderRadius.vertical(
                        top: pw.Radius.circular(5),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Day ${index + 1}',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    '$threatCount',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              );
            }),
          ),
          pw.SizedBox(height: 15),
          pw.Text(
            'Threats Timeline',
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildAnomaliesTable(List<dynamic> anomalies) {
    if (anomalies.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(20),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: pw.BorderRadius.circular(10),
        ),
        child: pw.Text(
          'No anomalies detected during this period.',
          style: pw.TextStyle(fontSize: 14, color: PdfColors.grey600),
          textAlign: pw.TextAlign.center,
        ),
      );
    }
    
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey300),
        columnWidths: {
          0: pw.FlexColumnWidth(2),
          1: pw.FlexColumnWidth(2),
          2: pw.FlexColumnWidth(3),
          3: pw.FlexColumnWidth(2),
        },
        children: [
          pw.TableRow(
            decoration: pw.BoxDecoration(
              color: PdfColor(
                getColor(primaryHex).red,
                getColor(primaryHex).green,
                getColor(primaryHex).blue,
                0.1
              )
            ),
            children: [
              _buildTableCell('Device', isHeader: true),
              _buildTableCell('Type', isHeader: true),
              _buildTableCell('Message', isHeader: true),
              _buildTableCell('Severity', isHeader: true),
            ],
          ),
          ...anomalies.take(10).map((anomaly) => pw.TableRow(
            children: [
              _buildTableCell(anomaly['deviceId']?.toString() ?? 'N/A'),
              _buildTableCell(anomaly['deviceType']?.toString() ?? 'N/A'),
              _buildTableCell(anomaly['message']?.toString() ?? 'N/A'),
              _buildTableCell(
                anomaly['severity']?.toString() ?? 'N/A',
                color: _getSeverityColor(anomaly['severity']?.toString()),
              ),
            ],
          )),
        ],
      ),
    );
  }
  
  static pw.Widget _buildTableCell(String text, {bool isHeader = false, PdfColor? color}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? (isHeader ? getColor(primaryHex) : PdfColors.grey800),
        ),
      ),
    );
  }
  
  static PdfColor _getSeverityColor(String? severity) {
    switch(severity?.toLowerCase()) {
      case 'high':
      case 'critical':
        return getColor(criticalHex);
      case 'medium':
        return getColor(warningHex);
      case 'low':
        return getColor(successHex);
      default:
        return PdfColors.grey600;
    }
  }
  
  static pw.Widget _buildFooter() {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      padding: const pw.EdgeInsets.all(10),
      child: pw.Text(
        '© ${DateTime.now().year} LabNet Security - Generated on ${DateTime.now().toString().substring(0, 19)}',
        style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
  
  static pw.Widget _buildPageNumber(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.center,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
      ),
    );
  }
}