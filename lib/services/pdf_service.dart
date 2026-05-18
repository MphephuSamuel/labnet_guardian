import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generateAdvancedReport({
    required String range,
    required Map<String, dynamic>? bandwidthData,
    required List<dynamic> threats,
    required List<dynamic> anomalies,
  }) async {
    final pdf = pw.Document();

    final averageBandwidth =
        bandwidthData?["averageBandwidth"] ?? 0;

    final activeDevices =
        bandwidthData?["activeDevices"] ?? 0;

    final traffic =
        List<dynamic>.from(bandwidthData?["traffic"] ?? []);

    final bandwidth =
        List<dynamic>.from(bandwidthData?["bandwidth"] ?? []);

    final threatTimeline =
        List<dynamic>.from(bandwidthData?["threats"] ?? []);

    pdf.addPage(
      pw.MultiPage(
        pageTheme: const pw.PageTheme(
          margin: pw.EdgeInsets.all(24),
        ),

        build: (context) => [

          // ================= TITLE =================
          pw.Text(
            "LabNet Guardian Analytics Report",
            style: pw.TextStyle(
              fontSize: 26,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 8),

          pw.Text(
            "Time Range: $range",
            style: const pw.TextStyle(fontSize: 14),
          ),

          pw.Divider(),

          pw.SizedBox(height: 20),

          // ================= KPI SECTION =================
          pw.Text(
            "Key Performance Indicators",
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 15),

          pw.Table(
            border: pw.TableBorder.all(
              color: PdfColors.grey300,
              width: 1,
            ),

            children: [

              _tableRow(
                "Average Bandwidth",
                "$averageBandwidth GB",
              ),

              _tableRow(
                "Active Devices",
                "$activeDevices",
              ),

              _tableRow(
                "Threats Blocked",
                "${threats.length}",
              ),

              _tableRow(
                "Anomalies Detected",
                "${anomalies.length}",
              ),
            ],
          ),

          pw.SizedBox(height: 30),

          // ================= NETWORK TRAFFIC =================
          pw.Text(
            "Network Traffic Data",
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 10),

          traffic.isEmpty
              ? pw.Text("No traffic data available.")
              : pw.Column(
                  children: traffic
                      .asMap()
                      .entries
                      .map(
                        (e) => pw.Text(
                          "Day ${e.key + 1}: ${e.value}",
                        ),
                      )
                      .toList(),
                ),

          pw.SizedBox(height: 25),

          // ================= BANDWIDTH =================
          pw.Text(
            "Bandwidth Usage Data",
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 10),

          bandwidth.isEmpty
              ? pw.Text("No bandwidth data available.")
              : pw.Column(
                  children: bandwidth
                      .asMap()
                      .entries
                      .map(
                        (e) => pw.Text(
                          "Day ${e.key + 1}: ${e.value} GB",
                        ),
                      )
                      .toList(),
                ),

          pw.SizedBox(height: 25),

          // ================= THREAT TIMELINE =================
          pw.Text(
            "Threat Timeline",
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 10),

          threatTimeline.isEmpty
              ? pw.Text("No threat timeline available.")
              : pw.Column(
                  children: threatTimeline
                      .asMap()
                      .entries
                      .map(
                        (e) => pw.Text(
                          "Period ${e.key + 1}: ${e.value} threats",
                        ),
                      )
                      .toList(),
                ),

          pw.SizedBox(height: 30),

          // ================= SUMMARY =================
          pw.Text(
            "Summary",
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 10),

          pw.Bullet(text: "Analytics generated successfully."),
          pw.Bullet(text: "Bandwidth trends monitored."),
          pw.Bullet(text: "Threat detection analysed."),
          pw.Bullet(text: "Anomalies recorded and reviewed."),
          pw.Bullet(text: "Network performance evaluated."),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // ================= TABLE ROW =================
  static pw.TableRow _tableRow(
    String title,
    String value,
  ) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(10),
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),

        pw.Padding(
          padding: const pw.EdgeInsets.all(10),
          child: pw.Text(value),
        ),
      ],
    );
  }
}