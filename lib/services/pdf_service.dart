import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';


class PdfService {
  static Future<void> generateAdvancedReport({
    required String range,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [

          // 🔷 TITLE
          pw.Text(
            "LabNet Guardian Analytics Report",
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 10),
          pw.Text("Time Range: $range"),
          pw.Text("Generated: ${DateTime.now()}"),

          pw.Divider(),

          // 📊 KPI SECTION
          pw.Header(level: 1, text: "Key Metrics"),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _kpiBox("Bandwidth", "428 GB"),
              _kpiBox("Devices", "87"),
              _kpiBox("Threats", "55"),
              _kpiBox("Anomalies", "12"),
            ],
          ),

          pw.SizedBox(height: 20),

          // 📈 NETWORK TRAFFIC CHART (REAL DRAWN)
          pw.Header(level: 1, text: "Network Traffic"),

          _buildChart(),

          pw.SizedBox(height: 20),

          // 🧾 DEVICE TABLE
          pw.Header(level: 1, text: "Connected Devices"),

          _buildDeviceTable(),

          pw.SizedBox(height: 20),

          // 🚨 THREAT TABLE
          pw.Header(level: 1, text: "Threat Logs"),

          _buildThreatTable(),

          pw.SizedBox(height: 20),

          // 📄 SUMMARY
          pw.Header(level: 1, text: "Report Summary"),

          pw.Paragraph(
            text:
                "This report presents network performance data across $range. "
                "Bandwidth usage shows steady growth, while threat detection "
                "increased during peak hours. The system successfully detected "
                "and mitigated anomalies.",
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  // ===========================
  // 📊 KPI BOX
  // ===========================
  static pw.Widget _kpiBox(String title, String value) {
    return pw.Container(
      width: 120,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
      ),
      child: pw.Column(
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 5),
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  // ===========================
  // 📈 SIMPLE LINE CHART (REAL)
  // ===========================
  static pw.Widget _buildChart() {
    final data = [2.0, 3.0, 2.5, 4.0, 3.8, 5.0];

    return pw.Container(
      height: 200,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: data.map((value) {
          return pw.Expanded(
            child: pw.Container(
              margin: const pw.EdgeInsets.symmetric(horizontal: 4),
              height: value * 30,
              color: PdfColors.blue,
            ),
          );
        }).toList(),
      ),
    );
  }

  // ===========================
  // 🧾 DEVICE TABLE
  // ===========================
  static pw.Widget _buildDeviceTable() {
    return pw.TableHelper.fromTextArray(
      headers: ["IP Address", "MAC Address", "Usage"],
      data: [
        ["192.168.1.2", "AA:BB:CC:DD", "120 MB"],
        ["192.168.1.3", "EE:FF:GG:HH", "300 MB"],
        ["192.168.1.4", "II:JJ:KK:LL", "90 MB"],
      ],
    );
  }

  // ===========================
  // 🚨 THREAT TABLE
  // ===========================
  static pw.Widget _buildThreatTable() {
    return pw.TableHelper.fromTextArray(
      headers: ["Time", "Threat Type", "Status"],
      data: [
        ["10:00", "Port Scan", "Blocked"],
        ["11:20", "DDoS Attempt", "Mitigated"],
        ["13:45", "Suspicious Login", "Flagged"],
      ],
    );
  }
}