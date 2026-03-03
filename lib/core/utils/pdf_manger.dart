import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../features/clients/data/clients_model.dart';
import '../../features/orders/data/order_model.dart';
import '../../features/orders/data/payment_model.dart';
import '../../l10n/app_localizations.dart';

class PdfManger {
  /// Load the Cairo font from assets so Arabic text renders correctly.
  static Future<pw.Font> _loadArabicFont() async {
    final data = await rootBundle.load('assets/fonts/Cairo.ttf');
    return pw.Font.ttf(data);
  }

  /// Example/demo report (kept for reference).
  static Future<pw.Document> generatePdfReport() async {
    final font = await _loadArabicFont();
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: font,
        bold: font,
        italic: font,
        boldItalic: font,
      ),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 1),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Demo Report',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text('This is just a demo PDF.'),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }

  /// Order details report used from the order details screen.
  static Future<pw.Document> generateOrderReport({
    required OrderModel order,
    required ClientModel client,
    required List<PaymentModel> payments,
    required AppLocalizations l10n,
  }) async {
    final font = await _loadArabicFont();
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: font,
        bold: font,
        italic: font,
        boldItalic: font,
      ),
    );

    final totalUnpaid = order.totalAmount - order.totalPaid;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          final isArabic = l10n.localeName.startsWith('ar');
          return [
            pw.Directionality(
              textDirection:
                  isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
              child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          client.name,
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        if ((client.phone ?? '').isNotEmpty)
                          pw.Text(client.phone ?? ''),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          l10n.orderDetails,
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text('ID: ${order.id}'),
                        pw.Text(
                          '${order.createdAt.toLocal()}'.split('.').first,
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),

                // Order summary
                pw.Text(
                  l10n.description,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(order.description),
                pw.SizedBox(height: 12),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: _summaryTile(
                        title: l10n.totalAmountLabel,
                        value: order.totalAmount.toStringAsFixed(2),
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: _summaryTile(
                        title: l10n.paidAmount,
                        value: order.totalPaid.toStringAsFixed(2),
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: _summaryTile(
                        title: l10n.totalUnpaid,
                        value: totalUnpaid.toStringAsFixed(2),
                      ),
                    ),
                  ],
                ),
                if ((order.notes ?? '').isNotEmpty) ...[
                  pw.SizedBox(height: 16),
                  pw.Text(
                    l10n.notes,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(order.notes ?? ''),
                ],
                pw.SizedBox(height: 24),

                // Payment history table
                if (payments.isNotEmpty) ...[
                  pw.Text(
                    l10n.paymentHistory,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey),
                    columnWidths: const {
                      0: pw.FlexColumnWidth(2),
                      1: pw.FlexColumnWidth(3),
                    },
                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.grey300,
                        ),
                        children: [
                          _tableHeader(l10n.amountLabel),
                          _tableHeader(l10n.dateLabel),
                        ],
                      ),
                      ...payments.map(
                        (p) => pw.TableRow(
                          children: [
                            _tableCell(p.amount.toStringAsFixed(2)),
                            _tableCell(
                              '${p.createdAt.toLocal()}'.split('.').first,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  // helper methods لتنظيم الكود
  static pw.Widget _tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8.0),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: PdfColors.black,
          fontWeight: pw.FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  static pw.Widget _tableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8.0),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
    );
  }

  static pw.Widget _summaryTile({
    required String title,
    required String value,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// دالة العرض في شاشة منفصلة (أفضل من الـ Dialog في الـ PDF)
//
void showPdfPreview(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.pdfPreviewTitle)),
          body: PdfPreview(
            build: (format) async {
              final doc = await PdfManger.generatePdfReport();
              return doc.save();
            },
          ),
        );
      },
    ),
  );
}

/// Show a PDF preview for a specific order (details + payments).
void showOrderPdfPreview(
  BuildContext context, {
  required OrderModel order,
  required ClientModel client,
  required List<PaymentModel> payments,
}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.pdfPreviewTitle)),
          body: PdfPreview(
            build: (format) async {
              final doc = await PdfManger.generateOrderReport(
                order: order,
                client: client,
                payments: payments,
                l10n: l10n,
              );
              return doc.save();
            },
          ),
        );
      },
    ),
  );
}

