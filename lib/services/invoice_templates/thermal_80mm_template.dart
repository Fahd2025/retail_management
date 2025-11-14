import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/print_format.dart';
import 'invoice_template.dart';

/// 80mm Thermal Receipt Template - Standard POS receipt
///
/// This template is designed for 80mm thermal paper (common in most POS printers).
/// It provides a compact, receipt-style layout optimized for thermal printing.
///
/// Features:
/// - Centered layout typical of receipts
/// - Compact spacing to save paper
/// - Clear item listings
/// - ZATCA QR code at bottom
/// - No logo (optional based on config)
///
/// To modify this template:
/// 1. Adjust text sizes (currently optimized for 80mm width)
/// 2. Change spacing between sections
/// 3. Modify the items table format
/// 4. Add/remove sections based on needs
class Thermal80mmTemplate extends InvoiceTemplate {
  Thermal80mmTemplate({
    required PrintFormatConfig config,
  }) : super(
          format: PrintFormat.thermal80mm,
          config: config,
        );

  @override
  pw.Widget build(InvoiceData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // Header (centered company info)
        buildHeader(data),
        buildDivider(),

        // Invoice Title
        buildTitle(data),
        buildDivider(),

        // Invoice Info
        buildInvoiceInfo(data),

        // Customer Info (if available)
        if (config.showCustomerInfo && data.customer != null) ...[
          buildDivider(),
          buildCustomerInfo(data),
        ],

        buildDivider(),

        // Items
        buildItemsTable(data),

        pw.SizedBox(height: 3),

        // VAT Note (only shown when VAT is enabled)
        if (data.vatEnabled)
          pw.Text(
            getVatNote(data.vatIncludedInPrice),
            style: pw.TextStyle(
                fontSize: 5,
                fontStyle: pw.FontStyle.italic,
                font: data.arabicFont),
            textDirection: pw.TextDirection.rtl,
            textAlign: pw.TextAlign.center,
          ),

        buildDivider(),

        // Totals
        buildTotals(data),

        // Notes
        if (config.showNotes && (data.sale.notes?.isNotEmpty ?? false)) ...[
          buildDivider(),
          buildNotes(data),
        ],

        buildDivider(),

        // Footer with QR
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
            width: 60,
            height: 60,
            child: pw.Image(
              pw.MemoryImage(data.logoBytes!),
              fit: pw.BoxFit.contain,
            ),
          ),
          pw.SizedBox(height: 5),
        ],
        pw.Text(
          data.companyInfo.name,
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.Text(
          data.companyInfo.nameArabic,
          style: pw.TextStyle(fontSize: 11, font: data.arabicFont),
          textAlign: pw.TextAlign.center,
          textDirection: pw.TextDirection.rtl,
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          data.companyInfo.address,
          style: const pw.TextStyle(fontSize: 7),
          textAlign: pw.TextAlign.center,
        ),
        pw.Text(
          data.companyInfo.addressArabic,
          style: pw.TextStyle(fontSize: 7, font: data.arabicFont),
          textAlign: pw.TextAlign.center,
          textDirection: pw.TextDirection.rtl,
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          'Phone: ${data.companyInfo.phone}',
          style: const pw.TextStyle(fontSize: 7),
          textAlign: pw.TextAlign.center,
        ),
        pw.Text(
          'VAT: ${data.companyInfo.vatNumber}',
          style: const pw.TextStyle(fontSize: 7),
          textAlign: pw.TextAlign.center,
        ),
        pw.Text(
          'CR: ${data.companyInfo.crnNumber}',
          style: const pw.TextStyle(fontSize: 7),
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
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.Text(
          'فاتورة ضريبية',
          style: pw.TextStyle(fontSize: 10, font: data.arabicFont),
          textAlign: pw.TextAlign.center,
          textDirection: pw.TextDirection.rtl,
        ),
      ],
    );
  }

  @override
  pw.Widget buildInvoiceInfo(InvoiceData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildLabelValueRow('Invoice:', data.sale.invoiceNumber, data),
        _buildLabelValueRow(
            'Date:', dateFormat.format(data.sale.saleDate), data),
        _buildLabelValueRow(
            'Payment:', getPaymentMethodLabel(data.sale.paymentMethod), data),
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
          'CUSTOMER',
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 2),
        _buildLabelValueRow('Name:', data.customer!.name, data),
        if (data.customer!.phone != null)
          _buildLabelValueRow('Phone:', data.customer!.phone!, data),
        if (data.customer!.vatNumber != null)
          _buildLabelValueRow('VAT:', data.customer!.vatNumber!, data),
      ],
    );
  }

  pw.Widget _buildLabelValueRow(String label, String value, InvoiceData data) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 8, font: data.arabicFont),
              textDirection: pw.TextDirection.rtl,
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  @override
  pw.Widget buildItemsTable(InvoiceData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // Header
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 3),
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey300,
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                flex: 3,
                child: pw.Text(
                  'Item',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Container(
                width: 30,
                child: pw.Text(
                  'Qty',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Container(
                width: 45,
                child: pw.Text(
                  'Price',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.right,
                ),
              ),
              pw.Container(
                width: 50,
                child: pw.Text(
                  'Total',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          ),
        ),

        // Items
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
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        item.productName,
                        style: pw.TextStyle(fontSize: 8, font: data.arabicFont),
                        textDirection: pw.TextDirection.rtl,
                        textAlign: pw.TextAlign.left,
                      ),
                    ),
                    pw.Container(
                      width: 30,
                      child: pw.Text(
                        item.quantity.toString(),
                        style: const pw.TextStyle(fontSize: 8),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Container(
                      width: 45,
                      child: pw.Text(
                        getCurrencyFormat(data).format(item.unitPrice),
                        style: const pw.TextStyle(fontSize: 8),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Container(
                      width: 50,
                      child: pw.Text(
                        getCurrencyFormat(data).format(item.total),
                        style: const pw.TextStyle(fontSize: 8),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
                // VAT info on second line (only shown when VAT is enabled)
                if (data.vatEnabled)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 5, top: 1),
                    child: pw.Text(
                      'VAT: ${getCurrencyFormat(data).format(item.vatAmount)}',
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
        if (data.vatEnabled)
          _buildTotalRow(
              'Subtotal:', getCurrencyFormat(data).format(data.sale.subtotal)),
        if (data.vatEnabled)
          _buildTotalRow(
              'VAT Amount:', getCurrencyFormat(data).format(data.sale.vatAmount)),
        if (data.vatEnabled)
          pw.Container(
            margin: const pw.EdgeInsets.symmetric(vertical: 3),
            height: 1,
            color: PdfColors.grey,
          ),
        _buildTotalRow(
          'TOTAL:',
          getCurrencyFormat(data).format(data.sale.totalAmount),
          isBold: true,
          fontSize: 10,
        ),
        if (data.sale.paidAmount > 0) ...[
          pw.SizedBox(height: 3),
          _buildTotalRow('Paid:', getCurrencyFormat(data).format(data.sale.paidAmount)),
          if (data.sale.changeAmount > 0)
            _buildTotalRow(
                'Change:', getCurrencyFormat(data).format(data.sale.changeAmount)),
        ],
      ],
    );
  }

  pw.Widget _buildTotalRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 8,
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

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Notes:',
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          data.sale.notes!,
          style: const pw.TextStyle(fontSize: 7),
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
          'Thank you for your business!',
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.Text(
          'شكراً لتعاملكم معنا',
          style: pw.TextStyle(fontSize: 8, font: data.arabicFont),
          textAlign: pw.TextAlign.center,
          textDirection: pw.TextDirection.rtl,
        ),
        pw.SizedBox(height: 5),
        // ZATCA QR Code (centered)
        pw.Center(
          child: pw.BarcodeWidget(
            data: data.zatcaQrData,
            barcode: pw.Barcode.qrCode(),
            width: 80,
            height: 80,
          ),
        ),
        pw.SizedBox(height: 5),
      ],
    );
  }

  @override
  pw.Widget buildDivider() {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 3),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.grey,
            width: 1,
          ),
        ),
      ),
    );
  }
}
