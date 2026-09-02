import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/analytics_state.dart';

class PdfReportService {
  // Color scheme (static so they are computed once)
  static final _primary = PdfColor.fromInt(0xFF7E73FF);
  static final _success = PdfColor.fromInt(0xFF00C853);
  static final _warning = PdfColor.fromInt(0xFFFF6D00);
  static final _danger = PdfColor.fromInt(0xFFD50000);

  static PdfColor _statusColor(double pct) {
    if (pct >= 75) return _success;
    if (pct >= 60) return _warning;
    return _danger;
  }

  /// Generates and returns an attendance report as PDF bytes.
  static Future<Uint8List> generateReport({
    required AnalyticsState state,
    required String semesterName,
    bool isDetailed = false,
  }) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.interRegular();
    final boldFont = await PdfGoogleFonts.interBold();
    final dateStr = DateFormat('MMMM d, yyyy').format(DateTime.now());

    final summary = state.overallSummary;
    final forecast = state.overallForecast;
    final overallPct = summary != null && summary.effectiveTotal > 0
        ? (summary.effectivePresent / summary.effectiveTotal * 100)
        : 0.0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (context) => [
          // ── Header ──────────────────────────────────────────────────
          pw.Container(
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: pw.BoxDecoration(
              color: _primary,
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Attendify',
                        style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 22,
                            color: PdfColors.white)),
                    pw.SizedBox(height: 4),
                    pw.Text('Attendance Report',
                        style: const pw.TextStyle(
                            fontSize: 12, color: PdfColors.white)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(semesterName,
                        style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 13,
                            color: PdfColors.white)),
                    pw.SizedBox(height: 4),
                    pw.Text('Generated: $dateStr',
                        style: const pw.TextStyle(
                            fontSize: 10, color: PdfColors.white)),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // ── Overall Summary Cards ─────────────────────────────────
          pw.Text('Overall Summary',
              style: pw.TextStyle(
                  font: boldFont, fontSize: 15, color: PdfColors.grey900)),
          pw.SizedBox(height: 10),

          pw.Row(
            children: [
              _buildSummaryCard(
                label: 'Overall Attendance',
                value: '${overallPct.toStringAsFixed(1)}%',
                color: _statusColor(overallPct),
                font: boldFont,
              ),
              pw.SizedBox(width: 10),
              _buildSummaryCard(
                label: 'Classes Attended',
                value: '${summary?.effectivePresent ?? 0}',
                color: _success,
                font: boldFont,
              ),
              pw.SizedBox(width: 10),
              _buildSummaryCard(
                label: 'Classes Missed',
                value: '${summary?.totalAbsentRecords ?? 0}',
                color: _danger,
                font: boldFont,
              ),
              pw.SizedBox(width: 10),
              _buildSummaryCard(
                label: 'Safe Bunks Left',
                value: '${forecast?.safeBunksRemaining ?? 0}',
                color: _primary,
                font: boldFont,
              ),
            ],
          ),

          pw.SizedBox(height: 24),

          // ── Subject Breakdown Table ───────────────────────────────
          pw.Text('Subject Breakdown',
              style: pw.TextStyle(
                  font: boldFont, fontSize: 15, color: PdfColors.grey900)),
          pw.SizedBox(height: 10),

          pw.Table(
            border: null,
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1.5),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(1.5),
            },
            children: [
              // Header row
              pw.TableRow(
                decoration: pw.BoxDecoration(color: _primary),
                children: [
                  _tableCell('Subject', font: boldFont, isHeader: true),
                  _tableCell('Present', font: boldFont, isHeader: true),
                  _tableCell('Total', font: boldFont, isHeader: true),
                  _tableCell('Attendance', font: boldFont, isHeader: true),
                  _tableCell('Safe Bunks', font: boldFont, isHeader: true),
                ],
              ),
              // Data rows
              ...state.subjectStats.asMap().entries.map((entry) {
                final i = entry.key;
                final stats = entry.value;
                final pct = stats.summary.effectiveTotal > 0
                    ? stats.summary.effectivePresent /
                        stats.summary.effectiveTotal *
                        100
                    : 0.0;
                final rowColor =
                    i % 2 == 0 ? PdfColors.grey100 : PdfColors.white;
                return pw.TableRow(
                  decoration: pw.BoxDecoration(color: rowColor),
                  children: [
                    _tableCell(stats.subject.name, font: font),
                    _tableCell('${stats.summary.effectivePresent}', font: font),
                    _tableCell('${stats.summary.effectiveTotal}', font: font),
                    _tableCell(
                      '${pct.toStringAsFixed(1)}%',
                      font: boldFont,
                      textColor: _statusColor(pct),
                    ),
                    _tableCell('${stats.forecast.safeBunksRemaining}',
                        font: font),
                  ],
                );
              }),
            ],
          ),

          pw.SizedBox(height: 28),

          // ── Footer ───────────────────────────────────────────────
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 6),
          pw.Text(
            'This report was generated by Attendify. For personal use only.',
            style: const pw.TextStyle(
                fontSize: 9, color: PdfColors.grey500),
          ),
        ],
      ),
    );

    if (isDetailed) {
      for (final subjectStat in state.subjectStats) {
        final subjectAttendances = state.allAttendances
            .where((a) => a.subjectId == subjectStat.subject.id)
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

        if (subjectAttendances.isEmpty) continue;

        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(32),
            theme: pw.ThemeData.withFont(base: font, bold: boldFont),
            build: (context) => [
              pw.Text(
                'Detailed Attendance: ${subjectStat.subject.name}',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 18,
                  color: _primary,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(3),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      _tableCell('Date', font: boldFont),
                      _tableCell('Status', font: boldFont),
                      _tableCell('Notes', font: boldFont),
                    ],
                  ),
                  ...subjectAttendances.map((record) {
                    final dateFormatted = DateFormat('MMM d, yyyy').format(record.date);
                    final statusName = record.status.name.toUpperCase();
                    PdfColor statusColor = PdfColors.grey800;
                    if (record.status.name == 'present') statusColor = _success;
                    if (record.status.name == 'absent') statusColor = _danger;

                    return pw.TableRow(
                      children: [
                        _tableCell(dateFormatted, font: font),
                        _tableCell(statusName, font: boldFont, textColor: statusColor),
                        _tableCell(record.notes ?? '', font: font),
                      ],
                    );
                  }),
                ],
              ),
            ],
          ),
        );
      }
    }

    return pdf.save();
  }

  static pw.Widget _buildSummaryCard({
    required String label,
    required String value,
    required PdfColor color,
    required pw.Font font,
  }) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: color, width: 1.5),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(value,
                style: pw.TextStyle(font: font, fontSize: 18, color: color)),
            pw.SizedBox(height: 4),
            pw.Text(label,
                style:
                    const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _tableCell(
    String text, {
    required pw.Font font,
    bool isHeader = false,
    PdfColor? textColor,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 10 : 9,
          color: isHeader
              ? PdfColors.white
              : (textColor ?? PdfColors.grey800),
        ),
      ),
    );
  }
}
