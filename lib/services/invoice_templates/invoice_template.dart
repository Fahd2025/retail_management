import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../models/sale.dart';
import '../../models/company_info.dart';
import '../../models/customer.dart';
import '../../models/print_format.dart';

/// Invoice data container passed to templates
class InvoiceData {
  final Sale sale;
  final CompanyInfo companyInfo;
  final Customer? customer;
  final String zatcaQrData;
  final Uint8List? logoBytes;
  final pw.Font? arabicFont;

  const InvoiceData({
    required this.sale,
    required this.companyInfo,
    required this.customer,
    required this.zatcaQrData,
    this.logoBytes,
    this.arabicFont,
  });
}

/// Abstract base class for invoice templates
///
/// This class defines the structure that all invoice templates must follow.
/// To create a custom template:
/// 1. Extend this class
/// 2. Implement the build() method
/// 3. Override any of the _build* methods to customize specific sections
abstract class InvoiceTemplate {
  final PrintFormat format;
  final PrintFormatConfig config;

  // Common formatters used across templates
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final NumberFormat currencyFormat =
      NumberFormat.currency(symbol: 'SAR ', decimalDigits: 2);

  InvoiceTemplate({
    required this.format,
    required this.config,
  });

  /// Main build method - must be implemented by each template
  /// This is where you define the overall structure of the invoice
  pw.Widget build(InvoiceData data);

  /// Build the header section (company logo and info)
  /// Override this to customize the header layout
  pw.Widget buildHeader(InvoiceData data) {
    return pw.Container();
  }

  /// Build the invoice title section
  /// Override this to customize the title style
  pw.Widget buildTitle(InvoiceData data) {
    return pw.Container();
  }

  /// Build the invoice metadata (number, date, payment method)
  /// Override this to customize the invoice info layout
  pw.Widget buildInvoiceInfo(InvoiceData data) {
    return pw.Container();
  }

  /// Build the customer information section
  /// Override this to customize customer info display
  pw.Widget buildCustomerInfo(InvoiceData data) {
    return pw.Container();
  }

  /// Build the items table
  /// Override this to customize the items table layout
  pw.Widget buildItemsTable(InvoiceData data) {
    return pw.Container();
  }

  /// Build the totals section (subtotal, VAT, total)
  /// Override this to customize totals layout
  pw.Widget buildTotals(InvoiceData data) {
    return pw.Container();
  }

  /// Build the footer section (thank you message and QR code)
  /// Override this to customize footer layout
  pw.Widget buildFooter(InvoiceData data) {
    return pw.Container();
  }

  /// Build notes section (if any)
  /// Override this to customize notes display
  pw.Widget buildNotes(InvoiceData data) {
    if (data.sale.notes?.isEmpty ?? true) {
      return pw.Container();
    }
    return pw.Container();
  }

  // Helper methods available to all templates

  /// Get the payment method label in both English and Arabic
  String getPaymentMethodLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash / نقداً';
      case PaymentMethod.card:
        return 'Card / بطاقة';
      case PaymentMethod.transfer:
        return 'Transfer / تحويل';
    }
  }

  /// Create a separator line
  pw.Widget buildDivider() {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 5),
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

  /// Create a text element with the format's default font size
  pw.TextStyle getDefaultTextStyle() {
    return pw.TextStyle(
      fontSize: format.defaultFontSize,
    );
  }

  /// Create a heading text style
  pw.TextStyle getHeadingTextStyle() {
    return pw.TextStyle(
      fontSize: format.headingFontSize,
      fontWeight: pw.FontWeight.bold,
    );
  }

  /// Create a title text style
  pw.TextStyle getTitleTextStyle() {
    return pw.TextStyle(
      fontSize: format.titleFontSize,
      fontWeight: pw.FontWeight.bold,
    );
  }
}
