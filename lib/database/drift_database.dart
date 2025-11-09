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
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
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
  TextColumn get description => text().nullable()();
  TextColumn get barcode => text()();
  RealColumn get price => real()();
  RealColumn get cost => real()();
  IntColumn get quantity => integer()();
  TextColumn get categoryId => text().references(Categories, #id)();
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
  TextColumn get saleId => text().references(Sales, #id, onDelete: KeyAction.cascade)();
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

@DriftDatabase(tables: [Users, Categories, Products, Customers, Sales, SaleItems, CompanyInfoTable])
class AppDatabase extends _$AppDatabase {
  // Singleton pattern
  static AppDatabase? _instance;

  AppDatabase._internal() : super(impl.connect());

  factory AppDatabase() {
    _instance ??= AppDatabase._internal();
    return _instance!;
  }

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();

      // Create indexes
      await customStatement('CREATE INDEX idx_products_barcode ON products(barcode)');
      await customStatement('CREATE INDEX idx_products_category_id ON products(category_id)');
      await customStatement('CREATE INDEX idx_sales_date ON sales(sale_date)');
      await customStatement('CREATE INDEX idx_sales_cashier ON sales(cashier_id)');
      await customStatement('CREATE INDEX idx_sale_items_sale ON sale_items(sale_id)');

      // Seed initial data
      await _seedInitialData();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from == 1 && to == 2) {
        // Create categories table
        await m.createTable(categories);

        // Add default categories
        await _seedInitialCategories();

        // Add categoryId column to products
        await m.addColumn(products, products.categoryId);

        // Migrate existing products to use the first category as default
        final defaultCategory = await (select(categories)..limit(1)).getSingleOrNull();
        if (defaultCategory != null) {
          await customStatement(
            'UPDATE products SET category_id = ? WHERE category_id IS NULL',
            [defaultCategory.id],
          );
        }

        // Update index
        await customStatement('CREATE INDEX idx_products_category_id ON products(category_id)');
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

  // Product operations
  Future<models.Product> createProduct(models.Product product) async {
    await into(products).insert(ProductsCompanion(
      id: Value(product.id),
      name: Value(product.name),
      description: Value(product.description),
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
    final query = select(products)..orderBy([(t) => OrderingTerm(expression: t.name)]);
    if (activeOnly) {
      query.where((tbl) => tbl.isActive.equals(true));
    }
    final result = await query.get();
    return result.map((row) => _productFromRow(row)).toList();
  }

  Future<List<models.Product>> getProductsByCategory(String categoryId) async {
    final query = select(products)
      ..where((tbl) => tbl.categoryId.equals(categoryId) & tbl.isActive.equals(true))
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
        description: Value(product.description),
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

  Future<List<models.Customer>> getAllCustomers({bool activeOnly = false}) async {
    final query = select(customers)..orderBy([(t) => OrderingTerm(expression: t.name)]);
    if (activeOnly) {
      query.where((tbl) => tbl.isActive.equals(true));
    }
    final result = await query.get();
    return result.map((row) => _customerFromRow(row)).toList();
  }

  Future<int> updateCustomer(models.Customer customer) async {
    return (update(customers)..where((tbl) => tbl.id.equals(customer.id))).write(
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
      ..orderBy([(t) => OrderingTerm(expression: t.saleDate, mode: OrderingMode.desc)]))
      .get();

    final allSales = <models.Sale>[];
    for (var saleRow in saleRows) {
      final itemsQuery = select(saleItems)..where((tbl) => tbl.saleId.equals(saleRow.id));
      final itemRows = await itemsQuery.get();
      final items = itemRows.map((row) => _saleItemFromRow(row)).toList();
      allSales.add(_saleFromRow(saleRow, items));
    }
    return allSales;
  }

  Future<List<models.Sale>> getSalesByDateRange(DateTime start, DateTime end) async {
    final saleRows = await (select(sales)
      ..where((tbl) =>
        tbl.saleDate.isBiggerOrEqualValue(start.toIso8601String()) &
        tbl.saleDate.isSmallerOrEqualValue(end.toIso8601String()))
      ..orderBy([(t) => OrderingTerm(expression: t.saleDate, mode: OrderingMode.desc)]))
      .get();

    final allSales = <models.Sale>[];
    for (var saleRow in saleRows) {
      final itemsQuery = select(saleItems)..where((tbl) => tbl.saleId.equals(saleRow.id));
      final itemRows = await itemsQuery.get();
      final items = itemRows.map((row) => _saleItemFromRow(row)).toList();
      allSales.add(_saleFromRow(saleRow, items));
    }
    return allSales;
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
  Future<models.CompanyInfo> createOrUpdateCompanyInfo(models.CompanyInfo info) async {
    final existing = await (select(companyInfoTable)..limit(1)).getSingleOrNull();

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
      await (update(companyInfoTable)..where((tbl) => tbl.id.equals(existing.id))).write(
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
    final saleRows = await (select(sales)..where((tbl) => tbl.needsSync.equals(true))).get();

    final allSales = <models.Sale>[];
    for (var saleRow in saleRows) {
      final itemsQuery = select(saleItems)..where((tbl) => tbl.saleId.equals(saleRow.id));
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
      role: row.role == 'admin' ? models.UserRole.admin : models.UserRole.cashier,
      isActive: row.isActive,
      createdAt: DateTime.parse(row.createdAt),
      lastLoginAt: row.lastLoginAt != null ? DateTime.parse(row.lastLoginAt!) : null,
    );
  }

  models.Product _productFromRow(Product row) {
    return models.Product(
      id: row.id,
      name: row.name,
      description: row.description,
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

  models.Category _categoryFromRow(Category row) {
    return models.Category(
      id: row.id,
      name: row.name,
      description: row.description,
      imageUrl: row.imageUrl,
      isActive: row.isActive,
      createdAt: DateTime.parse(row.createdAt),
      updatedAt: DateTime.parse(row.updatedAt),
      needsSync: row.needsSync,
    );
  }

  // Category operations
  Future<models.Category> createCategory(models.Category category) async {
    await into(categories).insert(CategoriesCompanion(
      id: Value(category.id),
      name: Value(category.name),
      description: Value(category.description),
      imageUrl: Value(category.imageUrl),
      isActive: Value(category.isActive),
      createdAt: Value(category.createdAt.toIso8601String()),
      updatedAt: Value(category.updatedAt.toIso8601String()),
      needsSync: Value(category.needsSync),
    ));
    return category;
  }

  Future<models.Category?> getCategory(String id) async {
    final query = select(categories)..where((tbl) => tbl.id.equals(id));
    final result = await query.getSingleOrNull();
    if (result == null) return null;
    return _categoryFromRow(result);
  }

  Future<List<models.Category>> getAllCategories({bool activeOnly = false}) async {
    final query = select(categories)..orderBy([(t) => OrderingTerm(expression: t.name)]);
    if (activeOnly) {
      query.where((tbl) => tbl.isActive.equals(true));
    }
    final result = await query.get();
    return result.map((row) => _categoryFromRow(row)).toList();
  }

  Future<int> updateCategory(models.Category category) async {
    return (update(categories)..where((tbl) => tbl.id.equals(category.id))).write(
      CategoriesCompanion(
        name: Value(category.name),
        description: Value(category.description),
        imageUrl: Value(category.imageUrl),
        isActive: Value(category.isActive),
        updatedAt: Value(DateTime.now().toIso8601String()),
        needsSync: Value(category.needsSync),
      ),
    );
  }

  Future<int> deleteCategory(String id) async {
    return (delete(categories)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Get category with product count
  Future<List<Map<String, dynamic>>> getCategoriesWithProductCount() async {
    final categoriesList = await getAllCategories(activeOnly: true);
    final result = <Map<String, dynamic>>[];

    for (var category in categoriesList) {
      final productCount = await (select(products)
        ..where((tbl) => tbl.categoryId.equals(category.id) & tbl.isActive.equals(true)))
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
  }

  Future<void> _seedInitialCategories() async {
    final now = DateTime.now();
    final defaultCategories = [
      models.Category(
        id: 'cat-1',
        name: 'Electronics',
        description: 'Electronic devices and accessories',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      models.Category(
        id: 'cat-2',
        name: 'Clothing',
        description: 'Apparel and fashion items',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      models.Category(
        id: 'cat-3',
        name: 'Food & Beverages',
        description: 'Food items and drinks',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      models.Category(
        id: 'cat-4',
        name: 'Home & Garden',
        description: 'Home improvement and garden supplies',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      models.Category(
        id: 'cat-5',
        name: 'Office Supplies',
        description: 'Office and stationery items',
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
      models.Product(
        id: 'prod-1',
        name: 'Wireless Mouse',
        description: 'Ergonomic wireless mouse with USB receiver',
        barcode: '1234567890001',
        price: 45.00,
        cost: 30.00,
        quantity: 50,
        category: 'cat-1', // Electronics
        isActive: true,
        vatRate: 15.0,
        createdAt: now,
        updatedAt: now,
      ),
      models.Product(
        id: 'prod-2',
        name: 'Notebook A4',
        description: '200 pages ruled notebook',
        barcode: '1234567890002',
        price: 12.00,
        cost: 7.00,
        quantity: 100,
        category: 'cat-5', // Office Supplies
        isActive: true,
        vatRate: 15.0,
        createdAt: now,
        updatedAt: now,
      ),
      models.Product(
        id: 'prod-3',
        name: 'T-Shirt - Medium',
        description: 'Cotton t-shirt, medium size',
        barcode: '1234567890003',
        price: 35.00,
        cost: 20.00,
        quantity: 75,
        category: 'cat-2', // Clothing
        isActive: true,
        vatRate: 15.0,
        createdAt: now,
        updatedAt: now,
      ),
      models.Product(
        id: 'prod-4',
        name: 'Water Bottle 1L',
        description: 'Purified drinking water',
        barcode: '1234567890004',
        price: 3.50,
        cost: 2.00,
        quantity: 200,
        category: 'cat-3', // Food & Beverages
        isActive: true,
        vatRate: 15.0,
        createdAt: now,
        updatedAt: now,
      ),
      models.Product(
        id: 'prod-5',
        name: 'Garden Shovel',
        description: 'Heavy-duty garden shovel',
        barcode: '1234567890005',
        price: 55.00,
        cost: 35.00,
        quantity: 30,
        category: 'cat-4', // Home & Garden
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
    final adminUser = models.User(
      id: 'user-1',
      username: 'admin',
      password: 'admin123', // In production, this should be hashed
      fullName: 'System Administrator',
      role: models.UserRole.admin,
      isActive: true,
      createdAt: now,
    );

    await createUser(adminUser);
  }
}
