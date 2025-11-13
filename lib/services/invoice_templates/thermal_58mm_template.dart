import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:retail_management/models/sale.dart';
import '../../models/print_format.dart';
import 'invoice_template.dart';

/// 58mm Thermal Receipt Template - Compact POS receipt
///
/// This template is designed for 58mm thermal paper (common in portable POS printers).
/// It provides a very compact receipt-style layout optimized for small thermal printers.
///
/// Features:
/// - Extremely compact layout to fit 58mm width
/// - Simplified item display
/// - Essential information only
/// - Small QR code to save space
/// - Single-column centered layout
///
/// To modify this template:
/// 1. Font sizes are already very small - be careful increasing them
/// 2. Consider removing optional sections to save paper
/// 3. Adjust QR code size (currently 60x60mm)
/// 4. Modify item display format if needed
class Thermal58mmTemplate extends InvoiceTemplate {
  Thermal58mmTemplate({
    required PrintFormatConfig config,
  }) : super(
          format: PrintFormat.thermal58mm,
          config: config,
        );

  @override
  pw.Widget build(InvoiceData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // Header (company info)
        buildHeader(data),
        buildDivider(),

        // Invoice Title
        buildTitle(data),
        buildDivider(),

        // Invoice Info
        buildInvoiceInfo(data),

        // Customer Info (simplified)
        if (config.showCustomerInfo && data.customer != null) ...[
          buildDivider(),
          buildCustomerInfo(data),
        ],

        buildDivider(),

        // Items (simplified)
        buildItemsTable(data),

        buildDivider(),

        // Totals
        buildTotals(data),

        // Notes (only if short)
        if (config.showNotes && (data.sale.notes?.isNotEmpty ?? false)) ...[
          buildDivider(),
          buildNotes(data),
        ],

        buildDivider(),

        // Footer with small QR
        if (config.showQrCode) buildFooter(data),
      ],
    );
  }

  @override
  pw.Widget buildHeader(InvoiceData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        // Company Logo
        if (data.logoBytes != null) ...[
          pw.Container(
            width: 50,
            height: 50,
            child: pw.Image(
              pw.MemoryImage(data.logoBytes!),
              fit: pw.BoxFit.contain,
            ),
          ),
          pw.SizedBox(height: 3),
        ],
        pw.Text(
          data.companyInfo.name,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.Text(
          data.companyInfo.nameArabic,
          style: const pw.TextStyle(fontSize: 9),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          data.companyInfo.phone,
          style: const pw.TextStyle(fontSize: 6),
          textAlign: pw.TextAlign.center,
        ),
        pw.Text(
          'VAT: ${data.companyInfo.vatNumber}',
          style: const pw.TextStyle(fontSize: 6),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  @override
  pw.Widget buildTitle(InvoiceData data) {
    return pw.Column(
      children: [
        pw.Text(
          'TAX INVOICE',
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.Text(
          'فاتورة ضريبية',
          style: const pw.TextStyle(fontSize: 8),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  @override
  pw.Widget buildInvoiceInfo(InvoiceData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildInfoLine('Inv: ${data.sale.invoiceNumber}'),
        _buildInfoLine('Date: ${dateFormat.format(data.sale.saleDate)}'),
        _buildInfoLine(
            'Pay: ${_getShortPaymentMethod(data.sale.paymentMethod)}'),
      ],
    );
  }

  @override
  pw.Widget buildCustomerInfo(InvoiceData data) {
    if (data.customer == null) return pw.Container();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Customer:',
          style: pw.TextStyle(
            fontSize: 7,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        _buildInfoLine(data.customer!.name),
        if (data.customer!.phone != null) _buildInfoLine(data.customer!.phone!),
      ],
    );
  }

  pw.Widget _buildInfoLine(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 0.5),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 7),
      ),
    );
  }

  @override
  pw.Widget buildItemsTable(InvoiceData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // Header (simplified)
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey300,
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  'Item',
                  style: pw.TextStyle(
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Container(
                width: 35,
                child: pw.Text(
                  'Total',
                  style: pw.TextStyle(
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          ),
        ),

        // Items (simplified - two lines per item)
        ...data.sale.items.map((item) {
          return pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 2),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  color: PdfColors.grey300,
                  width: 0.5,
                ),
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Item name and total on first line
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        item.productName,
                        style: const pw.TextStyle(fontSize: 7),
                      ),
                    ),
                    pw.Container(
                      width: 35,
                      child: pw.Text(
                        currencyFormat.format(item.total),
                        style: const pw.TextStyle(fontSize: 7),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
                // Qty, price, VAT on second line
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 1),
                  child: pw.Text(
                    '${item.quantity} x ${currencyFormat.format(item.unitPrice)} (VAT ${item.vatRate.toStringAsFixed(0)}%)',
                    style: const pw.TextStyle(
                        fontSize: 6, color: PdfColors.grey600),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  @override
  pw.Widget buildTotals(InvoiceData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _buildTotalRow('Subtotal:', currencyFormat.format(data.sale.subtotal)),
        _buildTotalRow('VAT:', currencyFormat.format(data.sale.vatAmount)),
        pw.Container(
          margin: const pw.EdgeInsets.symmetric(vertical: 2),
          height: 1,
          color: PdfColors.grey,
        ),
        _buildTotalRow(
          'TOTAL:',
          currencyFormat.format(data.sale.totalAmount),
          isBold: true,
          fontSize: 9,
        ),
        if (data.sale.paidAmount > 0) ...[
          pw.SizedBox(height: 2),
          _buildTotalRow('Paid:', currencyFormat.format(data.sale.paidAmount),
              fontSize: 7),
          if (data.sale.changeAmount > 0)
            _buildTotalRow(
                'Change:', currencyFormat.format(data.sale.changeAmount),
                fontSize: 7),
        ],
      ],
    );
  }

  pw.Widget _buildTotalRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 7,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  pw.Widget buildNotes(InvoiceData data) {
    if (data.sale.notes?.isEmpty ?? true) return pw.Container();

    // Truncate long notes for 58mm
    String notes = data.sale.notes!;
    if (notes.length > 100) {
      notes = '${notes.substring(0, 97)}...';
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Notes:',
          style: pw.TextStyle(
            fontSize: 7,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          notes,
          style: const pw.TextStyle(fontSize: 6),
        ),
      ],
    );
  }

  @override
  pw.Widget buildFooter(InvoiceData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'Thank you!',
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.Text(
          'شكراً لكم',
          style: const pw.TextStyle(fontSize: 7),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 3),
        // Smaller QR Code for 58mm
        pw.Center(
          child: pw.BarcodeWidget(
            data: data.zatcaQrData,
            barcode: pw.Barcode.qrCode(),
            width: 60,
            height: 60,
          ),
        ),
        pw.SizedBox(height: 3),
      ],
    );
  }

  @override
  pw.Widget buildDivider() {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 2),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.grey,
            width: 0.5,
          ),
        ),
      ),
    );
  }

  String _getShortPaymentMethod(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.transfer:
        return 'Transfer';
    }
  }
}
