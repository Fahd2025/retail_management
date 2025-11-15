import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../database/drift_database.dart';
import '../blocs/data_import_export/data_import_export_event.dart';
import 'package:drift/drift.dart' as drift;

// Platform-specific imports using conditional imports
import 'dart:io';
import 'package:path_provider/path_provider.dart';
// Conditional import for web file download
import 'web_file_download_stub.dart'
    if (dart.library.html) 'web_file_download.dart';

/// Result model for import/export operations
class ImportExportResult {
  final bool success;
  final String message;
  final String? filePath;
  final int? itemsImported;
  final String? errorDetails;

  ImportExportResult({
    required this.success,
    required this.message,
    this.filePath,
    this.itemsImported,
    this.errorDetails,
  });
}

/// Result model for data type detection
class DataTypeDetectionResult {
  final List<DataType> detectedTypes;
  final Map<DataType, int> itemCounts;
  final bool isValid;
  final String? errorMessage;
  final bool hasAppConfig; // Whether imported settings contain app configuration
  final Map<String, dynamic>? appConfigData; // The app config data if present

  DataTypeDetectionResult({
    required this.detectedTypes,
    required this.itemCounts,
    required this.isValid,
    this.errorMessage,
    this.hasAppConfig = false,
    this.appConfigData,
  });
}

/// Service for handling data import and export operations
class DataImportExportService {
  final AppDatabase _database;
  final _uuid = const Uuid();

  DataImportExportService({required AppDatabase database})
      : _database = database;

  /// Export data based on selected data types and format
  Future<ImportExportResult> exportData({
    required List<DataType> dataTypes,
    required ExportFormat format,
    Function(double)? onProgress,
  }) async {
    try {
      onProgress?.call(0.1);

      // Check if "All" is selected
      final typesToExport = dataTypes.contains(DataType.all)
          ? [
              DataType.products,
              DataType.categories,
              DataType.customers,
              DataType.sales,
              DataType.users,
              DataType.settings,
            ]
          : dataTypes;

      // Collect all data
      final Map<String, dynamic> exportData = {};
      int totalTypes = typesToExport.length;
      int completedTypes = 0;

      for (final type in typesToExport) {
        switch (type) {
          case DataType.products:
            exportData['products'] = await _exportProducts();
            break;
          case DataType.categories:
            exportData['categories'] = await _exportCategories();
            break;
          case DataType.customers:
            exportData['customers'] = await _exportCustomers();
            break;
          case DataType.sales:
            final salesData = await _exportSales();
            exportData['sales'] = salesData['sales'];
            exportData['sale_items'] = salesData['sale_items'];
            break;
          case DataType.users:
            exportData['users'] = await _exportUsers();
            break;
          case DataType.settings:
            exportData['settings'] = await _exportSettings();
            break;
          case DataType.all:
            // Already handled above
            break;
        }

        completedTypes++;
        onProgress?.call(0.1 + (completedTypes / totalTypes) * 0.7);
      }

      onProgress?.call(0.8);

      // Generate file
      String filePath;
      if (format == ExportFormat.json) {
        filePath = await _saveJsonFile(exportData, typesToExport);
      } else {
        filePath = await _saveCsvFiles(exportData, typesToExport);
      }

      onProgress?.call(1.0);

      return ImportExportResult(
        success: true,
        message: 'Data exported successfully',
        filePath: filePath,
      );
    } catch (e) {
      return ImportExportResult(
        success: false,
        message: 'Export failed',
        errorDetails: e.toString(),
      );
    }
  }

  /// Import data from file
  Future<ImportExportResult> importData({
    String? filePath,
    String? fileContent,
    String? fileName,
    required List<DataType> dataTypes,
    Function(double)? onProgress,
  }) async {
    try {
      onProgress?.call(0.1);

      String content;
      String effectiveFileName;

      // Handle both file path (mobile) and file content (web)
      if (fileContent != null) {
        // Web platform - content already provided
        content = fileContent;
        effectiveFileName = fileName ?? 'import';
      } else if (filePath != null) {
        // Mobile platform - read from file path
        final file = File(filePath);
        if (!await file.exists()) {
          return ImportExportResult(
            success: false,
            message: 'File not found',
            errorDetails: 'The selected file does not exist',
          );
        }
        content = await file.readAsString();
        effectiveFileName = filePath;
      } else {
        return ImportExportResult(
          success: false,
          message: 'No file provided',
          errorDetails: 'Either filePath or fileContent must be provided',
        );
      }

      onProgress?.call(0.2);

      Map<String, dynamic> importData;

      // Detect file format and parse
      if (effectiveFileName.endsWith('.json')) {
        importData = json.decode(content) as Map<String, dynamic>;
      } else if (effectiveFileName.endsWith('.csv')) {
        // For CSV, we need to determine which type it is
        if (filePath != null) {
          importData = await _parseCsvFile(filePath, dataTypes);
        } else {
          // For web, parse CSV from content
          importData = await _parseCsvFromContent(content, dataTypes);
        }
      } else {
        return ImportExportResult(
          success: false,
          message: 'Unsupported file format',
          errorDetails: 'Only JSON and CSV files are supported',
        );
      }

      onProgress?.call(0.3);

      // Check if "All" is selected
      final typesToImport = dataTypes.contains(DataType.all)
          ? [
              DataType.categories, // Import categories first (dependencies)
              DataType.products,
              DataType.customers,
              DataType.users,
              DataType.sales,
              DataType.settings,
            ]
          : dataTypes;

      int totalImported = 0;
      int totalTypes = typesToImport.length;
      int completedTypes = 0;

      for (final type in typesToImport) {
        switch (type) {
          case DataType.products:
            if (importData.containsKey('products')) {
              totalImported += await _importProducts(
                  importData['products'] as List<dynamic>);
            }
            break;
          case DataType.categories:
            if (importData.containsKey('categories')) {
              totalImported += await _importCategories(
                  importData['categories'] as List<dynamic>);
            }
            break;
          case DataType.customers:
            if (importData.containsKey('customers')) {
              totalImported += await _importCustomers(
                  importData['customers'] as List<dynamic>);
            }
            break;
          case DataType.sales:
            if (importData.containsKey('sales')) {
              totalImported += await _importSales(
                importData['sales'] as List<dynamic>,
                importData['sale_items'] as List<dynamic>? ?? [],
              );
            }
            break;
          case DataType.users:
            if (importData.containsKey('users')) {
              totalImported +=
                  await _importUsers(importData['users'] as List<dynamic>);
            }
            break;
          case DataType.settings:
            if (importData.containsKey('settings')) {
              totalImported += await _importSettings(
                  importData['settings'] as List<dynamic>);
            }
            break;
          case DataType.all:
            // Already handled above
            break;
        }

        completedTypes++;
        onProgress?.call(0.3 + (completedTypes / totalTypes) * 0.7);
      }

      onProgress?.call(1.0);

      return ImportExportResult(
        success: true,
        message: 'Data imported successfully',
        itemsImported: totalImported,
      );
    } catch (e) {
      return ImportExportResult(
        success: false,
        message: 'Import failed',
        errorDetails: e.toString(),
      );
    }
  }

  /// Detect data types present in a file
  Future<DataTypeDetectionResult> detectDataTypes({
    String? filePath,
    String? fileContent,
    String? fileName,
  }) async {
    try {
      String content;
      String effectiveFileName;

      // Handle both file path (mobile) and file content (web)
      if (fileContent != null) {
        content = fileContent;
        effectiveFileName = fileName ?? 'import';
      } else if (filePath != null) {
        final file = File(filePath);
        if (!await file.exists()) {
          return DataTypeDetectionResult(
            detectedTypes: [],
            itemCounts: {},
            isValid: false,
            errorMessage: 'File not found',
          );
        }
        content = await file.readAsString();
        effectiveFileName = filePath;
      } else {
        return DataTypeDetectionResult(
          detectedTypes: [],
          itemCounts: {},
          isValid: false,
          errorMessage: 'No file provided',
        );
      }

      Map<String, dynamic> data;

      // Parse based on file format
      if (effectiveFileName.endsWith('.json')) {
        try {
          data = json.decode(content) as Map<String, dynamic>;
        } catch (e) {
          return DataTypeDetectionResult(
            detectedTypes: [],
            itemCounts: {},
            isValid: false,
            errorMessage: 'Invalid JSON format',
          );
        }
      } else if (effectiveFileName.endsWith('.csv')) {
        // For CSV, try to detect from content structure
        try {
          final csvData = const CsvToListConverter().convert(content);
          if (csvData.isEmpty || csvData.length < 2) {
            return DataTypeDetectionResult(
              detectedTypes: [],
              itemCounts: {},
              isValid: false,
              errorMessage: 'CSV file is empty or invalid',
            );
          }

          // Analyze CSV headers to determine data type
          final headers = csvData.first.map((h) => h.toString().toLowerCase()).toList();

          // Detect data type based on column names
          DataType? detectedType;
          if (headers.contains('barcode') || headers.contains('price') || headers.contains('quantity')) {
            detectedType = DataType.products;
          } else if (headers.contains('vatNumber') || headers.contains('crnNumber') || headers.contains('phone')) {
            detectedType = DataType.customers;
          } else if (headers.contains('invoiceNumber') || headers.contains('totalAmount')) {
            detectedType = DataType.sales;
          } else if (headers.contains('username') || headers.contains('role')) {
            detectedType = DataType.users;
          }

          if (detectedType != null) {
            return DataTypeDetectionResult(
              detectedTypes: [detectedType],
              itemCounts: {detectedType: csvData.length - 1}, // Exclude header row
              isValid: true,
            );
          } else {
            return DataTypeDetectionResult(
              detectedTypes: [],
              itemCounts: {},
              isValid: false,
              errorMessage: 'Could not determine data type from CSV structure',
            );
          }
        } catch (e) {
          return DataTypeDetectionResult(
            detectedTypes: [],
            itemCounts: {},
            isValid: false,
            errorMessage: 'Invalid CSV format',
          );
        }
      } else {
        return DataTypeDetectionResult(
          detectedTypes: [],
          itemCounts: {},
          isValid: false,
          errorMessage: 'Unsupported file format',
        );
      }

      // Detect data types from JSON keys
      final List<DataType> detectedTypes = [];
      final Map<DataType, int> itemCounts = {};

      if (data.containsKey('products') && data['products'] is List) {
        detectedTypes.add(DataType.products);
        itemCounts[DataType.products] = (data['products'] as List).length;
      }

      if (data.containsKey('categories') && data['categories'] is List) {
        detectedTypes.add(DataType.categories);
        itemCounts[DataType.categories] = (data['categories'] as List).length;
      }

      if (data.containsKey('customers') && data['customers'] is List) {
        detectedTypes.add(DataType.customers);
        itemCounts[DataType.customers] = (data['customers'] as List).length;
      }

      if (data.containsKey('sales') && data['sales'] is List) {
        detectedTypes.add(DataType.sales);
        itemCounts[DataType.sales] = (data['sales'] as List).length;
      }

      if (data.containsKey('users') && data['users'] is List) {
        detectedTypes.add(DataType.users);
        itemCounts[DataType.users] = (data['users'] as List).length;
      }

      // Check for settings and app configuration
      bool hasAppConfig = false;
      Map<String, dynamic>? appConfigData;

      if (data.containsKey('settings') && data['settings'] is List) {
        detectedTypes.add(DataType.settings);
        itemCounts[DataType.settings] = (data['settings'] as List).length;

        // Check if settings contain app configuration
        final settingsList = data['settings'] as List;
        if (settingsList.isNotEmpty) {
          final firstSetting = settingsList.first as Map<String, dynamic>;
          if (firstSetting.containsKey('appConfig') && firstSetting['appConfig'] != null) {
            hasAppConfig = true;
            appConfigData = firstSetting['appConfig'] as Map<String, dynamic>;
          }
        }
      }

      if (detectedTypes.isEmpty) {
        return DataTypeDetectionResult(
          detectedTypes: [],
          itemCounts: {},
          isValid: false,
          errorMessage: 'No valid data types found in file',
        );
      }

      return DataTypeDetectionResult(
        detectedTypes: detectedTypes,
        itemCounts: itemCounts,
        isValid: true,
        hasAppConfig: hasAppConfig,
        appConfigData: appConfigData,
      );
    } catch (e) {
      return DataTypeDetectionResult(
        detectedTypes: [],
        itemCounts: {},
        isValid: false,
        errorMessage: 'Error detecting data types: ${e.toString()}',
      );
    }
  }

  // ============= EXPORT METHODS =============

  Future<List<Map<String, dynamic>>> _exportProducts() async {
    final products = await _database.select(_database.products).get();
    return products
        .map((p) => {
              'id': p.id,
              'name': p.name,
              'nameAr': p.nameAr,
              'description': p.description,
              'descriptionAr': p.descriptionAr,
              'barcode': p.barcode,
              'price': p.price,
              'cost': p.cost,
              'quantity': p.quantity,
              'categoryId': p.categoryId,
              'imageUrl': p.imageUrl,
              'isActive': p.isActive,
              'vatRate': p.vatRate,
              'createdAt': p.createdAt,
              'updatedAt': p.updatedAt,
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> _exportCategories() async {
    final categories =
        await _database.select(_database.categoriesTable).get();
    return categories
        .map((c) => {
              'id': c.id,
              'name': c.name,
              'nameAr': c.nameAr,
              'description': c.description,
              'descriptionAr': c.descriptionAr,
              'imageUrl': c.imageUrl,
              'isActive': c.isActive,
              'createdAt': c.createdAt,
              'updatedAt': c.updatedAt,
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> _exportCustomers() async {
    final customers = await _database.select(_database.customers).get();
    return customers
        .map((c) => {
              'id': c.id,
              'name': c.name,
              'email': c.email,
              'phone': c.phone,
              'crnNumber': c.crnNumber,
              'vatNumber': c.vatNumber,
              'saudiAddress': c.saudiAddress,
              'isActive': c.isActive,
              'createdAt': c.createdAt,
              'updatedAt': c.updatedAt,
            })
        .toList();
  }

  Future<Map<String, dynamic>> _exportSales() async {
    final sales = await _database.select(_database.sales).get();
    final saleItems = await _database.select(_database.saleItems).get();

    return {
      'sales': sales
          .map((s) => {
                'id': s.id,
                'invoiceNumber': s.invoiceNumber,
                'customerId': s.customerId,
                'cashierId': s.cashierId,
                'saleDate': s.saleDate,
                'subtotal': s.subtotal,
                'vatAmount': s.vatAmount,
                'totalAmount': s.totalAmount,
                'paidAmount': s.paidAmount,
                'changeAmount': s.changeAmount,
                'status': s.status,
                'paymentMethod': s.paymentMethod,
                'notes': s.notes,
                'isPrinted': s.isPrinted,
                'createdAt': s.createdAt,
                'updatedAt': s.updatedAt,
              })
          .toList(),
      'sale_items': saleItems
          .map((si) => {
                'id': si.id,
                'saleId': si.saleId,
                'productId': si.productId,
                'productName': si.productName,
                'unitPrice': si.unitPrice,
                'quantity': si.quantity,
                'vatRate': si.vatRate,
                'vatAmount': si.vatAmount,
                'subtotal': si.subtotal,
                'total': si.total,
              })
          .toList(),
    };
  }

  Future<List<Map<String, dynamic>>> _exportUsers() async {
    final users = await _database.select(_database.users).get();
    return users
        .map((u) => {
              'id': u.id,
              'username': u.username,
              // Note: We don't export passwords for security
              'fullName': u.fullName,
              'role': u.role,
              'isActive': u.isActive,
              'createdAt': u.createdAt,
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> _exportSettings() async {
    final companyInfo =
        await _database.select(_database.companyInfoTable).get();

    // Get app configuration from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final themeMode = prefs.getString('theme_mode') ?? 'light';
    final locale = prefs.getString('app_locale') ?? 'en';
    final printFormat = prefs.getString('print_format_config');
    final vatRate = prefs.getDouble('vat_rate') ?? 15.0;
    final vatIncludedInPrice = prefs.getBool('vat_included_in_price') ?? true;
    final vatEnabled = prefs.getBool('vat_enabled') ?? true;
    final colorScheme = prefs.getString('color_scheme');
    final syncUrl = prefs.getString('sync_url') ?? '';

    return companyInfo
        .map((ci) => {
              // Company Information
              'id': ci.id,
              'name': ci.name,
              'nameArabic': ci.nameArabic,
              'address': ci.address,
              'addressArabic': ci.addressArabic,
              'phone': ci.phone,
              'email': ci.email,
              'vatNumber': ci.vatNumber,
              'crnNumber': ci.crnNumber,
              'currency': ci.currency,
              'createdAt': ci.createdAt,
              'updatedAt': ci.updatedAt,

              // Application Configuration
              'appConfig': {
                // VAT Settings
                'vatRate': vatRate,
                'vatIncludedInPrice': vatIncludedInPrice,
                'vatEnabled': vatEnabled,

                // Theme Settings
                'themeMode': themeMode,
                'colorScheme': colorScheme != null ? json.decode(colorScheme) : null,

                // Language Settings
                'locale': locale,
                'language': locale == 'ar' ? 'Arabic' : 'English',

                // Print Format
                'printFormat': printFormat != null ? json.decode(printFormat) : null,

                // Sync Configuration
                'syncUrl': syncUrl,
              },
            })
        .toList();
  }

  // ============= IMPORT METHODS =============

  Future<int> _importProducts(List<dynamic> products) async {
    int count = 0;
    for (final productData in products) {
      try {
        final product = ProductsCompanion(
          id: drift.Value(productData['id'] as String? ?? _uuid.v4()),
          name: drift.Value(productData['name'] as String),
          nameAr: drift.Value(productData['nameAr'] as String?),
          description: drift.Value(productData['description'] as String?),
          descriptionAr: drift.Value(productData['descriptionAr'] as String?),
          barcode: drift.Value(productData['barcode'] as String),
          price: drift.Value((productData['price'] as num).toDouble()),
          cost: drift.Value((productData['cost'] as num).toDouble()),
          quantity: drift.Value(productData['quantity'] as int),
          categoryId: drift.Value(productData['categoryId'] as String),
          imageUrl: drift.Value(productData['imageUrl'] as String?),
          isActive: drift.Value(productData['isActive'] as bool? ?? true),
          vatRate:
              drift.Value((productData['vatRate'] as num?)?.toDouble() ?? 0.0),
          createdAt: drift.Value(productData['createdAt'] as String? ??
              DateTime.now().toIso8601String()),
          updatedAt: drift.Value(productData['updatedAt'] as String? ??
              DateTime.now().toIso8601String()),
          needsSync: const drift.Value(false),
        );

        await _database.into(_database.products).insert(
              product,
              mode: drift.InsertMode.insertOrReplace,
            );
        count++;
      } catch (e) {
        // Skip invalid entries
        continue;
      }
    }
    return count;
  }

  Future<int> _importCategories(List<dynamic> categories) async {
    int count = 0;
    for (final categoryData in categories) {
      try {
        final category = CategoriesTableCompanion(
          id: drift.Value(categoryData['id'] as String? ?? _uuid.v4()),
          name: drift.Value(categoryData['name'] as String),
          nameAr: drift.Value(categoryData['nameAr'] as String?),
          description: drift.Value(categoryData['description'] as String?),
          descriptionAr:
              drift.Value(categoryData['descriptionAr'] as String?),
          imageUrl: drift.Value(categoryData['imageUrl'] as String?),
          isActive: drift.Value(categoryData['isActive'] as bool? ?? true),
          createdAt: drift.Value(categoryData['createdAt'] as String? ??
              DateTime.now().toIso8601String()),
          updatedAt: drift.Value(categoryData['updatedAt'] as String? ??
              DateTime.now().toIso8601String()),
          needsSync: const drift.Value(false),
        );

        await _database.into(_database.categoriesTable).insert(
              category,
              mode: drift.InsertMode.insertOrReplace,
            );
        count++;
      } catch (e) {
        continue;
      }
    }
    return count;
  }

  Future<int> _importCustomers(List<dynamic> customers) async {
    int count = 0;
    for (final customerData in customers) {
      try {
        final customer = CustomersCompanion(
          id: drift.Value(customerData['id'] as String? ?? _uuid.v4()),
          name: drift.Value(customerData['name'] as String),
          email: drift.Value(customerData['email'] as String?),
          phone: drift.Value(customerData['phone'] as String?),
          crnNumber: drift.Value(customerData['crnNumber'] as String?),
          vatNumber: drift.Value(customerData['vatNumber'] as String?),
          saudiAddress: drift.Value(customerData['saudiAddress'] as String?),
          isActive: drift.Value(customerData['isActive'] as bool? ?? true),
          createdAt: drift.Value(customerData['createdAt'] as String? ??
              DateTime.now().toIso8601String()),
          updatedAt: drift.Value(customerData['updatedAt'] as String? ??
              DateTime.now().toIso8601String()),
          needsSync: const drift.Value(false),
        );

        await _database.into(_database.customers).insert(
              customer,
              mode: drift.InsertMode.insertOrReplace,
            );
        count++;
      } catch (e) {
        continue;
      }
    }
    return count;
  }

  Future<int> _importSales(
      List<dynamic> sales, List<dynamic> saleItems) async {
    int count = 0;

    for (final saleData in sales) {
      try {
        final sale = SalesCompanion(
          id: drift.Value(saleData['id'] as String? ?? _uuid.v4()),
          invoiceNumber: drift.Value(saleData['invoiceNumber'] as String),
          customerId: drift.Value(saleData['customerId'] as String?),
          cashierId: drift.Value(saleData['cashierId'] as String),
          saleDate: drift.Value(saleData['saleDate'] as String),
          subtotal: drift.Value((saleData['subtotal'] as num).toDouble()),
          vatAmount: drift.Value((saleData['vatAmount'] as num).toDouble()),
          totalAmount:
              drift.Value((saleData['totalAmount'] as num).toDouble()),
          paidAmount: drift.Value((saleData['paidAmount'] as num).toDouble()),
          changeAmount:
              drift.Value((saleData['changeAmount'] as num).toDouble()),
          status: drift.Value(saleData['status'] as String),
          paymentMethod: drift.Value(saleData['paymentMethod'] as String),
          notes: drift.Value(saleData['notes'] as String?),
          isPrinted: drift.Value(saleData['isPrinted'] as bool? ?? false),
          needsSync: const drift.Value(false),
          createdAt: drift.Value(saleData['createdAt'] as String? ??
              DateTime.now().toIso8601String()),
          updatedAt: drift.Value(saleData['updatedAt'] as String? ??
              DateTime.now().toIso8601String()),
        );

        await _database.into(_database.sales).insert(
              sale,
              mode: drift.InsertMode.insertOrReplace,
            );
        count++;
      } catch (e) {
        continue;
      }
    }

    // Import sale items
    for (final itemData in saleItems) {
      try {
        final item = SaleItemsCompanion(
          id: drift.Value(itemData['id'] as String? ?? _uuid.v4()),
          saleId: drift.Value(itemData['saleId'] as String),
          productId: drift.Value(itemData['productId'] as String),
          productName: drift.Value(itemData['productName'] as String),
          unitPrice: drift.Value((itemData['unitPrice'] as num).toDouble()),
          quantity: drift.Value(itemData['quantity'] as int),
          vatRate: drift.Value((itemData['vatRate'] as num).toDouble()),
          vatAmount: drift.Value((itemData['vatAmount'] as num).toDouble()),
          subtotal: drift.Value((itemData['subtotal'] as num).toDouble()),
          total: drift.Value((itemData['total'] as num).toDouble()),
        );

        await _database.into(_database.saleItems).insert(
              item,
              mode: drift.InsertMode.insertOrReplace,
            );
      } catch (e) {
        continue;
      }
    }

    return count;
  }

  Future<int> _importUsers(List<dynamic> users) async {
    int count = 0;
    for (final userData in users) {
      try {
        // Skip if user already exists (to prevent overwriting passwords)
        final existingUser = await (_database.select(_database.users)
              ..where((u) => u.id.equals(userData['id'] as String)))
            .getSingleOrNull();

        if (existingUser != null) {
          continue; // Skip existing users
        }

        final user = UsersCompanion(
          id: drift.Value(userData['id'] as String? ?? _uuid.v4()),
          username: drift.Value(userData['username'] as String),
          password: drift.Value('changeme'), // Default password for imported users
          fullName: drift.Value(userData['fullName'] as String),
          role: drift.Value(userData['role'] as String),
          isActive: drift.Value(userData['isActive'] as bool? ?? true),
          createdAt: drift.Value(userData['createdAt'] as String? ??
              DateTime.now().toIso8601String()),
          lastLoginAt: const drift.Value.absent(),
        );

        await _database.into(_database.users).insert(user);
        count++;
      } catch (e) {
        continue;
      }
    }
    return count;
  }

  Future<int> _importSettings(List<dynamic> settings) async {
    int count = 0;
    for (final settingData in settings) {
      try {
        final companySetting = CompanyInfoTableCompanion(
          id: drift.Value(settingData['id'] as String? ?? _uuid.v4()),
          name: drift.Value(settingData['name'] as String),
          nameArabic: drift.Value(settingData['nameArabic'] as String),
          address: drift.Value(settingData['address'] as String),
          addressArabic: drift.Value(settingData['addressArabic'] as String),
          phone: drift.Value(settingData['phone'] as String),
          email: drift.Value(settingData['email'] as String?),
          vatNumber: drift.Value(settingData['vatNumber'] as String),
          crnNumber: drift.Value(settingData['crnNumber'] as String),
          logoPath: const drift.Value.absent(),
          currency: drift.Value(settingData['currency'] as String? ?? 'SAR'),
          createdAt: drift.Value(settingData['createdAt'] as String? ??
              DateTime.now().toIso8601String()),
          updatedAt: drift.Value(settingData['updatedAt'] as String? ??
              DateTime.now().toIso8601String()),
        );

        await _database.into(_database.companyInfoTable).insert(
              companySetting,
              mode: drift.InsertMode.insertOrReplace,
            );
        count++;

        // Apply app configuration if present in the imported data
        if (settingData.containsKey('appConfig') && settingData['appConfig'] != null) {
          final appConfig = settingData['appConfig'] as Map<String, dynamic>;
          final prefs = await SharedPreferences.getInstance();

          // Apply VAT settings
          if (appConfig.containsKey('vatRate')) {
            await prefs.setDouble('vat_rate', (appConfig['vatRate'] as num).toDouble());
          }
          if (appConfig.containsKey('vatIncludedInPrice')) {
            await prefs.setBool('vat_included_in_price', appConfig['vatIncludedInPrice'] as bool);
          }
          if (appConfig.containsKey('vatEnabled')) {
            await prefs.setBool('vat_enabled', appConfig['vatEnabled'] as bool);
          }

          // Apply theme settings
          if (appConfig.containsKey('themeMode')) {
            await prefs.setString('theme_mode', appConfig['themeMode'] as String);
          }
          if (appConfig.containsKey('colorScheme') && appConfig['colorScheme'] != null) {
            await prefs.setString('color_scheme', json.encode(appConfig['colorScheme']));
          }

          // Apply language settings
          if (appConfig.containsKey('locale')) {
            await prefs.setString('app_locale', appConfig['locale'] as String);
          }

          // Apply print format
          if (appConfig.containsKey('printFormat') && appConfig['printFormat'] != null) {
            await prefs.setString('print_format_config', json.encode(appConfig['printFormat']));
          }

          // Apply sync URL
          if (appConfig.containsKey('syncUrl')) {
            await prefs.setString('sync_url', appConfig['syncUrl'] as String);
          }
        }

      } catch (e) {
        continue;
      }
    }
    return count;
  }

  // ============= FILE OPERATIONS =============

  /// Generate a descriptive filename based on data types being exported
  String _generateFilename(List<DataType> dataTypes, {bool includeTimestamp = true}) {
    final now = DateTime.now();
    final date = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final time = '${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}';

    String typeName;
    if (dataTypes.isEmpty) {
      typeName = 'empty';
    } else if (dataTypes.length == 1) {
      typeName = _dataTypeToString(dataTypes.first);
    } else if (dataTypes.length >= 6) {
      typeName = 'all_data';
    } else {
      // Use first 2-3 types with "and_more"
      final firstTypes = dataTypes.take(2).map(_dataTypeToString).join('_');
      typeName = '${firstTypes}_and_more';
    }

    if (includeTimestamp) {
      return '${typeName}_${date}_$time';
    } else {
      return typeName;
    }
  }

  /// Convert DataType enum to string for filename
  String _dataTypeToString(DataType type) {
    switch (type) {
      case DataType.products:
        return 'products';
      case DataType.categories:
        return 'categories';
      case DataType.customers:
        return 'customers';
      case DataType.sales:
        return 'sales';
      case DataType.users:
        return 'users';
      case DataType.settings:
        return 'settings';
      case DataType.all:
        return 'all_data';
    }
  }

  /// Get the Downloads directory with platform-specific handling
  Future<Directory> _getDownloadsDirectory() async {
    if (kIsWeb) {
      // For web, this shouldn't be called, but return a dummy directory
      throw UnsupportedError('File system not available on web');
    }

    if (Platform.isAndroid) {
      // For Android, try to get external storage downloads directory
      try {
        final directory = Directory('/storage/emulated/0/Download');
        if (await directory.exists()) {
          return directory;
        }
      } catch (e) {
        // Fallback to app-specific external storage
      }
      // Fallback to external storage directory
      final directory = await getExternalStorageDirectory();
      return directory ?? await getApplicationDocumentsDirectory();
    } else if (Platform.isIOS) {
      // For iOS, use application documents directory (Downloads not accessible)
      return await getApplicationDocumentsDirectory();
    }

    // Default fallback
    return await getApplicationDocumentsDirectory();
  }

  /// Get company name from database
  Future<String> _getCompanyName() async {
    try {
      final companyInfo = await _database.getCompanyInfo();
      if (companyInfo != null && companyInfo.name.isNotEmpty) {
        // Clean company name for folder name (remove special characters)
        return companyInfo.name
            .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
            .trim();
      }
    } catch (e) {
      // Ignore error and use default
    }
    return 'RetailManagement';
  }

  /// Create company-specific export directory
  Future<Directory> _createCompanyExportDirectory() async {
    final downloadsDir = await _getDownloadsDirectory();
    final companyName = await _getCompanyName();

    // Create company folder in Downloads
    final companyDir = Directory('${downloadsDir.path}/$companyName');
    if (!await companyDir.exists()) {
      await companyDir.create(recursive: true);
    }

    return companyDir;
  }

  Future<String> _saveJsonFile(Map<String, dynamic> data, List<DataType> dataTypes) async {
    final fileName = '${_generateFilename(dataTypes)}.json';
    final jsonString = json.encode(data);

    if (kIsWeb) {
      // Web platform: Trigger browser download
      _downloadFileWeb(jsonString, fileName, 'application/json');
      return 'Downloaded: $fileName';
    } else {
      // Mobile/Desktop platform: Save to file system
      final directory = await _createCompanyExportDirectory();
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsString(jsonString);

      return filePath;
    }
  }

  Future<String> _saveCsvFiles(Map<String, dynamic> data, List<DataType> dataTypes) async {
    final folderName = _generateFilename(dataTypes);

    if (kIsWeb) {
      // Web platform: For CSV, we'll create a ZIP or download first CSV
      // For simplicity, let's download the first data type as CSV
      if (data.isNotEmpty) {
        final firstEntry = data.entries.first;
        if (firstEntry.value is List && (firstEntry.value as List).isNotEmpty) {
          final csvData = _convertToCSV(firstEntry.value as List<Map<String, dynamic>>);
          final fileName = '${folderName}_${firstEntry.key}.csv';
          _downloadFileWeb(csvData, fileName, 'text/csv');
          return 'Downloaded: $fileName';
        }
      }
      return 'Downloaded: CSV files';
    } else {
      // Mobile/Desktop platform: Save to file system
      final directory = await _createCompanyExportDirectory();

      // Create a subdirectory for this export
      final exportDir = Directory('${directory.path}/$folderName');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      // Save each data type as a separate CSV file
      for (final entry in data.entries) {
        if (entry.value is List && (entry.value as List).isNotEmpty) {
          final csvData = _convertToCSV(entry.value as List<Map<String, dynamic>>);
          final file = File('${exportDir.path}/${entry.key}.csv');
          await file.writeAsString(csvData);
        }
      }

      return exportDir.path;
    }
  }

  /// Download file on web platform using browser download
  void _downloadFileWeb(String content, String filename, String mimeType) {
    if (kIsWeb) {
      // Use the imported web file download function
      downloadFileOnWeb(content, filename, mimeType);
    }
  }

  String _convertToCSV(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return '';

    final headers = data.first.keys.toList();
    final rows = data.map((row) => headers.map((key) => row[key]).toList()).toList();

    return const ListToCsvConverter().convert([headers, ...rows]);
  }

  Future<Map<String, dynamic>> _parseCsvFile(
      String filePath, List<DataType> dataTypes) async {
    // This is a simplified implementation
    // In a real-world scenario, you'd need more sophisticated CSV parsing
    final file = File(filePath);
    final content = await file.readAsString();
    return _parseCsvFromContent(content, dataTypes);
  }

  /// Parse CSV from content string (used for web platform)
  Future<Map<String, dynamic>> _parseCsvFromContent(
      String content, List<DataType> dataTypes) async {
    final csv = const CsvToListConverter().convert(content);

    if (csv.isEmpty) {
      return {};
    }

    final headers = csv.first.map((h) => h.toString()).toList();
    final rows = csv.sublist(1);

    final List<Map<String, dynamic>> data = rows.map((row) {
      final Map<String, dynamic> rowMap = {};
      for (int i = 0; i < headers.length && i < row.length; i++) {
        rowMap[headers[i]] = row[i];
      }
      return rowMap;
    }).toList();

    // Determine data type from file name or content
    // This is a simplified approach
    return {'products': data}; // Adjust based on actual file
  }
}
