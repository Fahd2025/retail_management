import 'package:drift/drift.dart';
import '../models/user.dart' as models;
import '../models/product.dart' as models;
import '../models/customer.dart' as models;
import '../models/sale.dart' as models;
import '../models/company_info.dart' as models;
import '../models/category.dart' as models;
import 'connection/connection.dart' as impl;

part 'drift_database.g.dart';

// Users table
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get username => text()();
  TextColumn get password => text()();
  TextColumn get fullName => text()();
  TextColumn get role => text()();
  BoolColumn get isActive => boolean()();
  TextColumn get createdAt => text()();
  TextColumn get lastLoginAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Categories table
class CategoriesTable extends Table {
  @override
  String get tableName => 'categories';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get nameAr => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get descriptionAr => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  BoolColumn get isActive => boolean()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  BoolColumn get needsSync => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}

// Products table
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get nameAr => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get descriptionAr => text().nullable()();
  TextColumn get barcode => text()();
  RealColumn get price => real()();
  RealColumn get cost => real()();
  IntColumn get quantity => integer()();
  TextColumn get categoryId => text().references(CategoriesTable, #id)();
  TextColumn get imageUrl => text().nullable()();
  BoolColumn get isActive => boolean()();
  RealColumn get vatRate => real()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  BoolColumn get needsSync => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}

// Customers table
class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get crnNumber => text().nullable()();
  TextColumn get vatNumber => text().nullable()();
  TextColumn get saudiAddress => text().nullable()();
  BoolColumn get isActive => boolean()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  BoolColumn get needsSync => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}

// Sales table
class Sales extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceNumber => text()();
  TextColumn get customerId => text().nullable()();
  TextColumn get cashierId => text()();
  TextColumn get saleDate => text()();
  RealColumn get subtotal => real()();
  RealColumn get vatAmount => real()();
  RealColumn get totalAmount => real()();
  RealColumn get paidAmount => real()();
  RealColumn get changeAmount => real()();
  TextColumn get status => text()();
  TextColumn get paymentMethod => text()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isPrinted => boolean()();
  BoolColumn get needsSync => boolean()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

// Sale Items table
class SaleItems extends Table {
  TextColumn get id => text()();
  TextColumn get saleId =>
      text().references(Sales, #id, onDelete: KeyAction.cascade)();
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  RealColumn get unitPrice => real()();
  IntColumn get quantity => integer()();
  RealColumn get vatRate => real()();
  RealColumn get vatAmount => real()();
  RealColumn get subtotal => real()();
  RealColumn get total => real()();

  @override
  Set<Column> get primaryKey => {id};
}

// Company Info table
class CompanyInfoTable extends Table {
  @override
  String get tableName => 'company_info';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get nameArabic => text()();
  TextColumn get address => text()();
  TextColumn get addressArabic => text()();
  TextColumn get phone => text()();
  TextColumn get email => text().nullable()();
  TextColumn get vatNumber => text()();
  TextColumn get crnNumber => text()();
  TextColumn get logoPath => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  Users,
  CategoriesTable,
  Products,
  Customers,
  Sales,
  SaleItems,
  CompanyInfoTable
])
class AppDatabase extends _$AppDatabase {
  // Singleton pattern
  static AppDatabase? _instance;

  AppDatabase._internal() : super(impl.connect());

  factory AppDatabase() {
    _instance ??= AppDatabase._internal();
    return _instance!;
  }

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();

          // Create indexes
          await customStatement(
              'CREATE INDEX idx_products_barcode ON products(barcode)');
          await customStatement(
              'CREATE INDEX idx_products_category_id ON products(category_id)');
          await customStatement(
              'CREATE INDEX idx_sales_date ON sales(sale_date)');
          await customStatement(
              'CREATE INDEX idx_sales_cashier ON sales(cashier_id)');
          await customStatement(
              'CREATE INDEX idx_sale_items_sale ON sale_items(sale_id)');

          // Seed initial data
          await _seedInitialData();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from == 1 && to == 2) {
            // Create categories table
            await m.createTable(categoriesTable);

            // Add default categories
            await _seedInitialCategories();

            // Add categoryId column to products
            await m.addColumn(products, products.categoryId);

            // Migrate existing products to use the first category as default
            final defaultCategory =
                await (select(categoriesTable)..limit(1)).getSingleOrNull();
            if (defaultCategory != null) {
              await customStatement(
                'UPDATE products SET category_id = ? WHERE category_id IS NULL',
                [defaultCategory.id],
              );
            }

            // Update index
            await customStatement(
                'CREATE INDEX idx_products_category_id ON products(category_id)');
          }

          if (from <= 2 && to >= 3) {
            // Add Arabic fields to products table
            await m.addColumn(products, products.nameAr);
            await m.addColumn(products, products.descriptionAr);

            // Add Arabic fields to categories table
            await m.addColumn(categoriesTable, categoriesTable.nameAr);
            await m.addColumn(categoriesTable, categoriesTable.descriptionAr);
          }
        },
      );

  // User operations
  Future<models.User> createUser(models.User user) async {
    await into(users).insert(UsersCompanion(
      id: Value(user.id),
      username: Value(user.username),
      password: Value(user.password),
      fullName: Value(user.fullName),
      role: Value(user.role.toString().split('.').last),
      isActive: Value(user.isActive),
      createdAt: Value(user.createdAt.toIso8601String()),
      lastLoginAt: Value(user.lastLoginAt?.toIso8601String()),
    ));
    return user;
  }

  Future<models.User?> getUserByUsername(String username) async {
    final query = select(users)..where((tbl) => tbl.username.equals(username));
    final result = await query.getSingleOrNull();
    if (result == null) return null;
    return _userFromRow(result);
  }

  Future<List<models.User>> getAllUsers() async {
    final result = await select(users).get();
    return result.map((row) => _userFromRow(row)).toList();
  }

  Future<int> updateUser(models.User user) async {
    return (update(users)..where((tbl) => tbl.id.equals(user.id))).write(
      UsersCompanion(
        username: Value(user.username),
        password: Value(user.password),
        fullName: Value(user.fullName),
        role: Value(user.role.toString().split('.').last),
        isActive: Value(user.isActive),
        lastLoginAt: Value(user.lastLoginAt?.toIso8601String()),
      ),
    );
  }

  Future<int> deleteUser(String id) async {
    return (delete(users)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<models.User?> getUserById(String id) async {
    final query = select(users)..where((tbl) => tbl.id.equals(id));
    final result = await query.getSingleOrNull();
    if (result == null) return null;
    return _userFromRow(result);
  }

  Future<Map<String, dynamic>> getUserSalesStats(String userId) async {
    final query = select(sales)..where((tbl) => tbl.cashierId.equals(userId));
    final userSales = await query.get();

    int invoiceCount = userSales.length;
    double totalSales = 0.0;

    for (var sale in userSales) {
      totalSales += sale.totalAmount;
    }

    return {
      'invoiceCount': invoiceCount,
      'totalSales': totalSales,
    };
  }

  // Product operations
  Future<models.Product> createProduct(models.Product product) async {
    await into(products).insert(ProductsCompanion(
      id: Value(product.id),
      name: Value(product.name),
      nameAr: Value(product.nameAr),
      description: Value(product.description),
      descriptionAr: Value(product.descriptionAr),
      barcode: Value(product.barcode),
      price: Value(product.price),
      cost: Value(product.cost),
      quantity: Value(product.quantity),
      categoryId: Value(product.category),
      imageUrl: Value(product.imageUrl),
      isActive: Value(product.isActive),
      vatRate: Value(product.vatRate),
      createdAt: Value(product.createdAt.toIso8601String()),
      updatedAt: Value(product.updatedAt.toIso8601String()),
      needsSync: Value(product.needsSync),
    ));
    return product;
  }

  Future<models.Product?> getProduct(String id) async {
    final query = select(products)..where((tbl) => tbl.id.equals(id));
    final result = await query.getSingleOrNull();
    if (result == null) return null;
    return _productFromRow(result);
  }

  Future<models.Product?> getProductByBarcode(String barcode) async {
    final query = select(products)..where((tbl) => tbl.barcode.equals(barcode));
    final result = await query.getSingleOrNull();
    if (result == null) return null;
    return _productFromRow(result);
  }

  Future<List<models.Product>> getAllProducts({bool activeOnly = false}) async {
    final query = select(products)
      ..orderBy([(t) => OrderingTerm(expression: t.name)]);
    if (activeOnly) {
      query.where((tbl) => tbl.isActive.equals(true));
    }
    final result = await query.get();
    return result.map((row) => _productFromRow(row)).toList();
  }

  Future<List<models.Product>> getProductsByCategory(String categoryId) async {
    final query = select(products)
      ..where((tbl) =>
          tbl.categoryId.equals(categoryId) & tbl.isActive.equals(true))
      ..orderBy([(t) => OrderingTerm(expression: t.name)]);
    final result = await query.get();
    return result.map((row) => _productFromRow(row)).toList();
  }

  Future<List<String>> getProductCategories() async {
    final query = selectOnly(products, distinct: true)
      ..addColumns([products.categoryId])
      ..where(products.isActive.equals(true))
      ..orderBy([OrderingTerm(expression: products.categoryId)]);
    final result = await query.get();
    return result.map((row) => row.read(products.categoryId)!).toList();
  }

  Future<int> updateProduct(models.Product product) async {
    return (update(products)..where((tbl) => tbl.id.equals(product.id))).write(
      ProductsCompanion(
        name: Value(product.name),
        nameAr: Value(product.nameAr),
        description: Value(product.description),
        descriptionAr: Value(product.descriptionAr),
        barcode: Value(product.barcode),
        price: Value(product.price),
        cost: Value(product.cost),
        quantity: Value(product.quantity),
        categoryId: Value(product.category),
        imageUrl: Value(product.imageUrl),
        isActive: Value(product.isActive),
        vatRate: Value(product.vatRate),
        updatedAt: Value(DateTime.now().toIso8601String()),
        needsSync: Value(product.needsSync),
      ),
    );
  }

  Future<int> deleteProduct(String id) async {
    return (delete(products)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Customer operations
  Future<models.Customer> createCustomer(models.Customer customer) async {
    await into(customers).insert(CustomersCompanion(
      id: Value(customer.id),
      name: Value(customer.name),
      email: Value(customer.email),
      phone: Value(customer.phone),
      crnNumber: Value(customer.crnNumber),
      vatNumber: Value(customer.vatNumber),
      saudiAddress: Value(customer.saudiAddress?.toString()),
      isActive: Value(customer.isActive),
      createdAt: Value(customer.createdAt.toIso8601String()),
      updatedAt: Value(customer.updatedAt.toIso8601String()),
      needsSync: Value(customer.needsSync),
    ));
    return customer;
  }

  Future<models.Customer?> getCustomer(String id) async {
    final query = select(customers)..where((tbl) => tbl.id.equals(id));
    final result = await query.getSingleOrNull();
    if (result == null) return null;
    return _customerFromRow(result);
  }

  Future<List<models.Customer>> getAllCustomers(
      {bool activeOnly = false}) async {
    final query = select(customers)
      ..orderBy([(t) => OrderingTerm(expression: t.name)]);
    if (activeOnly) {
      query.where((tbl) => tbl.isActive.equals(true));
    }
    final result = await query.get();
    return result.map((row) => _customerFromRow(row)).toList();
  }

  Future<int> updateCustomer(models.Customer customer) async {
    return (update(customers)..where((tbl) => tbl.id.equals(customer.id)))
        .write(
      CustomersCompanion(
        name: Value(customer.name),
        email: Value(customer.email),
        phone: Value(customer.phone),
        crnNumber: Value(customer.crnNumber),
        vatNumber: Value(customer.vatNumber),
        saudiAddress: Value(customer.saudiAddress?.toString()),
        isActive: Value(customer.isActive),
        updatedAt: Value(DateTime.now().toIso8601String()),
        needsSync: Value(customer.needsSync),
      ),
    );
  }

  Future<int> deleteCustomer(String id) async {
    return (delete(customers)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Sale operations
  Future<models.Sale> createSale(models.Sale sale) async {
    await transaction(() async {
      await into(sales).insert(SalesCompanion(
        id: Value(sale.id),
        invoiceNumber: Value(sale.invoiceNumber),
        customerId: Value(sale.customerId),
        cashierId: Value(sale.cashierId),
        saleDate: Value(sale.saleDate.toIso8601String()),
        subtotal: Value(sale.subtotal),
        vatAmount: Value(sale.vatAmount),
        totalAmount: Value(sale.totalAmount),
        paidAmount: Value(sale.paidAmount),
        changeAmount: Value(sale.changeAmount),
        status: Value(sale.status.toString().split('.').last),
        paymentMethod: Value(sale.paymentMethod.toString().split('.').last),
        notes: Value(sale.notes),
        isPrinted: Value(sale.isPrinted),
        needsSync: Value(sale.needsSync),
        createdAt: Value(sale.createdAt.toIso8601String()),
        updatedAt: Value(sale.updatedAt.toIso8601String()),
      ));

      for (var item in sale.items) {
        await into(saleItems).insert(SaleItemsCompanion(
          id: Value(item.id),
          saleId: Value(sale.id),
          productId: Value(item.productId),
          productName: Value(item.productName),
          unitPrice: Value(item.unitPrice),
          quantity: Value(item.quantity),
          vatRate: Value(item.vatRate),
          vatAmount: Value(item.vatAmount),
          subtotal: Value(item.subtotal),
          total: Value(item.total),
        ));
      }
    });
    return sale;
  }

  Future<models.Sale?> getSale(String id) async {
    final saleQuery = select(sales)..where((tbl) => tbl.id.equals(id));
    final saleRow = await saleQuery.getSingleOrNull();
    if (saleRow == null) return null;

    final itemsQuery = select(saleItems)..where((tbl) => tbl.saleId.equals(id));
    final itemRows = await itemsQuery.get();
    final items = itemRows.map((row) => _saleItemFromRow(row)).toList();

    return _saleFromRow(saleRow, items);
  }

  Future<List<models.Sale>> getAllSales() async {
    final saleRows = await (select(sales)
          ..orderBy([
            (t) => OrderingTerm(expression: t.saleDate, mode: OrderingMode.desc)
          ]))
        .get();

    final allSales = <models.Sale>[];
    for (var saleRow in saleRows) {
      final itemsQuery = select(saleItems)
        ..where((tbl) => tbl.saleId.equals(saleRow.id));
      final itemRows = await itemsQuery.get();
      final items = itemRows.map((row) => _saleItemFromRow(row)).toList();
      allSales.add(_saleFromRow(saleRow, items));
    }
    return allSales;
  }

  Future<List<models.Sale>> getSalesByDateRange(
      DateTime start, DateTime end) async {
    final saleRows = await (select(sales)
          ..where((tbl) =>
              tbl.saleDate.isBiggerOrEqualValue(start.toIso8601String()) &
              tbl.saleDate.isSmallerOrEqualValue(end.toIso8601String()))
          ..orderBy([
            (t) => OrderingTerm(expression: t.saleDate, mode: OrderingMode.desc)
          ]))
        .get();

    final allSales = <models.Sale>[];
    for (var saleRow in saleRows) {
      final itemsQuery = select(saleItems)
        ..where((tbl) => tbl.saleId.equals(saleRow.id));
      final itemRows = await itemsQuery.get();
      final items = itemRows.map((row) => _saleItemFromRow(row)).toList();
      allSales.add(_saleFromRow(saleRow, items));
    }
    return allSales;
  }

  Future<List<models.Sale>> getSalesByCustomer(String customerId,
      {DateTime? startDate, DateTime? endDate}) async {
    var query = select(sales)
      ..where((tbl) => tbl.customerId.equals(customerId));

    if (startDate != null && endDate != null) {
      query = select(sales)
        ..where((tbl) =>
            tbl.customerId.equals(customerId) &
            tbl.saleDate.isBiggerOrEqualValue(startDate.toIso8601String()) &
            tbl.saleDate.isSmallerOrEqualValue(endDate.toIso8601String()));
    }

    query = query
      ..orderBy([
        (t) => OrderingTerm(expression: t.saleDate, mode: OrderingMode.desc)
      ]);

    final saleRows = await query.get();

    final allSales = <models.Sale>[];
    for (var saleRow in saleRows) {
      final itemsQuery = select(saleItems)
        ..where((tbl) => tbl.saleId.equals(saleRow.id));
      final itemRows = await itemsQuery.get();
      final items = itemRows.map((row) => _saleItemFromRow(row)).toList();
      allSales.add(_saleFromRow(saleRow, items));
    }
    return allSales;
  }

  Future<Map<String, dynamic>> getCustomerSalesStatistics(
      String customerId) async {
    final salesQuery = select(sales)
      ..where((tbl) => tbl.customerId.equals(customerId));
    final salesList = await salesQuery.get();

    final invoiceCount = salesList.length;
    final totalAmount =
        salesList.fold<double>(0, (sum, sale) => sum + sale.totalAmount);

    return {
      'invoiceCount': invoiceCount,
      'totalAmount': totalAmount,
    };
  }

  // Dashboard Analytics Queries

  /// Get best-selling products within a date range
  Future<List<Map<String, dynamic>>> getBestSellingProducts(
    DateTime start,
    DateTime end, {
    int limit = 10,
  }) async {
    // Query to get product sales statistics
    final query = await customSelect(
      '''
      SELECT
        si.product_id,
        si.product_name,
        p.image_url as product_image,
        p.category_id as category,
        SUM(si.quantity) as total_quantity_sold,
        SUM(si.total) as total_revenue,
        COUNT(DISTINCT si.sale_id) as transaction_count
      FROM sale_items si
      INNER JOIN sales s ON si.sale_id = s.id
      LEFT JOIN products p ON si.product_id = p.id
      WHERE s.sale_date >= ? AND s.sale_date <= ?
        AND s.status = 'completed'
      GROUP BY si.product_id, si.product_name, p.image_url, p.category_id
      ORDER BY total_revenue DESC
      LIMIT ?
      ''',
      variables: [
        Variable(start.toIso8601String()),
        Variable(end.toIso8601String()),
        Variable(limit),
      ],
      readsFrom: {saleItems, sales, products},
    ).get();

    return query.map((row) => row.data).toList();
  }

  /// Get products with low stock (quantity <= 10)
  Future<List<Map<String, dynamic>>> getLowStockProducts({
    int threshold = 10,
    int limit = 20,
  }) async {
    final query = select(products)
      ..where((tbl) => tbl.quantity.isSmallerOrEqualValue(threshold))
      ..orderBy([(t) => OrderingTerm(expression: t.quantity)])
      ..limit(limit);

    final result = await query.get();

    return result.map((row) {
      return {
        'productId': row.id,
        'productName': row.name,
        'productImage': row.imageUrl,
        'currentQuantity': row.quantity.toDouble(),
        'reorderLevel': threshold.toDouble(),
        'category': row.categoryId,
        'isActive': row.isActive,
      };
    }).toList();
  }

  /// Get daily sales data for a date range (for line/bar charts)
  Future<List<Map<String, dynamic>>> getDailySalesData(
    DateTime start,
    DateTime end,
  ) async {
    final query = await customSelect(
      '''
      SELECT
        DATE(sale_date) as date,
        SUM(total_amount) as total_sales,
        SUM(vat_amount) as total_vat,
        COUNT(*) as invoice_count
      FROM sales
      WHERE sale_date >= ? AND sale_date <= ?
        AND status = 'completed'
      GROUP BY DATE(sale_date)
      ORDER BY DATE(sale_date) ASC
      ''',
      variables: [
        Variable(start.toIso8601String()),
        Variable(end.toIso8601String()),
      ],
      readsFrom: {sales},
    ).get();

    return query.map((row) => row.data).toList();
  }

  /// Get sales data by category (for pie charts)
  Future<List<Map<String, dynamic>>> getCategorySalesData(
    DateTime start,
    DateTime end,
  ) async {
    final query = await customSelect(
      '''
      SELECT
        c.name as category_name,
        SUM(si.total) as total_revenue,
        COUNT(DISTINCT si.product_id) as product_count,
        COUNT(DISTINCT si.sale_id) as transaction_count
      FROM sale_items si
      INNER JOIN sales s ON si.sale_id = s.id
      INNER JOIN products p ON si.product_id = p.id
      INNER JOIN categories c ON p.category_id = c.id
      WHERE s.sale_date >= ? AND s.sale_date <= ?
        AND s.status = 'completed'
      GROUP BY c.name
      ORDER BY total_revenue DESC
      ''',
      variables: [
        Variable(start.toIso8601String()),
        Variable(end.toIso8601String()),
      ],
      readsFrom: {saleItems, sales, products, categoriesTable},
    ).get();

    return query.map((row) => row.data).toList();
  }

  /// Get comprehensive dashboard statistics for a date range
  Future<Map<String, dynamic>> getDashboardStatistics(
    DateTime start,
    DateTime end,
  ) async {
    // Get product counts
    final totalProductsQuery = select(products);
    final activeProductsQuery = select(products)
      ..where((tbl) => tbl.isActive.equals(true));

    final totalProductsCount = await totalProductsQuery.get();
    final activeProductsCount = await activeProductsQuery.get();

    // Get customer counts
    final totalCustomersQuery = select(customers);
    final activeCustomersQuery = select(customers)
      ..where((tbl) => tbl.isActive.equals(true));

    final totalCustomersCount = await totalCustomersQuery.get();
    final activeCustomersCount = await activeCustomersQuery.get();

    // Get sales statistics
    final salesQuery = select(sales)
      ..where((tbl) =>
          tbl.saleDate.isBiggerOrEqualValue(start.toIso8601String()) &
          tbl.saleDate.isSmallerOrEqualValue(end.toIso8601String()));

    final salesList = await salesQuery.get();

    final totalInvoices = salesList.length;
    final completedInvoices =
        salesList.where((s) => s.status == 'completed').length;
    final returnedInvoices =
        salesList.where((s) => s.status == 'returned').length;
    final cancelledInvoices =
        salesList.where((s) => s.status == 'cancelled').length;

    final completedSales =
        salesList.where((s) => s.status == 'completed').toList();
    final totalSales =
        completedSales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);
    final totalVat =
        completedSales.fold<double>(0, (sum, sale) => sum + sale.vatAmount);

    return {
      'totalProducts': totalProductsCount.length,
      'activeProducts': activeProductsCount.length,
      'totalSales': totalSales,
      'totalVat': totalVat,
      'totalCustomers': totalCustomersCount.length,
      'activeCustomers': activeCustomersCount.length,
      'totalInvoices': totalInvoices,
      'completedInvoices': completedInvoices,
      'returnedInvoices': returnedInvoices,
      'cancelledInvoices': cancelledInvoices,
    };
  }

  Future<int> updateSale(models.Sale sale) async {
    return (update(sales)..where((tbl) => tbl.id.equals(sale.id))).write(
      SalesCompanion(
        status: Value(sale.status.toString().split('.').last),
        isPrinted: Value(sale.isPrinted),
        updatedAt: Value(DateTime.now().toIso8601String()),
        needsSync: Value(sale.needsSync),
      ),
    );
  }

  // Company Info operations
  Future<models.CompanyInfo> createOrUpdateCompanyInfo(
      models.CompanyInfo info) async {
    final existing =
        await (select(companyInfoTable)..limit(1)).getSingleOrNull();

    if (existing == null) {
      await into(companyInfoTable).insert(CompanyInfoTableCompanion(
        id: Value(info.id),
        name: Value(info.name),
        nameArabic: Value(info.nameArabic),
        address: Value(info.address),
        addressArabic: Value(info.addressArabic),
        phone: Value(info.phone),
        email: Value(info.email),
        vatNumber: Value(info.vatNumber),
        crnNumber: Value(info.crnNumber),
        logoPath: Value(info.logoPath),
        createdAt: Value(info.createdAt.toIso8601String()),
        updatedAt: Value(info.updatedAt.toIso8601String()),
      ));
    } else {
      await (update(companyInfoTable)
            ..where((tbl) => tbl.id.equals(existing.id)))
          .write(
        CompanyInfoTableCompanion(
          name: Value(info.name),
          nameArabic: Value(info.nameArabic),
          address: Value(info.address),
          addressArabic: Value(info.addressArabic),
          phone: Value(info.phone),
          email: Value(info.email),
          vatNumber: Value(info.vatNumber),
          crnNumber: Value(info.crnNumber),
          logoPath: Value(info.logoPath),
          updatedAt: Value(DateTime.now().toIso8601String()),
        ),
      );
    }
    return info;
  }

  Future<models.CompanyInfo?> getCompanyInfo() async {
    final result = await (select(companyInfoTable)..limit(1)).getSingleOrNull();
    if (result == null) return null;
    return _companyInfoFromRow(result);
  }

  // Sync operations
  Future<List<models.Product>> getProductsNeedingSync() async {
    final query = select(products)..where((tbl) => tbl.needsSync.equals(true));
    final result = await query.get();
    return result.map((row) => _productFromRow(row)).toList();
  }

  Future<List<models.Customer>> getCustomersNeedingSync() async {
    final query = select(customers)..where((tbl) => tbl.needsSync.equals(true));
    final result = await query.get();
    return result.map((row) => _customerFromRow(row)).toList();
  }

  Future<List<models.Sale>> getSalesNeedingSync() async {
    final saleRows =
        await (select(sales)..where((tbl) => tbl.needsSync.equals(true))).get();

    final allSales = <models.Sale>[];
    for (var saleRow in saleRows) {
      final itemsQuery = select(saleItems)
        ..where((tbl) => tbl.saleId.equals(saleRow.id));
      final itemRows = await itemsQuery.get();
      final items = itemRows.map((row) => _saleItemFromRow(row)).toList();
      allSales.add(_saleFromRow(saleRow, items));
    }
    return allSales;
  }

  // Helper methods to convert from Drift rows to model objects
  models.User _userFromRow(User row) {
    return models.User(
      id: row.id,
      username: row.username,
      password: row.password,
      fullName: row.fullName,
      role:
          row.role == 'admin' ? models.UserRole.admin : models.UserRole.cashier,
      isActive: row.isActive,
      createdAt: DateTime.parse(row.createdAt),
      lastLoginAt:
          row.lastLoginAt != null ? DateTime.parse(row.lastLoginAt!) : null,
    );
  }

  models.Product _productFromRow(Product row) {
    return models.Product(
      id: row.id,
      name: row.name,
      nameAr: row.nameAr,
      description: row.description,
      descriptionAr: row.descriptionAr,
      barcode: row.barcode,
      price: row.price,
      cost: row.cost,
      quantity: row.quantity,
      category: row.categoryId,
      imageUrl: row.imageUrl,
      isActive: row.isActive,
      vatRate: row.vatRate,
      createdAt: DateTime.parse(row.createdAt),
      updatedAt: DateTime.parse(row.updatedAt),
      needsSync: row.needsSync,
    );
  }

  models.Customer _customerFromRow(Customer row) {
    return models.Customer(
      id: row.id,
      name: row.name,
      email: row.email,
      phone: row.phone,
      crnNumber: row.crnNumber,
      vatNumber: row.vatNumber,
      saudiAddress: row.saudiAddress != null
          ? models.SaudiAddress.fromString(row.saudiAddress!)
          : null,
      isActive: row.isActive,
      createdAt: DateTime.parse(row.createdAt),
      updatedAt: DateTime.parse(row.updatedAt),
      needsSync: row.needsSync,
    );
  }

  models.SaleItem _saleItemFromRow(SaleItem row) {
    return models.SaleItem(
      id: row.id,
      saleId: row.saleId,
      productId: row.productId,
      productName: row.productName,
      unitPrice: row.unitPrice,
      quantity: row.quantity,
      vatRate: row.vatRate,
      vatAmount: row.vatAmount,
      subtotal: row.subtotal,
      total: row.total,
    );
  }

  models.Sale _saleFromRow(Sale row, List<models.SaleItem> items) {
    return models.Sale(
      id: row.id,
      invoiceNumber: row.invoiceNumber,
      customerId: row.customerId,
      cashierId: row.cashierId,
      saleDate: DateTime.parse(row.saleDate),
      items: items,
      subtotal: row.subtotal,
      vatAmount: row.vatAmount,
      totalAmount: row.totalAmount,
      paidAmount: row.paidAmount,
      changeAmount: row.changeAmount,
      status: row.status == 'completed'
          ? models.SaleStatus.completed
          : row.status == 'returned'
              ? models.SaleStatus.returned
              : models.SaleStatus.cancelled,
      paymentMethod: row.paymentMethod == 'cash'
          ? models.PaymentMethod.cash
          : row.paymentMethod == 'card'
              ? models.PaymentMethod.card
              : models.PaymentMethod.transfer,
      notes: row.notes,
      isPrinted: row.isPrinted,
      needsSync: row.needsSync,
      createdAt: DateTime.parse(row.createdAt),
      updatedAt: DateTime.parse(row.updatedAt),
    );
  }

  models.CompanyInfo _companyInfoFromRow(CompanyInfoTableData row) {
    return models.CompanyInfo(
      id: row.id,
      name: row.name,
      nameArabic: row.nameArabic,
      address: row.address,
      addressArabic: row.addressArabic,
      phone: row.phone,
      email: row.email,
      vatNumber: row.vatNumber,
      crnNumber: row.crnNumber,
      logoPath: row.logoPath,
      createdAt: DateTime.parse(row.createdAt),
      updatedAt: DateTime.parse(row.updatedAt),
    );
  }

  models.Category _categoryFromRow(CategoriesTableData row) {
    return models.Category(
      id: row.id,
      name: row.name,
      nameAr: row.nameAr,
      description: row.description,
      descriptionAr: row.descriptionAr,
      imageUrl: row.imageUrl,
      isActive: row.isActive,
      createdAt: DateTime.parse(row.createdAt),
      updatedAt: DateTime.parse(row.updatedAt),
      needsSync: row.needsSync,
    );
  }

  // Category operations
  Future<models.Category> createCategory(models.Category category) async {
    await into(categoriesTable).insert(CategoriesTableCompanion(
      id: Value(category.id),
      name: Value(category.name),
      nameAr: Value(category.nameAr),
      description: Value(category.description),
      descriptionAr: Value(category.descriptionAr),
      imageUrl: Value(category.imageUrl),
      isActive: Value(category.isActive),
      createdAt: Value(category.createdAt.toIso8601String()),
      updatedAt: Value(category.updatedAt.toIso8601String()),
      needsSync: Value(category.needsSync),
    ));
    return category;
  }

  Future<models.Category?> getCategory(String id) async {
    final query = select(categoriesTable)..where((tbl) => tbl.id.equals(id));
    final result = await query.getSingleOrNull();
    if (result == null) return null;
    return _categoryFromRow(result);
  }

  Future<List<models.Category>> getAllCategories(
      {bool activeOnly = false}) async {
    final query = select(categoriesTable)
      ..orderBy([(t) => OrderingTerm(expression: t.name)]);
    if (activeOnly) {
      query.where((tbl) => tbl.isActive.equals(true));
    }
    final result = await query.get();
    return result.map((row) => _categoryFromRow(row)).toList();
  }

  Future<int> updateCategory(models.Category category) async {
    return (update(categoriesTable)..where((tbl) => tbl.id.equals(category.id)))
        .write(
      CategoriesTableCompanion(
        name: Value(category.name),
        nameAr: Value(category.nameAr),
        description: Value(category.description),
        descriptionAr: Value(category.descriptionAr),
        imageUrl: Value(category.imageUrl),
        isActive: Value(category.isActive),
        updatedAt: Value(DateTime.now().toIso8601String()),
        needsSync: Value(category.needsSync),
      ),
    );
  }

  Future<int> deleteCategory(String id) async {
    return (delete(categoriesTable)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Get category with product count
  Future<List<Map<String, dynamic>>> getCategoriesWithProductCount() async {
    final categoriesList = await getAllCategories(activeOnly: true);
    final result = <Map<String, dynamic>>[];

    for (var category in categoriesList) {
      final productCount = await (select(products)
            ..where((tbl) =>
                tbl.categoryId.equals(category.id) & tbl.isActive.equals(true)))
          .get()
          .then((rows) => rows.length);

      result.add({
        'category': category,
        'productCount': productCount,
      });
    }

    return result;
  }

  // Seed initial data
  Future<void> _seedInitialData() async {
    // Check if we already have data
    final userCount = await (select(users)).get().then((rows) => rows.length);
    if (userCount > 0) return; // Already seeded

    await _seedInitialCategories();
    await _seedInitialProducts();
    await _seedInitialUser();
    await _seedInitialCustomers();
    await _seedInitialCompanyInfo();
  }

  Future<void> _seedInitialCategories() async {
    final now = DateTime.now();
    final defaultCategories = [
      models.Category(
        id: 'cat-1',
        name: 'Electronics',
        nameAr: 'الإلكترونيات',
        description: 'Electronic devices and accessories',
        descriptionAr: 'الأجهزة الإلكترونية والملحقات',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      models.Category(
        id: 'cat-2',
        name: 'Clothing',
        nameAr: 'الملابس',
        description: 'Apparel and fashion items',
        descriptionAr: 'الملابس والأزياء',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      models.Category(
        id: 'cat-3',
        name: 'Food & Beverages',
        nameAr: 'الأطعمة والمشروبات',
        description: 'Food items and drinks',
        descriptionAr: 'المواد الغذائية والمشروبات',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      models.Category(
        id: 'cat-4',
        name: 'Home & Garden',
        nameAr: 'المنزل والحديقة',
        description: 'Home improvement and garden supplies',
        descriptionAr: 'مستلزمات تحسين المنزل والحديقة',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      models.Category(
        id: 'cat-5',
        name: 'Office Supplies',
        nameAr: 'اللوازم المكتبية',
        description: 'Office and stationery items',
        descriptionAr: 'المستلزمات المكتبية والقرطاسية',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    for (var category in defaultCategories) {
      await createCategory(category);
    }
  }

  Future<void> _seedInitialProducts() async {
    final now = DateTime.now();
    final defaultProducts = [
      // Electronics
      models.Product(
        id: 'prod-1',
        name: 'Wireless Mouse',
        nameAr: 'ماوس لاسلكي',
        description: 'Ergonomic wireless mouse with USB receiver',
        descriptionAr: 'ماوس لاسلكي مريح مع مستقبل USB',
        barcode: '1234567890001',
        price: 45.00,
        cost: 30.00,
        quantity: 50,
        category: 'cat-1',
        isActive: true,
        vatRate: 15.0,
        createdAt: now,
        updatedAt: now,
      ),
      models.Product(
        id: 'prod-6',
        name: 'USB Keyboard',
        nameAr: 'لوحة مفاتيح USB',
        description: 'Mechanical keyboard with LED backlight',
        descriptionAr: 'لوحة مفاتيح ميكانيكية مع إضاءة LED',
        barcode: '1234567890006',
        price: 120.00,
        cost: 80.00,
        quantity: 35,
        category: 'cat-1',
        isActive: true,
        vatRate: 15.0,
        createdAt: now,
        updatedAt: now,
      ),
      models.Product(
        id: 'prod-7',
        name: 'USB-C Cable 2m',
        nameAr: 'كابل USB-C 2 متر',
        description: 'Fast charging USB-C to USB-C cable',
        descriptionAr: 'كابل شحن سريع من USB-C إلى USB-C',
        barcode: '1234567890007',
        price: 25.00,
        cost: 12.00,
        quantity: 100,
        category: 'cat-1',
        isActive: true,
        vatRate: 15.0,
        createdAt: now,
        updatedAt: now,
      ),
      models.Product(
        id: 'prod-8',
        name: 'Wireless Headphones',
        nameAr: 'سماعات لاسلكية',
        description: 'Bluetooth headphones with noise cancellation',
        descriptionAr: 'سماعات بلوتوث مع إلغاء الضوضاء',
        barcode: '1234567890008',
        price: 250.00,
        cost: 150.00,
        quantity: 25,
        category: 'cat-1',
        isActive: true,
        vatRate: 15.0,
        createdAt: now,
        updatedAt: now,
      ),

      // Clothing
      models.Product(
        id: 'prod-3',
        name: 'T-Shirt - Medium',
        nameAr: 'تيشيرت - وسط',
        description: 'Cotton t-shirt, medium size',
        descriptionAr: 'تيشيرت قطني، مقاس وسط',
        barcode: '1234567890003',
        price: 35.00,
        cost: 20.00,
        quantity: 75,
        category: 'cat-2',
        isActive: true,
        vatRate: 15.0,
        createdAt: now,
        updatedAt: now,
      ),
      models.Product(
        id: 'prod-9',
        name: 'Jeans - Size 32',
        nameAr: 'بنطلون جينز - مقاس 32',
        description: 'Blue denim jeans, classic fit',
        descriptionAr: 'بنطلون جينز أزرق، قصة كلاسيكية',
        barcode: '1234567890009',
        price: 150.00,
        cost: 90.00,
        quantity: 40,
        category: 'cat-2',
        isActive: true,
        vatRate: 15.0,
        createdAt: now,
        updatedAt: now,
      ),
      models.Product(
        id: 'prod-10',
        name: 'Sports Shoes',
        nameAr: 'أحذية رياضية',
        description: 'Running shoes with cushioned sole',
        descriptionAr: 'أحذية جري بنعل مبطن',
        barcode: '1234567890010',
        price: 280.00,
        cost: 180.00,
        quantity: 30,
        category: 'cat-2',
        isActive: true,
        vatRate: 15.0,
        createdAt: now,
        updatedAt: now,
      ),

      // Food & Beverages
      models.Product(
        id: 'prod-4',
        name: 'Water Bottle 1L',
        nameAr: 'زجاجة ماء 1 لتر',
        description: 'Purified drinking water',
        descriptionAr: 'مياه شرب نقية',
        barcode: '1234567890004',
        price: 3.50,
        cost: 2.00,
        quantity: 200,
        category: 'cat-3',
        isActive: true,
        vatRate: 15.0,
        createdAt: now,
        updatedAt: now,
      ),
      models.Product(
        id: 'prod-11',
        name: 'Coffee Beans 250g',
        nameAr: 'حبوب قهوة 250 جرام',
        description: 'Premium Arabica coffee beans',
        descriptionAr: 'حبوب قهوة عربية فاخرة',
        barcode: '1234567890011',
        price: 45.00,
        cost: 25.00,
        quantity: 60,
        category: 'cat-3',
        isActive: true,
        vatRate: 15.0,
        createdAt: now,
        updatedAt: now,
      ),
      models.Product(
        id: 'prod-12',
        name: 'Orange Juice 1L',
        nameAr: 'عصير برتقال 1 لتر',
        description: 'Fresh squeezed orange juice',
        descriptionAr: 'عصير برتقال طازج',
        barcode: '1234567890012',
        price: 12.00,
        cost: 7.00,
        quantity: 80,
        category: 'cat-3',
        isActive: true,
        vatRate: 15.0,
        createdAt: now,
        updatedAt: now,
      ),
      models.Product(
        id: 'prod-13',
        name: 'Chocolate Bar',
        nameAr: 'لوح شوكولاتة',
        description: 'Premium dark chocolate 100g',
        descriptionAr: 'شوكولاتة داكنة فاخرة 100 جرام',
        barcode: '1234567890013',
        price: 8.50,
        cost: 4.50,
        quantity: 150,
        category: 'cat-3',
        isActive: true,
        vatRate: 15.0,
        createdAt: now,
        updatedAt: now,
      ),

      // Home & Garden
      models.Product(
        id: 'prod-5',
        name: 'Garden Shovel',
        nameAr: 'مجرفة حديقة',
        description: 'Heavy-duty garden shovel',
        descriptionAr: 'مجرفة حديقة متينة',
        barcode: '1234567890005',
        price: 55.00,
        cost: 35.00,
        quantity: 30,
        category: 'cat-4',
        isActive: true,
        vatRate: 15.0,
        createdAt: now,
        updatedAt: now,
      ),
      models.Product(
        id: 'prod-14',
        name: 'LED Light Bulb',
        nameAr: 'مصباح LED',
        description: '10W LED bulb, warm white',
        descriptionAr: 'مصباح LED 10 واط، أبيض دافئ',
        barcode: '1234567890014',
        price: 15.00,
        cost: 8.00,
        quantity: 120,
        category: 'cat-4',
        isActive: true,
        vatRate: 15.0,
        createdAt: now,
        updatedAt: now,
      ),
      models.Product(
        id: 'prod-15',
        name: 'Plant Pot 30cm',
        nameAr: 'أصيص نباتات 30 سم',
        description: 'Ceramic plant pot with drainage',
        descriptionAr: 'أصيص نباتات خزفي مع تصريف',
        barcode: '1234567890015',
        price: 35.00,
        cost: 20.00,
        quantity: 45,
        category: 'cat-4',
        isActive: true,
        vatRate: 15.0,
        createdAt: now,
        updatedAt: now,
      ),

      // Office Supplies
      models.Product(
        id: 'prod-2',
        name: 'Notebook A4',
        nameAr: 'دفتر ملاحظات A4',
        description: '200 pages ruled notebook',
        descriptionAr: 'دفتر مسطر 200 صفحة',
        barcode: '1234567890002',
        price: 12.00,
        cost: 7.00,
        quantity: 100,
        category: 'cat-5',
        isActive: true,
        vatRate: 15.0,
        createdAt: now,
        updatedAt: now,
      ),
      models.Product(
        id: 'prod-16',
        name: 'Ballpoint Pen Pack',
        nameAr: 'عبوة أقلام حبر',
        description: 'Pack of 10 blue ballpoint pens',
        descriptionAr: 'عبوة من 10 أقلام حبر زرقاء',
        barcode: '1234567890016',
        price: 18.00,
        cost: 10.00,
        quantity: 200,
        category: 'cat-5',
        isActive: true,
        vatRate: 15.0,
        createdAt: now,
        updatedAt: now,
      ),
      models.Product(
        id: 'prod-17',
        name: 'Stapler',
        nameAr: 'دباسة',
        description: 'Heavy-duty office stapler',
        descriptionAr: 'دباسة مكتبية متينة',
        barcode: '1234567890017',
        price: 28.00,
        cost: 16.00,
        quantity: 50,
        category: 'cat-5',
        isActive: true,
        vatRate: 15.0,
        createdAt: now,
        updatedAt: now,
      ),
      models.Product(
        id: 'prod-18',
        name: 'A4 Paper Ream',
        nameAr: 'رزمة ورق A4',
        description: '500 sheets white copy paper',
        descriptionAr: '500 ورقة بيضاء للطباعة',
        barcode: '1234567890018',
        price: 22.00,
        cost: 14.00,
        quantity: 80,
        category: 'cat-5',
        isActive: true,
        vatRate: 15.0,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    for (var product in defaultProducts) {
      await createProduct(product);
    }
  }

  Future<void> _seedInitialUser() async {
    final now = DateTime.now();

    final defaultUsers = [
      models.User(
        id: 'user-1',
        username: 'admin',
        password: 'admin123', // In production, this should be hashed
        fullName: 'System Administrator',
        role: models.UserRole.admin,
        isActive: true,
        createdAt: now,
      ),
      models.User(
        id: 'user-2',
        username: 'cashier',
        password: 'cashier123', // In production, this should be hashed
        fullName: 'System Cashier',
        role: models.UserRole.cashier,
        isActive: true,
        createdAt: now,
      ),
    ];

    for (var user in defaultUsers) {
      await createUser(user);
    }
  }

  Future<void> _seedInitialCustomers() async {
    final now = DateTime.now();

    final defaultCustomers = [
      // Individual customers without business registration
      models.Customer(
        id: 'cust-1',
        name: 'Ahmed Al-Saud',
        email: 'ahmed.alsaud@email.com',
        phone: '+966501234567',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      models.Customer(
        id: 'cust-2',
        name: 'Fatima Hassan',
        email: 'fatima.hassan@email.com',
        phone: '+966502345678',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      models.Customer(
        id: 'cust-3',
        name: 'Mohammed Ali',
        phone: '+966503456789',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      // Business customers with CRN and VAT numbers
      models.Customer(
        id: 'cust-4',
        name: 'Al-Noor Trading Company',
        email: 'info@alnoor-trading.sa',
        phone: '+966114567890',
        crnNumber: '1010123456',
        vatNumber: '300123456789003',
        saudiAddress: models.SaudiAddress(
          buildingNumber: '7890',
          streetName: 'King Fahd Road',
          district: 'Al Olaya',
          city: 'Riyadh',
          postalCode: '12211',
          additionalNumber: '1234',
        ),
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      models.Customer(
        id: 'cust-5',
        name: 'Saudi Electronics Ltd.',
        email: 'sales@saudi-electronics.sa',
        phone: '+966126789012',
        crnNumber: '2020234567',
        vatNumber: '300234567890003',
        saudiAddress: models.SaudiAddress(
          buildingNumber: '4321',
          streetName: 'Prince Sultan Street',
          district: 'Al Hamra',
          city: 'Jeddah',
          postalCode: '23323',
          additionalNumber: '5678',
        ),
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      models.Customer(
        id: 'cust-6',
        name: 'Al-Khaleej General Trading',
        email: 'contact@alkhaleej-trading.sa',
        phone: '+966138901234',
        crnNumber: '3030345678',
        vatNumber: '300345678901003',
        saudiAddress: models.SaudiAddress(
          buildingNumber: '5678',
          streetName: 'Dhahran Street',
          district: 'Al Khobar',
          city: 'Dammam',
          postalCode: '32234',
          additionalNumber: '9012',
        ),
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      // Individual customer with full Saudi address
      models.Customer(
        id: 'cust-7',
        name: 'Khalid Ibrahim',
        email: 'khalid.ibrahim@email.com',
        phone: '+966504567890',
        saudiAddress: models.SaudiAddress(
          buildingNumber: '2468',
          streetName: 'Takhassusi Street',
          district: 'Al Muhammadiyah',
          city: 'Riyadh',
          postalCode: '12364',
          additionalNumber: '3456',
        ),
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      // Additional individual customers
      models.Customer(
        id: 'cust-8',
        name: 'Sara Al-Mutairi',
        email: 'sara.mutairi@email.com',
        phone: '+966505678901',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      models.Customer(
        id: 'cust-9',
        name: 'Abdullah Omar',
        phone: '+966506789012',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      models.Customer(
        id: 'cust-10',
        name: 'Noura Fahad',
        email: 'noura.fahad@email.com',
        phone: '+966507890123',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    for (var customer in defaultCustomers) {
      await createCustomer(customer);
    }
  }

  Future<void> _seedInitialCompanyInfo() async {
    final now = DateTime.now();

    final companyInfo = models.CompanyInfo(
      id: 'company-1',
      name: 'Saudi Retail Solutions',
      nameArabic: 'حلول التجزئة السعودية',
      address:
          'Building 1234, King Abdullah Road, Al Olaya District, Riyadh 12345',
      addressArabic: 'مبنى 1234، طريق الملك عبدالله، حي العليا، الرياض 12345',
      phone: '+966112345678',
      email: 'info@saudiretail.sa',
      vatNumber: '300123456789003',
      crnNumber: '1010987654',
      logoPath: 'assets/images/sample_company_logo.png',
      createdAt: now,
      updatedAt: now,
    );

    await createOrUpdateCompanyInfo(companyInfo);
  }
}
