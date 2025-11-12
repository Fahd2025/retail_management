# Custom Invoice Printing Documentation

## Overview

The retail management system now supports custom-sized invoice printing with three paper formats:
- **A4** (210×297mm) - Standard document format
- **80mm Thermal** - Standard POS receipt printer
- **58mm Thermal** - Compact portable POS printer

This document provides comprehensive guidance on using, customizing, and extending the invoice printing system.

## Table of Contents

1. [User Guide](#user-guide)
2. [Architecture](#architecture)
3. [Template Customization Guide](#template-customization-guide)
4. [Adding New Formats](#adding-new-formats)
5. [API Reference](#api-reference)
6. [Troubleshooting](#troubleshooting)

---

## User Guide

### Configuring Print Format

1. **Navigate to Settings**
   - Open the app and go to the Settings screen
   - Find the "Print Settings" section

2. **Select Print Format**
   - Choose from three available formats:
     - A4 (210×297mm) - Best for full-page invoices
     - 80mm Thermal - Standard receipt printers
     - 58mm Thermal - Compact portable printers

3. **Configure Display Options**
   - Toggle options to customize what appears on invoices:
     - Show Company Logo
     - Show QR Code (ZATCA-compliant)
     - Show Customer Information
     - Show Notes

### Printing an Invoice

1. **Complete a Sale**
   - After completing a sale in the Cashier screen
   - Tap "Yes" when asked to print

2. **Select Format (Optional)**
   - A bottom sheet appears with format options
   - Select your preferred format for this print
   - The system remembers your default from settings

3. **Preview or Print**
   - Tap "Print Now" to send directly to printer
   - Tap "Preview" to see the invoice before printing
   - Use the preview to verify layout and content

---

## Architecture

### Component Overview

```
┌─────────────────────────────────────────────────────┐
│                 Invoice Printing System              │
└─────────────────────────────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
        ▼                 ▼                 ▼
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│   Models    │  │   Services  │  │  UI Widgets │
│             │  │             │  │             │
│ PrintFormat │  │   Invoice   │  │   Format    │
│   Config    │  │   Service   │  │  Selector   │
│             │  │             │  │             │
│  Template   │  │  Template   │  │   Preview   │
│    Data     │  │   Factory   │  │   Dialog    │
└─────────────┘  └─────────────┘  └─────────────┘
                        │
        ┌───────────────┼───────────────┐
        │               │               │
        ▼               ▼               ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│ A4 Template │ │ 80mm Temp.  │ │ 58mm Temp.  │
└─────────────┘ └─────────────┘ └─────────────┘
```

### Key Components

1. **PrintFormat** (`lib/models/print_format.dart`)
   - Enum defining available formats
   - Dimension calculations (mm to PDF points)
   - Font size recommendations

2. **PrintFormatConfig** (`lib/models/print_format.dart`)
   - Configuration for print settings
   - Display options (logo, QR, customer info, notes)
   - JSON serialization for persistence

3. **InvoiceTemplate** (`lib/services/invoice_templates/invoice_template.dart`)
   - Abstract base class for all templates
   - Common helper methods
   - Standardized build() interface

4. **Template Implementations**
   - `A4InvoiceTemplate` - Full-page layout
   - `Thermal80mmTemplate` - Standard receipt
   - `Thermal58mmTemplate` - Compact receipt

5. **InvoiceService** (`lib/services/invoice_service.dart`)
   - PDF generation using templates
   - Print dialog integration
   - Preview functionality

---

## Template Customization Guide

### Modifying Existing Templates

Each template has a modular structure with separate methods for each section:

#### 1. Modify the A4 Template

**File:** `lib/services/invoice_templates/a4_invoice_template.dart`

```dart
@override
pw.Widget buildHeader(InvoiceData data) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      // Customize company logo
      pw.Container(
        width: 100,  // Change logo size
        height: 100,
        child: pw.Image(...), // Add actual logo
      ),
      // Modify company info layout
      pw.Column(
        children: [
          // Customize text styles, add/remove fields
        ],
      ),
    ],
  );
}
```

**Common Customizations:**

1. **Change Font Sizes:**
   ```dart
   pw.Text(
     'Invoice Title',
     style: pw.TextStyle(
       fontSize: 20,  // Adjust size
       fontWeight: pw.FontWeight.bold,
     ),
   )
   ```

2. **Modify Spacing:**
   ```dart
   pw.SizedBox(height: 30),  // Increase/decrease spacing
   ```

3. **Change Colors:**
   ```dart
   pw.Container(
     decoration: pw.BoxDecoration(
       color: PdfColors.blue100,  // Custom color
     ),
   )
   ```

4. **Customize Table:**
   ```dart
   @override
   pw.Widget buildItemsTable(InvoiceData data) {
     return pw.Table(
       border: pw.TableBorder.all(
         color: PdfColors.black,
         width: 2,  // Thicker border
       ),
       // Add/remove columns as needed
     );
   }
   ```

#### 2. Modify Thermal Templates

**Files:**
- `lib/services/invoice_templates/thermal_80mm_template.dart`
- `lib/services/invoice_templates/thermal_58mm_template.dart`

**Key Considerations for Thermal Printers:**

1. **Keep Text Compact:**
   ```dart
   pw.Text(
     'Item Name',
     style: pw.TextStyle(
       fontSize: 7,  // Small fonts for thermal
     ),
   )
   ```

2. **Center-Align Content:**
   ```dart
   pw.Column(
     crossAxisAlignment: pw.CrossAxisAlignment.center,
     children: [
       // Centered content looks better on receipts
     ],
   )
   ```

3. **Use Dividers for Sections:**
   ```dart
   pw.Container(
     decoration: pw.BoxDecoration(
       border: pw.Border(
         bottom: pw.BorderSide(width: 1),
       ),
     ),
   )
   ```

### Override Specific Sections

You can override individual methods without changing the entire template:

```dart
class CustomA4Template extends A4InvoiceTemplate {
  CustomA4Template({required PrintFormatConfig config})
      : super(config: config);

  @override
  pw.Widget buildFooter(InvoiceData data) {
    // Your custom footer
    return pw.Column(
      children: [
        pw.Text('Custom Thank You Message'),
        // Your custom QR code positioning
        pw.BarcodeWidget(
          data: data.zatcaQrData,
          barcode: pw.Barcode.qrCode(),
          width: 150,  // Custom size
          height: 150,
        ),
      ],
    );
  }
}
```

Then register your custom template in the factory:

```dart
// In invoice_template_factory.dart
case PrintFormat.a4:
  return CustomA4Template(config: config);
```

---

## Adding New Formats

### Step 1: Add to PrintFormat Enum

```dart
// In lib/models/print_format.dart
enum PrintFormat {
  // ... existing formats

  /// Custom format - 100mm paper
  custom100mm('100mm', '100mm Custom', 100, 297);

  // ... rest of enum
}
```

### Step 2: Create Template Class

```dart
// Create lib/services/invoice_templates/custom_100mm_template.dart
import 'package:pdf/widgets.dart' as pw;
import '../../models/print_format.dart';
import 'invoice_template.dart';

class Custom100mmTemplate extends InvoiceTemplate {
  Custom100mmTemplate({required PrintFormatConfig config})
      : super(
          format: PrintFormat.custom100mm,
          config: config,
        );

  @override
  pw.Widget build(InvoiceData data) {
    return pw.Column(
      children: [
        buildHeader(data),
        buildTitle(data),
        buildInvoiceInfo(data),
        buildItemsTable(data),
        buildTotals(data),
        buildFooter(data),
      ],
    );
  }

  // Implement other required methods...
}
```

### Step 3: Update Factory

```dart
// In lib/services/invoice_templates/invoice_template_factory.dart
static InvoiceTemplate create(PrintFormatConfig config) {
  switch (config.format) {
    // ... existing cases
    case PrintFormat.custom100mm:
      return Custom100mmTemplate(config: config);
  }
}
```

### Step 4: Test Your Template

```dart
// In test/custom_template_test.dart
test('should create custom 100mm template', () {
  const config = PrintFormatConfig(format: PrintFormat.custom100mm);
  final template = InvoiceTemplateFactory.create(config);

  expect(template, isA<Custom100mmTemplate>());
  expect(template.format, PrintFormat.custom100mm);
});
```

---

## API Reference

### InvoiceService

#### generateInvoicePdf()

Generates a PDF invoice using the specified format.

```dart
Future<Uint8List> generateInvoicePdf({
  required Sale sale,
  required CompanyInfo companyInfo,
  Customer? customer,
  PrintFormatConfig config = PrintFormatConfig.defaultConfig,
})
```

**Parameters:**
- `sale`: The sale/transaction data
- `companyInfo`: Company information for the header
- `customer`: Optional customer information
- `config`: Print format configuration

**Returns:** PDF as `Uint8List` bytes

**Example:**
```dart
final invoiceService = InvoiceService();
final pdfBytes = await invoiceService.generateInvoicePdf(
  sale: currentSale,
  companyInfo: myCompanyInfo,
  customer: selectedCustomer,
  config: PrintFormatConfig(
    format: PrintFormat.thermal80mm,
    showLogo: false,
    showQrCode: true,
  ),
);
```

#### printInvoice()

Opens the system print dialog with the generated invoice.

```dart
Future<void> printInvoice({
  required Sale sale,
  required CompanyInfo companyInfo,
  Customer? customer,
  PrintFormatConfig config = PrintFormatConfig.defaultConfig,
})
```

#### previewInvoice()

Generates PDF for preview purposes (used by preview widgets).

```dart
Future<Uint8List> previewInvoice({
  required Sale sale,
  required CompanyInfo companyInfo,
  Customer? customer,
  PrintFormatConfig config = PrintFormatConfig.defaultConfig,
})
```

### InvoiceTemplateFactory

#### create()

Creates the appropriate template based on configuration.

```dart
static InvoiceTemplate create(PrintFormatConfig config)
```

#### createForFormat()

Convenience method to create a template with default options.

```dart
static InvoiceTemplate createForFormat(
  PrintFormat format, {
  bool showLogo = true,
  bool showQrCode = true,
  bool showCustomerInfo = true,
  bool showNotes = true,
})
```

### InvoiceTemplate (Base Class)

All templates extend this abstract class and must implement:

```dart
pw.Widget build(InvoiceData data);
```

**Optional overridable methods:**
- `buildHeader(InvoiceData data)`
- `buildTitle(InvoiceData data)`
- `buildInvoiceInfo(InvoiceData data)`
- `buildCustomerInfo(InvoiceData data)`
- `buildItemsTable(InvoiceData data)`
- `buildTotals(InvoiceData data)`
- `buildFooter(InvoiceData data)`
- `buildNotes(InvoiceData data)`

**Helper methods available:**
- `getPaymentMethodLabel(PaymentMethod method)`
- `buildDivider()`
- `getDefaultTextStyle()`
- `getHeadingTextStyle()`
- `getTitleTextStyle()`

---

## Troubleshooting

### Issue: Text is cut off in thermal receipts

**Solution:** Reduce font sizes or line spacing in the thermal templates.

```dart
// In thermal templates
pw.Text(
  item.productName,
  style: pw.TextStyle(
    fontSize: 6,  // Smaller font
  ),
  maxLines: 2,    // Allow wrapping
)
```

### Issue: QR code is too large

**Solution:** Adjust QR code dimensions in the template's `buildFooter()` method.

```dart
pw.BarcodeWidget(
  data: data.zatcaQrData,
  barcode: pw.Barcode.qrCode(),
  width: 60,   // Reduced from 80
  height: 60,
)
```

### Issue: Invoice is blank or shows errors

**Solution:** Check that all required data is provided:

```dart
// Ensure sale has items
if (sale.items.isEmpty) {
  throw Exception('Sale must have at least one item');
}

// Ensure company info exists
if (companyInfo == null) {
  throw Exception('Company information is required');
}
```

### Issue: Preview doesn't match printed output

**Solution:** Some printers have margins. Test actual prints and adjust template margins:

```dart
// In print_format.dart
pw.PageFormat get pageFormat {
  return pw.PageFormat(
    widthPt,
    heightPt,
    marginAll: 5 * 2.83465,  // Increase margins
  );
}
```

### Issue: Arabic text not displaying correctly

**Solution:** Ensure proper text direction and font support:

```dart
pw.Text(
  arabicText,
  textDirection: pw.TextDirection.rtl,  // Right-to-left
)
```

### Issue: Print format not persisting

**Solution:** Check that AppConfigBloc is properly initialized:

```dart
// In main.dart
BlocProvider(
  create: (context) => AppConfigBloc()
    ..add(const InitializeAppConfigEvent()),
  child: MyApp(),
)
```

---

## Best Practices

1. **Always test on actual printers** - Preview may differ from physical output
2. **Use appropriate font sizes** - Smaller for thermal, larger for A4
3. **Keep thermal receipts compact** - Paper is expensive
4. **Include ZATCA QR codes** - Required for Saudi tax compliance
5. **Provide print previews** - Let users verify before printing
6. **Save user preferences** - Remember their preferred format
7. **Handle errors gracefully** - Show clear messages if printing fails
8. **Test with edge cases** - Long item names, many items, missing data
9. **Support bilingual content** - English and Arabic for Saudi market
10. **Document customizations** - Help future developers understand changes

---

## Examples

### Example 1: Quick Print with Default Settings

```dart
final invoiceService = InvoiceService();
await invoiceService.printInvoice(
  sale: currentSale,
  companyInfo: companyInfo,
);
```

### Example 2: Generate PDF for Email

```dart
final pdfBytes = await invoiceService.generateInvoicePdf(
  sale: currentSale,
  companyInfo: companyInfo,
  config: PrintFormatConfig(format: PrintFormat.a4),
);

// Email the PDF
await emailService.sendPdfAttachment(
  to: customer.email,
  subject: 'Your Invoice',
  attachment: pdfBytes,
);
```

### Example 3: Custom Format Selection Dialog

```dart
// Show format selector before printing
final selectedFormat = await showDialog<PrintFormat>(
  context: context,
  builder: (context) => PrintFormatQuickSelector(
    selectedFormat: currentFormat,
    onFormatChanged: (format) {
      Navigator.pop(context, format);
    },
  ),
);

if (selectedFormat != null) {
  await invoiceService.printInvoice(
    sale: currentSale,
    companyInfo: companyInfo,
    config: PrintFormatConfig(format: selectedFormat),
  );
}
```

---

## Support

For questions or issues:
1. Check this documentation first
2. Review the test files for usage examples
3. Examine existing template implementations
4. Create an issue in the project repository

---

## Version History

- **v1.0** (2024) - Initial implementation
  - Three print formats (A4, 80mm, 58mm)
  - Modular template system
  - User preferences and preview
  - ZATCA QR code support
