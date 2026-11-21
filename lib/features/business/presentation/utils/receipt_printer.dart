import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/currency_utils.dart';

enum ReceiptFormat { thermal58, thermal80, a4 }

class ReceiptPrinter {
  static Future<void> printSaleReceipt({
    required BusinessesData business,
    required SalesRecord sale,
    required List<SalesItem> items,
    String? customerName,
    ReceiptFormat format = ReceiptFormat.thermal80,
  }) async {
    final pdf = pw.Document();

    final dateStr = DateFormat('dd/MM/yyyy')
        .format(DateTime.fromMillisecondsSinceEpoch(sale.saleDate));
    final timeStr = sale.saleTime ??
        DateFormat('hh:mm a')
            .format(DateTime.fromMillisecondsSinceEpoch(sale.saleDate));

    final pageFormat = switch (format) {
      ReceiptFormat.thermal58 =>
        const PdfPageFormat(58 * PdfPageFormat.mm, double.infinity, marginAll: 2 * PdfPageFormat.mm),
      ReceiptFormat.thermal80 =>
        const PdfPageFormat(80 * PdfPageFormat.mm, double.infinity, marginAll: 4 * PdfPageFormat.mm),
      ReceiptFormat.a4 => PdfPageFormat.a4,
    };

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (context) {
          if (format == ReceiptFormat.a4) {
            return _buildA4Invoice(business, sale, items, customerName, dateStr, timeStr);
          } else {
            return _buildThermalReceipt(business, sale, items, customerName, dateStr, timeStr, format == ReceiptFormat.thermal58);
          }
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice_${sale.invoiceNumber ?? sale.id.substring(0, 8)}',
    );
  }

  static pw.Widget _buildThermalReceipt(
    BusinessesData business,
    SalesRecord sale,
    List<SalesItem> items,
    String? customerName,
    String dateStr,
    String timeStr,
    bool is58mm,
  ) {
    final fontSize = is58mm ? 8.0 : 9.5;
    final titleSize = is58mm ? 12.0 : 14.0;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(business.name,
            style: pw.TextStyle(
                fontSize: titleSize, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center),
        if (business.location != null && business.location!.isNotEmpty)
          pw.Text(business.location!,
              style: pw.TextStyle(fontSize: fontSize),
              textAlign: pw.TextAlign.center),
        if (business.phone != null && business.phone!.isNotEmpty)
          pw.Text('Tel: ${business.phone!}',
              style: pw.TextStyle(fontSize: fontSize),
              textAlign: pw.TextAlign.center),
        pw.Divider(thickness: 0.5),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
                'Inv: #${sale.invoiceNumber ?? sale.id.substring(0, 6).toUpperCase()}',
                style: pw.TextStyle(fontSize: fontSize)),
            pw.Text(sale.saleType.toUpperCase(),
                style: pw.TextStyle(
                    fontSize: fontSize, fontWeight: pw.FontWeight.bold)),
          ],
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Date: $dateStr', style: pw.TextStyle(fontSize: fontSize)),
            pw.Text('Time: $timeStr', style: pw.TextStyle(fontSize: fontSize)),
          ],
        ),
        if (customerName != null && customerName.isNotEmpty)
          pw.Align(
            alignment: pw.Alignment.centerLeft,
            child: pw.Text('Customer: $customerName',
                style: pw.TextStyle(
                    fontSize: fontSize, fontWeight: pw.FontWeight.bold)),
          ),
        pw.Divider(thickness: 0.5),
        // Item Header
        pw.Row(
          children: [
            pw.Expanded(
                flex: 5,
                child: pw.Text('Item',
                    style: pw.TextStyle(
                        fontSize: fontSize, fontWeight: pw.FontWeight.bold))),
            pw.Expanded(
                flex: 2,
                child: pw.Text('Qty',
                    style: pw.TextStyle(
                        fontSize: fontSize, fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.center)),
            pw.Expanded(
                flex: 3,
                child: pw.Text('Total',
                    style: pw.TextStyle(
                        fontSize: fontSize, fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.right)),
          ],
        ),
        pw.Divider(thickness: 0.5),
        // Item Rows
        ...items.map((item) {
          final name = item.productName ?? 'Item';
          final qtyStr = '${item.quantity} ${item.unit ?? ''}';
          final totalStr = CurrencyUtils.format(item.totalMinor);
          return pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
            child: pw.Row(
              children: [
                pw.Expanded(
                    flex: 5,
                    child: pw.Text(name,
                        style: pw.TextStyle(fontSize: fontSize))),
                pw.Expanded(
                    flex: 2,
                    child: pw.Text(qtyStr,
                        style: pw.TextStyle(fontSize: fontSize),
                        textAlign: pw.TextAlign.center)),
                pw.Expanded(
                    flex: 3,
                    child: pw.Text(totalStr,
                        style: pw.TextStyle(fontSize: fontSize),
                        textAlign: pw.TextAlign.right)),
              ],
            ),
          );
        }),
        pw.Divider(thickness: 0.5),
        // Summary
        _buildThermalSummaryRow('Subtotal', CurrencyUtils.format(sale.subtotalMinor), fontSize),
        if (sale.discountMinor > 0)
          _buildThermalSummaryRow('Discount', '- ${CurrencyUtils.format(sale.discountMinor)}', fontSize),
        _buildThermalSummaryRow('Total', CurrencyUtils.format(sale.totalMinor), fontSize, isBold: true),
        _buildThermalSummaryRow('Paid', CurrencyUtils.format(sale.paidMinor), fontSize),
        if (sale.dueMinor > 0)
          _buildThermalSummaryRow('Due', CurrencyUtils.format(sale.dueMinor), fontSize, isBold: true),
        pw.SizedBox(height: 6),
        pw.Text('Thank You!',
            style: pw.TextStyle(
                fontSize: fontSize + 1, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center),
      ],
    );
  }

  static pw.Widget _buildThermalSummaryRow(String label, String value, double fontSize, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  fontSize: fontSize,
                  fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: fontSize,
                  fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    );
  }

  static pw.Widget _buildA4Invoice(
    BusinessesData business,
    SalesRecord sale,
    List<SalesItem> items,
    String? customerName,
    String dateStr,
    String timeStr,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(business.name,
                      style: pw.TextStyle(
                          fontSize: 22, fontWeight: pw.FontWeight.bold)),
                  if (business.location != null) pw.Text(business.location!),
                  if (business.phone != null) pw.Text('Phone: ${business.phone!}'),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('INVOICE',
                      style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blueGrey800)),
                  pw.Text('Invoice #: ${sale.invoiceNumber ?? sale.id.substring(0, 8).toUpperCase()}'),
                  pw.Text('Date: $dateStr  $timeStr'),
                  pw.Text('Type: ${sale.saleType.toUpperCase()}'),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          if (customerName != null)
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Bill To:',
                      style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                          fontWeight: pw.FontWeight.bold)),
                  pw.Text(customerName,
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: ['#', 'Product / Item', 'Quantity', 'Unit Price', 'Total'],
            data: items.asMap().entries.map((e) {
              final idx = e.key + 1;
              final item = e.value;
              return [
                '$idx',
                item.productName ?? 'Item',
                '${item.quantity} ${item.unit ?? ''}',
                CurrencyUtils.format(item.unitPriceMinor),
                CurrencyUtils.format(item.totalMinor),
              ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {
              0: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
            },
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Container(
                width: 200,
                child: pw.Column(
                  children: [
                    _buildSummaryRow('Subtotal', CurrencyUtils.format(sale.subtotalMinor)),
                    if (sale.discountMinor > 0)
                      _buildSummaryRow('Discount', '- ${CurrencyUtils.format(sale.discountMinor)}'),
                    pw.Divider(),
                    _buildSummaryRow('Total', CurrencyUtils.format(sale.totalMinor), isBold: true),
                    _buildSummaryRow('Paid Amount', CurrencyUtils.format(sale.paidMinor)),
                    if (sale.dueMinor > 0)
                      _buildSummaryRow('Due Amount', CurrencyUtils.format(sale.dueMinor), isBold: true),
                  ],
                ),
              ),
            ],
          ),
          pw.Spacer(),
          pw.Center(
            child: pw.Text('Thank you for your business!',
                style: pw.TextStyle(
                    fontStyle: pw.FontStyle.italic, color: PdfColors.grey600)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(value,
              style: pw.TextStyle(
                  fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    );
  }
}
