import 'package:pdf/widgets.dart' as pw;

/// Enum representing available print formats for invoices
enum PrintFormat {
  /// 58mm thermal receipt paper (common for portable POS printers)
  thermal58mm('58mm', '58mm Thermal', 58, 297),

  /// 80mm thermal receipt paper (standard POS printer size)
  thermal80mm('80mm', '80mm Thermal', 80, 297),

  /// A4 paper size (standard document format)
  a4('A4', 'A4 (210×297mm)', 210, 297);

  const PrintFormat(this.id, this.displayName, this.widthMm, this.heightMm);

  /// Unique identifier for the format
  final String id;

  /// Display name shown to users
  final String displayName;

  /// Width in millimeters
  final double widthMm;

  /// Height in millimeters (for thermal receipts, this is dynamic)
  final double heightMm;

  /// Convert millimeters to PDF points (1mm = 2.83465 points)
  double get widthPt => widthMm * 2.83465;
  double get heightPt => heightMm * 2.83465;

  /// Get the PDF page format for this print format
  pw.PageFormat get pageFormat {
    switch (this) {
      case PrintFormat.thermal58mm:
        // For thermal printers, height is dynamic based on content
        // Using a large height that will be trimmed by content
        return pw.PageFormat(widthPt, 842, marginAll: 2 * 2.83465); // ~2mm margins
      case PrintFormat.thermal80mm:
        return pw.PageFormat(widthPt, 842, marginAll: 2 * 2.83465); // ~2mm margins
      case PrintFormat.a4:
        return pw.PageFormat.a4.copyWith(
          marginLeft: 10 * 2.83465,  // 10mm
          marginRight: 10 * 2.83465, // 10mm
          marginTop: 10 * 2.83465,   // 10mm
          marginBottom: 10 * 2.83465, // 10mm
        );
    }
  }

  /// Get default font size for this format
  double get defaultFontSize {
    switch (this) {
      case PrintFormat.thermal58mm:
        return 7;
      case PrintFormat.thermal80mm:
        return 8;
      case PrintFormat.a4:
        return 10;
    }
  }

  /// Get heading font size for this format
  double get headingFontSize {
    switch (this) {
      case PrintFormat.thermal58mm:
        return 9;
      case PrintFormat.thermal80mm:
        return 11;
      case PrintFormat.a4:
        return 14;
    }
  }

  /// Get title font size for this format
  double get titleFontSize {
    switch (this) {
      case PrintFormat.thermal58mm:
        return 11;
      case PrintFormat.thermal80mm:
        return 13;
      case PrintFormat.a4:
        return 18;
    }
  }

  /// Check if this is a thermal receipt format
  bool get isThermal => this == thermal58mm || this == thermal80mm;

  /// Parse a string ID to PrintFormat
  static PrintFormat fromId(String id) {
    return PrintFormat.values.firstWhere(
      (format) => format.id == id,
      orElse: () => PrintFormat.a4,
    );
  }

  /// Get all available formats as a list
  static List<PrintFormat> get all => PrintFormat.values;
}

/// Configuration class for print format settings
class PrintFormatConfig {
  const PrintFormatConfig({
    required this.format,
    this.showLogo = true,
    this.showQrCode = true,
    this.showCustomerInfo = true,
    this.showNotes = true,
  });

  final PrintFormat format;
  final bool showLogo;
  final bool showQrCode;
  final bool showCustomerInfo;
  final bool showNotes;

  PrintFormatConfig copyWith({
    PrintFormat? format,
    bool? showLogo,
    bool? showQrCode,
    bool? showCustomerInfo,
    bool? showNotes,
  }) {
    return PrintFormatConfig(
      format: format ?? this.format,
      showLogo: showLogo ?? this.showLogo,
      showQrCode: showQrCode ?? this.showQrCode,
      showCustomerInfo: showCustomerInfo ?? this.showCustomerInfo,
      showNotes: showNotes ?? this.showNotes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'format': format.id,
      'showLogo': showLogo,
      'showQrCode': showQrCode,
      'showCustomerInfo': showCustomerInfo,
      'showNotes': showNotes,
    };
  }

  factory PrintFormatConfig.fromJson(Map<String, dynamic> json) {
    return PrintFormatConfig(
      format: PrintFormat.fromId(json['format'] as String? ?? 'A4'),
      showLogo: json['showLogo'] as bool? ?? true,
      showQrCode: json['showQrCode'] as bool? ?? true,
      showCustomerInfo: json['showCustomerInfo'] as bool? ?? true,
      showNotes: json['showNotes'] as bool? ?? true,
    );
  }

  static const defaultConfig = PrintFormatConfig(
    format: PrintFormat.a4,
    showLogo: true,
    showQrCode: true,
    showCustomerInfo: true,
    showNotes: true,
  );
}
