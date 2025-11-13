import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../models/sale.dart';
import '../models/customer.dart';
import '../models/company_info.dart';

class CustomerInvoiceExportService {
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final shortDateFormat = DateFormat('dd/MM/yyyy');
  final currencyFormat =
      NumberFormat.currency(symbol: 'SAR ', decimalDigits: 2);

  Future<Uint8List> generateCustomerInvoicesPdf({
    required Customer customer,
    required List<Sale> sales,
    required CompanyInfo companyInfo,
    DateTime? startDate,
    DateTime? endDate,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        build: (pw.Context context) {
          return [
            // Header
            _buildHeader(companyInfo),
            pw.SizedBox(height: 20),

            // Title
            pw.Center(
              child: pw.Text(
                'Customer Invoice Report / تقرير فواتير العميل',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),

            // Customer and Report Info
            _buildCustomerInfo(customer, sales, startDate, endDate),
            pw.SizedBox(height: 20),

            // Summary Statistics
            _buildSummaryStatistics(sales),
            pw.SizedBox(height: 20),

            // Invoices List
            pw.Text(
              'Invoices / الفواتير',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            _buildInvoicesTable(sales),
          ];
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

  pw.Widget _buildCustomerInfo(Customer customer, List<Sale> sales,
      DateTime? startDate, DateTime? endDate) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Customer Information / معلومات العميل',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Customer: ${customer.name}'),
                  if (customer.phone != null)
                    pw.Text('Phone: ${customer.phone}'),
                  if (customer.email != null)
                    pw.Text('Email: ${customer.email}'),
                  if (customer.vatNumber != null)
                    pw.Text('VAT: ${customer.vatNumber}'),
                  if (customer.crnNumber != null)
                    pw.Text('CR: ${customer.crnNumber}'),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                      'Report Date: ${shortDateFormat.format(DateTime.now())}'),
                  if (startDate != null && endDate != null) ...[
                    pw.Text('Period: ${shortDateFormat.format(startDate)}'),
                    pw.Text('to ${shortDateFormat.format(endDate)}'),
                  ] else
                    pw.Text('Period: All Time'),
                  pw.Text('Total Invoices: ${sales.length}'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryStatistics(List<Sale> sales) {
    final totalSubtotal =
        sales.fold<double>(0, (sum, sale) => sum + sale.subtotal);
    final totalVat = sales.fold<double>(0, (sum, sale) => sum + sale.vatAmount);
    final totalAmount =
        sales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildStatisticItem(
              'Total Invoices\nإجمالي الفواتير', sales.length.toString()),
          _buildStatisticItem(
              'Subtotal\nالمجموع الفرعي', currencyFormat.format(totalSubtotal)),
          _buildStatisticItem(
              'VAT Amount\nقيمة الضريبة', currencyFormat.format(totalVat)),
          _buildStatisticItem('Total Amount\nالمبلغ الإجمالي',
              currencyFormat.format(totalAmount)),
        ],
      ),
    );
  }

  pw.Widget _buildStatisticItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue700,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildInvoicesTable(List<Sale> sales) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1.5),
        5: const pw.FlexColumnWidth(2),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: PdfColors.grey300,
          ),
          children: [
            _buildTableCell('Invoice #', isHeader: true),
            _buildTableCell('Date', isHeader: true),
            _buildTableCell('Subtotal', isHeader: true),
            _buildTableCell('VAT', isHeader: true),
            _buildTableCell('Total', isHeader: true),
            _buildTableCell('Payment', isHeader: true),
          ],
        ),
        // Rows
        ...sales.map((sale) {
          return pw.TableRow(
            children: [
              _buildTableCell(sale.invoiceNumber),
              _buildTableCell(dateFormat.format(sale.saleDate)),
              _buildTableCell(currencyFormat.format(sale.subtotal),
                  align: pw.TextAlign.right),
              _buildTableCell(currencyFormat.format(sale.vatAmount),
                  align: pw.TextAlign.right),
              _buildTableCell(currencyFormat.format(sale.totalAmount),
                  align: pw.TextAlign.right),
              _buildTableCell(_getPaymentMethodLabel(sale.paymentMethod)),
            ],
          );
        }).toList(),
        // Footer with totals
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
          ),
          children: [
            _buildTableCell('Total / الإجمالي', isHeader: true, colspan: 2),
            _buildTableCell(
              currencyFormat.format(
                  sales.fold<double>(0, (sum, sale) => sum + sale.subtotal)),
              isHeader: true,
              align: pw.TextAlign.right,
            ),
            _buildTableCell(
              currencyFormat.format(
                  sales.fold<double>(0, (sum, sale) => sum + sale.vatAmount)),
              isHeader: true,
              align: pw.TextAlign.right,
            ),
            _buildTableCell(
              currencyFormat.format(
                  sales.fold<double>(0, (sum, sale) => sum + sale.totalAmount)),
              isHeader: true,
              align: pw.TextAlign.right,
            ),
            _buildTableCell('', isHeader: true),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    pw.TextAlign align = pw.TextAlign.left,
    int colspan = 1,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: isHeader ? 11 : 10,
        ),
        textAlign: align,
      ),
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

  /// Downloads the PDF on web or saves to device on mobile
  Future<void> exportCustomerInvoices({
    required Customer customer,
    required List<Sale> sales,
    required CompanyInfo companyInfo,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final pdfBytes = await generateCustomerInvoicesPdf(
      customer: customer,
      sales: sales,
      companyInfo: companyInfo,
      startDate: startDate,
      endDate: endDate,
    );

    // Generate filename
    final dateStr = DateFormat('yyyyMMdd').format(DateTime.now());
    final filename =
        'Customer_Invoices_${customer.name.replaceAll(' ', '_')}_$dateStr.pdf';

    // Use printing package which handles both web download and mobile save
    await Printing.sharePdf(bytes: pdfBytes, filename: filename);
  }
}
