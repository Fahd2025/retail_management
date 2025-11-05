import 'dart:convert';
import 'dart:typed_data';

/// ZATCA (Saudi Tax Authority) QR Code Generator
/// Generates QR codes according to ZATCA e-invoicing requirements
class ZatcaQrGenerator {
  /// Generate ZATCA-compliant QR code data
  static String generate({
    required String sellerName,
    required String vatNumber,
    required DateTime invoiceDate,
    required double totalWithVat,
    required double vatAmount,
  }) {
    final tags = <int, String>{
      1: sellerName, // Seller name
      2: vatNumber, // VAT registration number
      3: invoiceDate.toIso8601String(), // Invoice timestamp
      4: totalWithVat.toStringAsFixed(2), // Invoice total with VAT
      5: vatAmount.toStringAsFixed(2), // VAT amount
    };

    final buffer = BytesBuilder();

    tags.forEach((tag, value) {
      final valueBytes = utf8.encode(value);
      buffer.addByte(tag); // Tag
      buffer.addByte(valueBytes.length); // Length
      buffer.add(valueBytes); // Value
    });

    return base64Encode(buffer.toBytes());
  }

  /// Decode ZATCA QR code data (for verification)
  static Map<int, String>? decode(String qrData) {
    try {
      final bytes = base64Decode(qrData);
      final tags = <int, String>{};

      var index = 0;
      while (index < bytes.length) {
        final tag = bytes[index];
        final length = bytes[index + 1];
        final value = utf8.decode(bytes.sublist(index + 2, index + 2 + length));

        tags[tag] = value;
        index += 2 + length;
      }

      return tags;
    } catch (e) {
      return null;
    }
  }
}
