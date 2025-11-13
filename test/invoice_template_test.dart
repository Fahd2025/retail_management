import 'package:flutter_test/flutter_test.dart';
import 'package:retail_management/models/print_format.dart';
import 'package:retail_management/services/invoice_templates/invoice_template_factory.dart';
import 'package:retail_management/services/invoice_templates/a4_invoice_template.dart';
import 'package:retail_management/services/invoice_templates/thermal_80mm_template.dart';
import 'package:retail_management/services/invoice_templates/thermal_58mm_template.dart';

void main() {
  group('PrintFormat', () {
    test('should have correct dimensions for A4', () {
      final format = PrintFormat.a4;
      expect(format.widthMm, 210);
      expect(format.heightMm, 297);
      expect(format.isThermal, false);
    });

    test('should have correct dimensions for 80mm thermal', () {
      final format = PrintFormat.thermal80mm;
      expect(format.widthMm, 80);
      expect(format.isThermal, true);
    });

    test('should have correct dimensions for 58mm thermal', () {
      final format = PrintFormat.thermal58mm;
      expect(format.widthMm, 58);
      expect(format.isThermal, true);
    });

    test('should convert mm to points correctly', () {
      final format = PrintFormat.a4;
      // 1mm = 2.83465 points
      expect(format.widthPt, closeTo(595.27, 0.1)); // 210mm in points
    });

    test('should have appropriate font sizes for each format', () {
      expect(PrintFormat.a4.defaultFontSize, 10);
      expect(PrintFormat.thermal80mm.defaultFontSize, 8);
      expect(PrintFormat.thermal58mm.defaultFontSize, 7);
    });

    test('should parse ID correctly', () {
      expect(PrintFormat.fromId('A4'), PrintFormat.a4);
      expect(PrintFormat.fromId('80mm'), PrintFormat.thermal80mm);
      expect(PrintFormat.fromId('58mm'), PrintFormat.thermal58mm);
      expect(PrintFormat.fromId('invalid'), PrintFormat.a4); // default
    });
  });

  group('PrintFormatConfig', () {
    test('should create with default values', () {
      const config = PrintFormatConfig.defaultConfig;
      expect(config.format, PrintFormat.a4);
      expect(config.showLogo, true);
      expect(config.showQrCode, true);
      expect(config.showCustomerInfo, true);
      expect(config.showNotes, true);
    });

    test('should serialize to JSON correctly', () {
      const config = PrintFormatConfig(
        format: PrintFormat.thermal80mm,
        showLogo: false,
        showQrCode: true,
        showCustomerInfo: false,
        showNotes: true,
      );

      final json = config.toJson();
      expect(json['format'], '80mm');
      expect(json['showLogo'], false);
      expect(json['showQrCode'], true);
      expect(json['showCustomerInfo'], false);
      expect(json['showNotes'], true);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'format': '58mm',
        'showLogo': true,
        'showQrCode': false,
        'showCustomerInfo': true,
        'showNotes': false,
      };

      final config = PrintFormatConfig.fromJson(json);
      expect(config.format, PrintFormat.thermal58mm);
      expect(config.showLogo, true);
      expect(config.showQrCode, false);
      expect(config.showCustomerInfo, true);
      expect(config.showNotes, false);
    });

    test('should handle missing JSON fields with defaults', () {
      final json = {
        'format': 'A4',
      };

      final config = PrintFormatConfig.fromJson(json);
      expect(config.format, PrintFormat.a4);
      expect(config.showLogo, true);
      expect(config.showQrCode, true);
      expect(config.showCustomerInfo, true);
      expect(config.showNotes, true);
    });

    test('should copy with new values', () {
      const config = PrintFormatConfig.defaultConfig;

      final newConfig = config.copyWith(
        format: PrintFormat.thermal80mm,
        showLogo: false,
      );

      expect(newConfig.format, PrintFormat.thermal80mm);
      expect(newConfig.showLogo, false);
      expect(newConfig.showQrCode, true); // unchanged
      expect(newConfig.showCustomerInfo, true); // unchanged
      expect(newConfig.showNotes, true); // unchanged
    });
  });

  group('InvoiceTemplateFactory', () {
    test('should create A4 template for A4 format', () {
      const config = PrintFormatConfig(format: PrintFormat.a4);
      final template = InvoiceTemplateFactory.create(config);

      expect(template, isA<A4InvoiceTemplate>());
      expect(template.format, PrintFormat.a4);
    });

    test('should create 80mm thermal template for 80mm format', () {
      const config = PrintFormatConfig(format: PrintFormat.thermal80mm);
      final template = InvoiceTemplateFactory.create(config);

      expect(template, isA<Thermal80mmTemplate>());
      expect(template.format, PrintFormat.thermal80mm);
    });

    test('should create 58mm thermal template for 58mm format', () {
      const config = PrintFormatConfig(format: PrintFormat.thermal58mm);
      final template = InvoiceTemplateFactory.create(config);

      expect(template, isA<Thermal58mmTemplate>());
      expect(template.format, PrintFormat.thermal58mm);
    });

    test('should create template with correct config', () {
      const config = PrintFormatConfig(
        format: PrintFormat.a4,
        showLogo: false,
        showQrCode: true,
      );
      final template = InvoiceTemplateFactory.create(config);

      expect(template.config.showLogo, false);
      expect(template.config.showQrCode, true);
    });

    test('should create template using convenience method', () {
      final template = InvoiceTemplateFactory.createForFormat(
        PrintFormat.thermal80mm,
        showLogo: false,
        showQrCode: true,
        showCustomerInfo: false,
        showNotes: true,
      );

      expect(template.format, PrintFormat.thermal80mm);
      expect(template.config.showLogo, false);
      expect(template.config.showQrCode, true);
      expect(template.config.showCustomerInfo, false);
      expect(template.config.showNotes, true);
    });
  });

  group('Invoice Templates', () {
    test('A4 template should have correct page format', () {
      const config = PrintFormatConfig(format: PrintFormat.a4);
      final template = InvoiceTemplateFactory.create(config);

      expect(template.format.widthMm, 210);
      expect(template.format.heightMm, 297);
    });

    test('80mm template should have correct page format', () {
      const config = PrintFormatConfig(format: PrintFormat.thermal80mm);
      final template = InvoiceTemplateFactory.create(config);

      expect(template.format.widthMm, 80);
    });

    test('58mm template should have correct page format', () {
      const config = PrintFormatConfig(format: PrintFormat.thermal58mm);
      final template = InvoiceTemplateFactory.create(config);

      expect(template.format.widthMm, 58);
    });

    test('should get payment method label correctly', () {
      const config = PrintFormatConfig(format: PrintFormat.a4);
      final template = InvoiceTemplateFactory.create(config);

      // The base template should have the helper method
      expect(template.getPaymentMethodLabel, isNotNull);
    });

    test('should have correct text styles for different formats', () {
      final a4Template = InvoiceTemplateFactory.createForFormat(PrintFormat.a4);
      final thermal80Template =
          InvoiceTemplateFactory.createForFormat(PrintFormat.thermal80mm);
      final thermal58Template =
          InvoiceTemplateFactory.createForFormat(PrintFormat.thermal58mm);

      // A4 should have larger fonts
      expect(a4Template.getDefaultTextStyle().fontSize,
          greaterThan(thermal80Template.getDefaultTextStyle().fontSize!));
      expect(thermal80Template.getDefaultTextStyle().fontSize,
          greaterThan(thermal58Template.getDefaultTextStyle().fontSize!));
    });
  });
}
