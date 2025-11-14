import 'package:intl/intl.dart';
import '../database/drift_database.dart';
import '../models/company_info.dart';

/// Helper class for currency formatting and symbol retrieval
class CurrencyHelper {
  static CompanyInfo? _cachedCompanyInfo;

  /// Get currency symbol for a given currency code
  static String getCurrencySymbol(String currencyCode) {
    switch (currencyCode) {
      case 'SAR':
        return 'ر.س';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'AED':
        return 'د.إ';
      case 'KWD':
        return 'د.ك';
      case 'BHD':
        return 'د.ب';
      case 'QAR':
        return 'ر.ق';
      case 'OMR':
        return 'ر.ع';
      case 'JOD':
        return 'د.أ';
      case 'EGP':
        return 'ج.م';
      default:
        return currencyCode;
    }
  }

  /// Load company info and cache it
  static Future<void> loadCompanyInfo() async {
    final db = AppDatabase();
    _cachedCompanyInfo = await db.getCompanyInfo();
  }

  /// Get the current company currency code
  static Future<String> getCurrencyCode() async {
    if (_cachedCompanyInfo == null) {
      await loadCompanyInfo();
    }
    return _cachedCompanyInfo?.currency ?? 'SAR';
  }

  /// Get the current company currency symbol
  static Future<String> getCurrencySymbolAsync() async {
    final currencyCode = await getCurrencyCode();
    return getCurrencySymbol(currencyCode);
  }

  /// Get the current company currency symbol (synchronous)
  /// Returns SAR if company info is not loaded
  static String getCurrencySymbolSync() {
    return getCurrencySymbol(_cachedCompanyInfo?.currency ?? 'SAR');
  }

  /// Format a number as currency with the company's currency
  static Future<String> formatCurrency(double amount) async {
    final currencyCode = await getCurrencyCode();
    final symbol = getCurrencySymbol(currencyCode);
    final formatter = NumberFormat.currency(symbol: '$symbol ', decimalDigits: 2);
    return formatter.format(amount);
  }

  /// Format a number as currency synchronously
  static String formatCurrencySync(double amount) {
    final symbol = getCurrencySymbolSync();
    final formatter = NumberFormat.currency(symbol: '$symbol ', decimalDigits: 2);
    return formatter.format(amount);
  }

  /// Get NumberFormat with company currency
  static Future<NumberFormat> getCurrencyFormatter() async {
    final currencyCode = await getCurrencyCode();
    final symbol = getCurrencySymbol(currencyCode);
    return NumberFormat.currency(symbol: '$symbol ', decimalDigits: 2);
  }

  /// Get NumberFormat with company currency (synchronous)
  static NumberFormat getCurrencyFormatterSync() {
    final symbol = getCurrencySymbolSync();
    return NumberFormat.currency(symbol: '$symbol ', decimalDigits: 2);
  }

  /// Clear cached company info (call this when company info is updated)
  static void clearCache() {
    _cachedCompanyInfo = null;
  }

  /// Refresh cached company info
  static Future<void> refreshCache() async {
    await loadCompanyInfo();
  }
}
