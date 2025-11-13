import '../../models/print_format.dart';
import 'invoice_template.dart';
import 'a4_invoice_template.dart';
import 'thermal_80mm_template.dart';
import 'thermal_58mm_template.dart';

/// Factory class for creating invoice templates
///
/// This factory provides a centralized way to create the appropriate
/// invoice template based on the print format configuration.
///
/// Usage:
/// ```dart
/// final template = InvoiceTemplateFactory.create(config);
/// final widget = template.build(invoiceData);
/// ```
class InvoiceTemplateFactory {
  /// Create an invoice template based on the provided configuration
  ///
  /// Returns the appropriate template implementation for the specified format:
  /// - A4InvoiceTemplate for PrintFormat.a4
  /// - Thermal80mmTemplate for PrintFormat.thermal80mm
  /// - Thermal58mmTemplate for PrintFormat.thermal58mm
  static InvoiceTemplate create(PrintFormatConfig config) {
    switch (config.format) {
      case PrintFormat.a4:
        return A4InvoiceTemplate(config: config);
      case PrintFormat.thermal80mm:
        return Thermal80mmTemplate(config: config);
      case PrintFormat.thermal58mm:
        return Thermal58mmTemplate(config: config);
    }
  }

  /// Get a template for a specific format (convenience method)
  static InvoiceTemplate createForFormat(
    PrintFormat format, {
    bool showLogo = true,
    bool showQrCode = true,
    bool showCustomerInfo = true,
    bool showNotes = true,
  }) {
    final config = PrintFormatConfig(
      format: format,
      showLogo: showLogo,
      showQrCode: showQrCode,
      showCustomerInfo: showCustomerInfo,
      showNotes: showNotes,
    );
    return create(config);
  }
}
