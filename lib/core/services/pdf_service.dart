import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:engicore/features/history/domain/entities/calculation_record.dart';
import 'package:engicore/features/field_logger/domain/entities/log_session.dart';

/// Pikolab branded PDF colors.
class PdfBrandColors {
  static const teal = PdfColor.fromInt(0xFF009688);
  static const tealDark = PdfColor.fromInt(0xFF00796B);
  static const tealLight = PdfColor.fromInt(0xFFE0F2F1);
  static const grey = PdfColor.fromInt(0xFF9E9E9E);
  static const greyDark = PdfColor.fromInt(0xFF616161);
}

/// Service for generating branded PDF calculation reports.
class PdfService {
  PdfService();

  /// Generate and share a PDF report with inputs and results.
  ///
  /// This is the main entry point for PDF generation from calculators.
  Future<void> generateAndShareReport({
    required String title,
    required Map<String, String> inputs,
    required Map<String, String> results,
  }) async {
    final pdf = await _buildPdfDocument(
      title: title,
      inputs: inputs,
      results: results,
    );

    await Printing.sharePdf(
      bytes: pdf,
      filename: '${title.toLowerCase().replaceAll(' ', '_')}_report.pdf',
    );
  }

  /// Build the PDF document with Pikolab letterhead.
  Future<Uint8List> _buildPdfDocument({
    required String title,
    required Map<String, String> inputs,
    required Map<String, String> results,
  }) async {
    final pdf = pw.Document();

    // Load logo (fallback to text if not available)
    pw.MemoryImage? logoImage;
    try {
      final logoData = await rootBundle.load('assets/images/qoreng_logo.png');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (e) {
      // Logo not available, will use text fallback
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header (Letterhead)
              _buildLetterhead(logoImage),
              pw.SizedBox(height: 8),

              // Teal divider line
              pw.Container(
                width: double.infinity,
                height: 2,
                color: PdfBrandColors.teal,
              ),
              pw.SizedBox(height: 24),

              // Calculation Title
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfBrandColors.tealDark,
                ),
              ),
              pw.SizedBox(height: 24),

              // Inputs Section
              if (inputs.isNotEmpty) ...[
                _buildSectionHeader('Input Parameters'),
                pw.SizedBox(height: 8),
                _buildInputsTable(inputs),
                pw.SizedBox(height: 24),
              ],

              // Results Section
              _buildSectionHeader('Calculated Results'),
              pw.SizedBox(height: 8),
              _buildResultsTable(results),

              pw.Spacer(),

              // Footer (Pikolab Signature)
              _buildPikolabFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Build the letterhead header with logo and date.
  pw.Widget _buildLetterhead(pw.MemoryImage? logo) {
    final now = DateTime.now();
    final dateString =
        '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';
    final timeString =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        // Left: Logo + App Name
        pw.Row(
          children: [
            if (logo != null)
              pw.Container(
                width: 40,
                height: 40,
                child: pw.Image(logo),
              )
            else
              pw.Container(
                width: 40,
                height: 40,
                decoration: pw.BoxDecoration(
                  color: PdfBrandColors.teal,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Center(
                  child: pw.Text(
                    'Q',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
              ),
            pw.SizedBox(width: 12),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'QorEng Engineering Report',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfBrandColors.teal,
                  ),
                ),
                pw.Text(
                  'Professional Calculation Results',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Right: Date/Time
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              dateString,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
            pw.Text(
              timeString,
              style: const pw.TextStyle(
                fontSize: 9,
                color: PdfColors.grey500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build a section header.
  pw.Widget _buildSectionHeader(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: pw.BoxDecoration(
        color: PdfBrandColors.tealLight,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
          color: PdfBrandColors.tealDark,
        ),
      ),
    );
  }

  /// Build the inputs table.
  pw.Widget _buildInputsTable(Map<String, String> inputs) {
    return pw.Table(
      border: pw.TableBorder.all(
        color: PdfColors.grey300,
        width: 0.5,
      ),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(3),
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey100,
          ),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Parameter',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Value',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        // Data rows
        ...inputs.entries.map((entry) => pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    entry.key,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    entry.value,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
              ],
            )),
      ],
    );
  }

  /// Build the results table with highlighting.
  pw.Widget _buildResultsTable(Map<String, String> results) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfBrandColors.teal, width: 1.5),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: results.entries.map((entry) {
          final isFirst = entry.key == results.keys.first;
          final isLast = entry.key == results.keys.last;

          return pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: pw.BoxDecoration(
              color: isFirst ? PdfBrandColors.tealLight : PdfColors.white,
              borderRadius: pw.BorderRadius.only(
                topLeft: isFirst ? const pw.Radius.circular(6) : pw.Radius.zero,
                topRight:
                    isFirst ? const pw.Radius.circular(6) : pw.Radius.zero,
                bottomLeft:
                    isLast ? const pw.Radius.circular(6) : pw.Radius.zero,
                bottomRight:
                    isLast ? const pw.Radius.circular(6) : pw.Radius.zero,
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    entry.key,
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isFirst ? pw.FontWeight.bold : pw.FontWeight.normal,
                      color: PdfColors.grey800,
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 3,
                  child: pw.Text(
                    entry.value,
                    style: pw.TextStyle(
                      fontSize: isFirst ? 14 : 11,
                      fontWeight: pw.FontWeight.bold,
                      color: isFirst ? PdfBrandColors.tealDark : PdfColors.grey900,
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build the Pikolab signature footer.
  pw.Widget _buildPikolabFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 16),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: 1),
        ),
      ),
      child: pw.Column(
        children: [
          // Main footer text - centered
          pw.Center(
            child: pw.Text(
              'Developed by Pikolab R&D',
              style: const pw.TextStyle(
                fontSize: 9,
                color: PdfColors.grey600,
              ),
            ),
          ),
          pw.SizedBox(height: 4),
          // Website
          pw.Center(
            child: pw.Text(
              'www.pikolab.com',
              style: const pw.TextStyle(
                fontSize: 8,
                color: PdfColors.grey500,
              ),
            ),
          ),
          pw.SizedBox(height: 8),
          // Copyright
          pw.Center(
            child: pw.Text(
              '© 2025 QorEng',
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: PdfBrandColors.teal,
              ),
            ),
          ),
          pw.SizedBox(height: 8),
          // Disclaimer
          pw.Center(
            child: pw.Text(
              'DISCLAIMER: The user is solely responsible for verifying and confirming all calculations. '
              'The developers cannot be held liable for any damages or losses arising from the use of this software.',
              style: const pw.TextStyle(
                fontSize: 6,
                color: PdfColors.grey500,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // --- Legacy methods for CalculationRecord ---

  /// Generate a PDF report for a calculation record.
  Future<Uint8List> generateCalculationReport(
    CalculationRecord record,
  ) async {
    return _buildPdfDocument(
      title: record.title,
      inputs: {},
      results: {'Result': record.resultValue},
    );
  }

  /// Generate a PDF report for a Field Logger session.
  Future<Uint8List> generateLoggerReport(LogSession session) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm:ss');

    // Load logo
    pw.MemoryImage? logoImage;
    try {
      final logoData = await rootBundle.load('assets/images/qoreng_logo.png');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (e) {
      // Logo not available
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildLetterhead(logoImage),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 10),
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
          ),
        ),
        build: (context) => [
          pw.SizedBox(height: 8),
          pw.Container(
            width: double.infinity,
            height: 2,
            color: PdfBrandColors.teal,
          ),
          pw.SizedBox(height: 16),

          // Title
          pw.Text(
            'Field Logger Report',
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: PdfBrandColors.tealDark,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            session.title,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 16),

          // Session info
          _buildSectionHeader('Session Information'),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Start Time', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('${dateFormat.format(session.startTime)} ${timeFormat.format(session.startTime)}', style: const pw.TextStyle(fontSize: 10)),
                  ),
                ],
              ),
              if (session.endTime != null)
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('End Time', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('${dateFormat.format(session.endTime!)} ${timeFormat.format(session.endTime!)}', style: const pw.TextStyle(fontSize: 10)),
                    ),
                  ],
                ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Duration', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(_formatDuration(session.duration), style: const pw.TextStyle(fontSize: 10)),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Total Entries', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('${session.entries.length}', style: const pw.TextStyle(fontSize: 10)),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Parameters', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(session.parameters.map((p) => '${p.name} (${p.unit})').join(', '), style: const pw.TextStyle(fontSize: 10)),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 24),

          // Data table
          _buildSectionHeader('Recorded Data'),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(1.5),
              for (int i = 0; i < session.parameters.length; i++)
                i + 1: const pw.FlexColumnWidth(1),
            },
            children: [
              // Header row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('Time', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                  ),
                  ...session.parameters.map((param) => pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('${param.name}\n(${param.unit})', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                  )),
                ],
              ),
              // Data rows
              ...session.entries.map((entry) => pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(timeFormat.format(entry.timestamp), style: const pw.TextStyle(fontSize: 9)),
                  ),
                  ...session.parameters.map((param) => pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      entry.values[param.name]?.toStringAsFixed(2) ?? '—',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  )),
                ],
              )),
            ],
          ),
          pw.SizedBox(height: 24),

          // Footer
          _buildPikolabFooter(),
        ],
      ),
    );

    return pdf.save();
  }

  /// Format duration as readable string.
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  /// Print or share the PDF.
  Future<void> printPdf(Uint8List pdfData, String title) async {
    await Printing.layoutPdf(
      onLayout: (format) async => pdfData,
      name: title,
    );
  }

  /// Share the PDF.
  Future<void> sharePdf(Uint8List pdfData, String title) async {
    await Printing.sharePdf(
      bytes: pdfData,
      filename: '${title.toLowerCase().replaceAll(' ', '_')}.pdf',
    );
  }
}

/// Provider for PdfService.
final pdfServiceProvider = Provider<PdfService>((ref) {
  return PdfService();
});
