import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/print_format.dart';
import 'invoice_template.dart';

/// A4 Invoice Template - Professional full-page invoice
///
/// This template is designed for standard A4 paper (210×297mm) and provides
/// a comprehensive invoice layout suitable for formal business documents.
///
/// Features:
/// - Company logo and detailed information
/// - Bilingual content (English/Arabic)
/// - Full customer information
/// - Detailed items table with VAT breakdown
/// - ZATCA-compliant QR code
///
/// To modify this template:
/// 1. Adjust spacing by changing SizedBox heights
/// 2. Modify font sizes in the build methods
/// 3. Change colors and borders in decoration properties
/// 4. Customize the table structure in buildItemsTable()
class A4InvoiceTemplate extends InvoiceTemplate {
  A4InvoiceTemplate({
    required PrintFormatConfig config,
  }) : super(
          format: PrintFormat.a4,
          config: config,
        );

  @override
  pw.Widget build(InvoiceData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header with company info
        if (config.showLogo) buildHeader(data),
        if (config.showLogo) pw.SizedBox(height: 20),

        // Invoice Title
        buildTitle(data),
        pw.SizedBox(height: 20),

        // Invoice metadata and customer info in a row
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(child: buildInvoiceInfo(data)),
            if (config.showCustomerInfo && data.customer != null)
              pw.SizedBox(width: 20),
            if (config.showCustomerInfo && data.customer != null)
              pw.Expanded(child: buildCustomerInfo(data)),
          ],
        ),
        pw.SizedBox(height: 20),

        // Items Table
        buildItemsTable(data),
        pw.SizedBox(height: 5),

        // VAT Note
        pw.Text(
          'Note: Prices are exclusive of VAT / ملاحظة: الأسعار غير شاملة لضريبة القيمة المضافة',
          style: pw.TextStyle(
              fontSize: 8,
              fontStyle: pw.FontStyle.italic,
              font: data.arabicFont),
        ),
        pw.SizedBox(height: 15),

        // Totals
        buildTotals(data),

        // Notes (if configured and available)
        if (config.showNotes && (data.sale.notes?.isNotEmpty ?? false)) ...[
          pw.SizedBox(height: 20),
          buildNotes(data),
        ],

        pw.Spacer(),

        // Footer with QR Code
        if (config.showQrCode) pw.SizedBox(height: 20),
        if (config.showQrCode) buildFooter(data),
      ],
    );
  }

  @override
  pw.Widget buildHeader(InvoiceData data) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Company Logo
        pw.Container(
          width: 80,
          height: 80,
          decoration: pw.BoxDecoration(
            border: data.logoBytes == null
                ? pw.Border.all(color: PdfColors.grey)
                : null,
          ),
          child: data.logoBytes != null
              ? pw.Image(
                  pw.MemoryImage(data.logoBytes!),
                  fit: pw.BoxFit.contain,
                )
              : pw.Center(
                  child: pw.Text(
                    'LOGO',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey600,
                    ),
                  ),
                ),
        ),
        // Company Info - Right-aligned for bilingual support
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              data.companyInfo.name,
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              data.companyInfo.nameArabic,
              style: pw.TextStyle(fontSize: 14, font: data.arabicFont),
              textDirection: pw.TextDirection.rtl,
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              data.companyInfo.address,
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.Text(
              data.companyInfo.addressArabic,
              style: pw.TextStyle(fontSize: 10, font: data.arabicFont),
              textDirection: pw.TextDirection.rtl,
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              'Phone: ${data.companyInfo.phone}',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.Text(
              'VAT: ${data.companyInfo.vatNumber}',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.Text(
              'CR: ${data.companyInfo.crnNumber}',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  @override
  pw.Widget buildTitle(InvoiceData data) {
    return pw.Center(
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            'TAX INVOICE / ',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            'فاتورة ضريبية',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              font: data.arabicFont,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  @override
  pw.Widget buildInvoiceInfo(InvoiceData data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Invoice Details',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 5),
          _buildInfoRow('Invoice Number:', data.sale.invoiceNumber, data),
          _buildInfoRow('Date:', dateFormat.format(data.sale.saleDate), data),
          _buildInfoRow('Payment Method:',
              getPaymentMethodLabel(data.sale.paymentMethod), data),
        ],
      ),
    );
  }

  @override
  pw.Widget buildCustomerInfo(InvoiceData data) {
    if (data.customer == null) return pw.Container();

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Customer Information',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 5),
          _buildInfoRow('Name:', data.customer!.name, data),
          if (data.customer!.phone != null)
            _buildInfoRow('Phone:', data.customer!.phone!, data),
          if (data.customer!.vatNumber != null)
            _buildInfoRow('VAT:', data.customer!.vatNumber!, data),
          if (data.customer!.crnNumber != null)
            _buildInfoRow('CR:', data.customer!.crnNumber!, data),
        ],
      ),
    );
  }

  pw.Widget _buildInfoRow(String label, String value, InvoiceData data) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        children: [
          pw.Container(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 10, font: data.arabicFont),
            ),
          ),
        ],
      ),
    );
  }

  @override
  pw.Widget buildItemsTable(InvoiceData data) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey),
      children: [
        // Header Row
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey300,
          ),
          children: [
            _buildTableCell('Item / الوصف ',
                isHeader: true, font: data.arabicFont),
            _buildTableCell('Qty\nالكمية ',
                isHeader: true,
                align: pw.TextAlign.center,
                font: data.arabicFont),
            _buildTableCell('Price\n  السعر',
                isHeader: true,
                align: pw.TextAlign.right,
                font: data.arabicFont),
            _buildTableCell('VAT\n الضريبة ',
                isHeader: true,
                align: pw.TextAlign.right,
                font: data.arabicFont),
            _buildTableCell('Total\n الإجمالي ',
                isHeader: true,
                align: pw.TextAlign.right,
                font: data.arabicFont),
          ],
        ),
        // Item Rows
        ...data.sale.items.map((item) {
          return pw.TableRow(
            children: [
              _buildTableCell(item.productName, font: data.arabicFont),
              _buildTableCell(
                item.quantity.toString(),
                align: pw.TextAlign.center,
              ),
              _buildTableCell(
                currencyFormat.format(item.unitPrice),
                align: pw.TextAlign.right,
              ),
              _buildTableCell(
                currencyFormat.format(item.vatAmount),
                align: pw.TextAlign.right,
              ),
              _buildTableCell(
                currencyFormat.format(item.total),
                align: pw.TextAlign.right,
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    pw.TextAlign align = pw.TextAlign.left,
    pw.Font? font,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          font: font,
        ),
        textAlign: align,
      ),
    );
  }

  @override
  pw.Widget buildTotals(InvoiceData data) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 250,
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _buildTotalRow(
                'Subtotal:', currencyFormat.format(data.sale.subtotal)),
            _buildTotalRow(
                'VAT Amount:', currencyFormat.format(data.sale.vatAmount)),
            pw.Divider(color: PdfColors.grey),
            _buildTotalRow(
              'Total Amount:',
              currencyFormat.format(data.sale.totalAmount),
              isBold: true,
              fontSize: 12,
            ),
            if (data.sale.paidAmount > 0) ...[
              pw.SizedBox(height: 5),
              _buildTotalRow(
                  'Paid:', currencyFormat.format(data.sale.paidAmount)),
              if (data.sale.changeAmount > 0)
                _buildTotalRow(
                    'Change:', currencyFormat.format(data.sale.changeAmount)),
            ],
          ],
        ),
      ),
    );
  }

  pw.Widget _buildTotalRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 10,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
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

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Notes:',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            data.sale.notes!,
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
  }

  @override
  pw.Widget buildFooter(InvoiceData data) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Thank you for your business!',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              'شكراً لتعاملكم معنا',
              style: pw.TextStyle(fontSize: 11, font: data.arabicFont),
              textDirection: pw.TextDirection.rtl,
            ),
          ],
        ),
        // ZATCA QR Code
        pw.BarcodeWidget(
          data: data.zatcaQrData,
          barcode: pw.Barcode.qrCode(),
          width: 100,
          height: 100,
        ),
      ],
    );
  }
}
