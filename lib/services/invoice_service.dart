import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/sale.dart';
import '../models/company_info.dart';
import '../models/customer.dart';
import '../models/print_format.dart';
import '../utils/zatca_qr_generator.dart';
import 'invoice_templates/invoice_template.dart';
import 'invoice_templates/invoice_template_factory.dart';
import 'image_service.dart';
import 'package:flutter/services.dart' show rootBundle;

class InvoiceService {
  /// Generate an invoice PDF using the specified print format configuration
  ///
  /// This method creates a PDF invoice using the template system, which allows
  /// for different layouts based on the print format (A4, 80mm, 58mm).
  ///
  /// Parameters:
  /// - [sale]: The sale/transaction data
  /// - [companyInfo]: Company information for the header
  /// - [customer]: Optional customer information
  /// - [config]: Print format configuration (format, display options)
  ///
  /// Returns: PDF as Uint8List bytes
  Future<Uint8List> generateInvoicePdf({
    required Sale sale,
    required CompanyInfo companyInfo,
    Customer? customer,
    PrintFormatConfig config = PrintFormatConfig.defaultConfig,
  }) async {
    // Load Arabic font for proper Arabic text rendering
    final arabicFont = await rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf');
    final arabicTtf = pw.Font.ttf(arabicFont);

    final pdf = pw.Document();

    // Generate ZATCA QR Code
    final qrData = ZatcaQrGenerator.generate(
      sellerName: companyInfo.name,
      vatNumber: companyInfo.vatNumber,
      invoiceDate: sale.saleDate,
      totalWithVat: sale.totalAmount,
      vatAmount: sale.vatAmount,
    );

    // Load company logo if available
    Uint8List? logoBytes;
    if (companyInfo.logoPath != null && companyInfo.logoPath!.isNotEmpty) {
      try {
        if (companyInfo.logoPath!.startsWith('assets/')) {
          // Load from assets
          final data = await rootBundle.load(companyInfo.logoPath!);
          logoBytes = data.buffer.asUint8List();
        } else {
          // Load from storage (file or base64)
          logoBytes = await ImageService.getImageBytes(companyInfo.logoPath);
        }
      } catch (e) {
        print('Error loading logo for invoice: $e');
        // Continue without logo
      }
    }

    // Create invoice data container
    final invoiceData = InvoiceData(
      sale: sale,
      companyInfo: companyInfo,
      customer: customer,
      zatcaQrData: qrData,
      logoBytes: logoBytes,
      arabicFont: arabicTtf,
    );

    // Get the appropriate template for the format
    final template = InvoiceTemplateFactory.create(config);

    // Add page with the template
    pdf.addPage(
      pw.Page(
        pageFormat: config.format.pageFormat,
        build: (pw.Context context) {
          return template.build(invoiceData);
        },
      ),
    );

    return pdf.save();
  }

  /// Legacy method - generates PDF with default A4 format
  /// Maintained for backward compatibility
  @Deprecated('Use generateInvoicePdf with PrintFormatConfig instead')
  Future<Uint8List> generateInvoicePdfLegacy({
    required Sale sale,
    required CompanyInfo companyInfo,
    Customer? customer,
  }) async {
    return generateInvoicePdf(
      sale: sale,
      companyInfo: companyInfo,
      customer: customer,
      config: const PrintFormatConfig(format: PrintFormat.a4),
    );
  }

  /// Print an invoice using the system's print dialog
  ///
  /// This method generates the PDF and opens the system print dialog,
  /// allowing the user to select a printer and print the invoice.
  ///
  /// Parameters:
  /// - [sale]: The sale/transaction data
  /// - [companyInfo]: Company information for the header
  /// - [customer]: Optional customer information
  /// - [config]: Print format configuration
  Future<void> printInvoice({
    required Sale sale,
    required CompanyInfo companyInfo,
    Customer? customer,
    PrintFormatConfig config = PrintFormatConfig.defaultConfig,
  }) async {
    final pdfBytes = await generateInvoicePdf(
      sale: sale,
      companyInfo: companyInfo,
      customer: customer,
      config: config,
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
      name: 'Invoice_${sale.invoiceNumber}.pdf',
    );
  }

  /// Preview an invoice before printing
  ///
  /// This method generates the PDF and returns it for preview purposes.
  /// Can be used with Flutter's PdfPreview widget.
  Future<Uint8List> previewInvoice({
    required Sale sale,
    required CompanyInfo companyInfo,
    Customer? customer,
    PrintFormatConfig config = PrintFormatConfig.defaultConfig,
  }) async {
    return generateInvoicePdf(
      sale: sale,
      companyInfo: companyInfo,
      customer: customer,
      config: config,
    );
  }
}
