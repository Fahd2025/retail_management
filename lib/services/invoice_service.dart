import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/sale.dart';
import '../models/company_info.dart';
import '../models/customer.dart';
import '../utils/zatca_qr_generator.dart';

class InvoiceService {
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final currencyFormat = NumberFormat.currency(symbol: 'SAR ', decimalDigits: 2);

  Future<Uint8List> generateInvoicePdf({
    required Sale sale,
    required CompanyInfo companyInfo,
    Customer? customer,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    final pdf = pw.Document();

    // Generate ZATCA QR Code
    final qrData = ZatcaQrGenerator.generate(
      sellerName: companyInfo.name,
      vatNumber: companyInfo.vatNumber,
      invoiceDate: sale.saleDate,
      totalWithVat: sale.totalAmount,
      vatAmount: sale.vatAmount,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(companyInfo),
              pw.SizedBox(height: 20),

              // Tax Invoice Title
              pw.Center(
                child: pw.Text(
                  'TAX INVOICE / فاتورة ضريبية',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Invoice Info
              _buildInvoiceInfo(sale, customer),
              pw.SizedBox(height: 20),

              // Items Table
              _buildItemsTable(sale),
              pw.SizedBox(height: 20),

              // Totals
              _buildTotals(sale),
              pw.SizedBox(height: 20),

              // Footer with QR Code
              _buildFooter(qrData, companyInfo),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(CompanyInfo companyInfo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Company Logo placeholder
        pw.Container(
          width: 80,
          height: 80,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(),
          ),
          child: pw.Center(
            child: pw.Text('LOGO'),
          ),
        ),
        // Company Info
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              companyInfo.name,
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(companyInfo.nameArabic),
            pw.SizedBox(height: 5),
            pw.Text(companyInfo.address),
            pw.Text(companyInfo.addressArabic),
            pw.Text('Phone: ${companyInfo.phone}'),
            pw.Text('VAT: ${companyInfo.vatNumber}'),
            pw.Text('CR: ${companyInfo.crnNumber}'),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildInvoiceInfo(Sale sale, Customer? customer) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Invoice Number: ${sale.invoiceNumber}'),
            pw.Text('Date: ${dateFormat.format(sale.saleDate)}'),
            pw.Text('Payment Method: ${_getPaymentMethodLabel(sale.paymentMethod)}'),
          ],
        ),
        if (customer != null)
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Customer: ${customer.name}'),
              if (customer.vatNumber != null)
                pw.Text('VAT: ${customer.vatNumber}'),
              if (customer.crnNumber != null)
                pw.Text('CR: ${customer.crnNumber}'),
            ],
          ),
      ],
    );
  }

  pw.Widget _buildItemsTable(Sale sale) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: PdfColors.grey300,
          ),
          children: [
            _buildTableCell('Item', isHeader: true),
            _buildTableCell('Qty', isHeader: true),
            _buildTableCell('Price', isHeader: true),
            _buildTableCell('VAT %', isHeader: true),
            _buildTableCell('Total', isHeader: true),
          ],
        ),
        // Items
        ...sale.items.map((item) {
          return pw.TableRow(
            children: [
              _buildTableCell(item.productName),
              _buildTableCell(item.quantity.toString(), align: pw.TextAlign.center),
              _buildTableCell(currencyFormat.format(item.unitPrice)),
              _buildTableCell('${item.vatRate.toStringAsFixed(0)}%', align: pw.TextAlign.center),
              _buildTableCell(currencyFormat.format(item.total)),
            ],
          );
        }).toList(),
      ],
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: align,
      ),
    );
  }

  pw.Widget _buildTotals(Sale sale) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        _buildTotalRow('Subtotal:', currencyFormat.format(sale.subtotal)),
        _buildTotalRow('VAT Amount:', currencyFormat.format(sale.vatAmount)),
        pw.Divider(),
        _buildTotalRow(
          'Total Amount:',
          currencyFormat.format(sale.totalAmount),
          isBold: true,
        ),
        if (sale.paidAmount > 0) ...[
          _buildTotalRow('Paid:', currencyFormat.format(sale.paidAmount)),
          if (sale.changeAmount > 0)
            _buildTotalRow('Change:', currencyFormat.format(sale.changeAmount)),
        ],
      ],
    );
  }

  pw.Widget _buildTotalRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Container(
            width: 100,
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(String qrData, CompanyInfo companyInfo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Thank you for your business!',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('شكراً لتعاملكم معنا'),
          ],
        ),
        // ZATCA QR Code
        pw.BarcodeWidget(
          data: qrData,
          barcode: pw.Barcode.qrCode(),
          width: 100,
          height: 100,
        ),
      ],
    );
  }

  String _getPaymentMethodLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash / نقداً';
      case PaymentMethod.card:
        return 'Card / بطاقة';
      case PaymentMethod.transfer:
        return 'Transfer / تحويل';
    }
  }

  Future<void> printInvoice({
    required Sale sale,
    required CompanyInfo companyInfo,
    Customer? customer,
    PdfPageFormat? pageFormat,
  }) async {
    final pdfBytes = await generateInvoicePdf(
      sale: sale,
      companyInfo: companyInfo,
      customer: customer,
      pageFormat: pageFormat ?? PdfPageFormat.a4,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }
}
