import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../features/clients/data/clients_model.dart';
import '../../features/orders/data/order_model.dart';
import '../../features/orders/data/payment_model.dart';
import '../../l10n/app_localizations.dart';

Future<void> _logPdfReport({
  required String reportType,
  required String action,
}) async {
  await FirebaseAnalytics.instance.logEvent(
    name: 'pdf_report',
    parameters: <String, Object>{
      'report_type': reportType,
      'action': action,
    },
  );
}

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

  /// Client details report listing all orders for that client.
  static Future<pw.Document> generateClientReport({
    required ClientModel client,
    required List<OrderModel> orders,
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

    final totalOrders = orders.length;
    final totalAmount = orders.fold<double>(
      0,
      (sum, o) => sum + o.totalAmount,
    );
    final totalPaid = orders.fold<double>(
      0,
      (sum, o) => sum + o.totalPaid,
    );
    final totalUnpaid = totalAmount - totalPaid;

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
                          if ((client.notes ?? '').isNotEmpty) ...[
                            pw.SizedBox(height: 4),
                            pw.Text(client.notes ?? ''),
                          ],
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            l10n.clientReport,
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            '${DateTime.now().toLocal()}'.split('.').first,
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 24),

                  // Summary row
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        child: _summaryTile(
                          title: l10n.totalAmountLabel,
                          value: totalAmount.toStringAsFixed(2),
                        ),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Expanded(
                        child: _summaryTile(
                          title: l10n.paidAmount,
                          value: totalPaid.toStringAsFixed(2),
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
                  pw.SizedBox(height: 12),
                  _summaryTile(
                    title: l10n.totalOrders,
                    value: totalOrders.toString(),
                  ),
                  pw.SizedBox(height: 24),

                  if (orders.isNotEmpty) ...[
                    pw.Text(
                      l10n.totalOrders,
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.grey),
                      columnWidths: const {
                        0: pw.FlexColumnWidth(3), // description
                        1: pw.FlexColumnWidth(2), // total
                        2: pw.FlexColumnWidth(2), // paid
                        3: pw.FlexColumnWidth(2), // remaining
                        4: pw.FlexColumnWidth(3), // date
                      },
                      children: [
                        pw.TableRow(
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.grey300,
                          ),
                          children: [
                            _tableHeader(l10n.description),
                            _tableHeader(l10n.totalAmountLabel),
                            _tableHeader(l10n.paidAmount),
                            _tableHeader(l10n.totalUnpaid),
                            _tableHeader(l10n.dateLabel),
                          ],
                        ),
                        ...orders.map(
                          (o) {
                            final remaining = o.totalAmount - o.totalPaid;
                            return pw.TableRow(
                              children: [
                                _tableCell(o.description),
                                _tableCell(
                                  o.totalAmount.toStringAsFixed(2),
                                ),
                                _tableCell(
                                  o.totalPaid.toStringAsFixed(2),
                                ),
                                _tableCell(
                                  remaining.toStringAsFixed(2),
                                ),
                                _tableCell(
                                  '${o.createdAt.toLocal()}'
                                      .split('.')
                                      .first,
                                ),
                              ],
                            );
                          },
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
/// The preview has a share button but no print button.
void showOrderPdfPreview(
  BuildContext context, {
  required OrderModel order,
  required ClientModel client,
  required List<PaymentModel> payments,
}) {
  unawaited(_logPdfReport(reportType: 'order', action: 'preview'));
  final l10n = AppLocalizations.of(context)!;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(title: Text(l10n.pdfPreviewTitle)),
          body: PdfPreview(
            allowPrinting: false,
            allowSharing: true,
            canChangeOrientation: false,
            canChangePageFormat: false,
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

/// Directly open the native print dialog for an order (no preview screen).
Future<void> printOrderPdf(
  BuildContext context, {
  required OrderModel order,
  required ClientModel client,
  required List<PaymentModel> payments,
}) async {
  final l10n = AppLocalizations.of(context)!;
  await _logPdfReport(reportType: 'order', action: 'print');
  await Printing.layoutPdf(
    onLayout: (format) async {
      final doc = await PdfManger.generateOrderReport(
        order: order,
        client: client,
        payments: payments,
        l10n: l10n,
      );
      return doc.save();
    },
    name: '${client.name}_order.pdf',
  );
}

/// Show a PDF preview for a specific client with all their orders.
/// The preview has a share button but no print button.
void showClientPdfPreview(
  BuildContext context, {
  required ClientModel client,
  required List<OrderModel> orders,
}) {
  unawaited(_logPdfReport(reportType: 'client', action: 'preview'));
  final l10n = AppLocalizations.of(context)!;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(title: Text(l10n.pdfPreviewTitle)),
          body: PdfPreview(
            allowPrinting: false,
            allowSharing: true,
            canChangeOrientation: false,
            canChangePageFormat: false,
            build: (format) async {
              final doc = await PdfManger.generateClientReport(
                client: client,
                orders: orders,
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

/// Directly open the native print dialog for a client report (no preview screen).
Future<void> printClientPdf(
  BuildContext context, {
  required ClientModel client,
  required List<OrderModel> orders,
}) async {
  final l10n = AppLocalizations.of(context)!;
  await _logPdfReport(reportType: 'client', action: 'print');
  await Printing.layoutPdf(
    onLayout: (format) async {
      final doc = await PdfManger.generateClientReport(
        client: client,
        orders: orders,
        l10n: l10n,
      );
      return doc.save();
    },
    name: '${client.name}_report.pdf',
  );
}

