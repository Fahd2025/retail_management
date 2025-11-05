import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/sale.dart';
import '../models/company_info.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('retail_management.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';
    const intType = 'INTEGER NOT NULL';
    const doubleType = 'REAL NOT NULL';
    const boolType = 'INTEGER NOT NULL';

    // Users table
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        username $textType,
        password $textType,
        fullName $textType,
        role $textType,
        isActive $boolType,
        createdAt $textType,
        lastLoginAt $textTypeNullable
      )
    ''');

    // Products table
    await db.execute('''
      CREATE TABLE products (
        id $idType,
        name $textType,
        description $textTypeNullable,
        barcode $textType,
        price $doubleType,
        cost $doubleType,
        quantity $intType,
        category $textType,
        imageUrl $textTypeNullable,
        isActive $boolType,
        vatRate $doubleType,
        createdAt $textType,
        updatedAt $textType,
        needsSync $boolType
      )
    ''');

    // Customers table
    await db.execute('''
      CREATE TABLE customers (
        id $idType,
        name $textType,
        email $textTypeNullable,
        phone $textTypeNullable,
        crnNumber $textTypeNullable,
        vatNumber $textTypeNullable,
        saudiAddress $textTypeNullable,
        isActive $boolType,
        createdAt $textType,
        updatedAt $textType,
        needsSync $boolType
      )
    ''');

    // Sales table
    await db.execute('''
      CREATE TABLE sales (
        id $idType,
        invoiceNumber $textType,
        customerId $textTypeNullable,
        cashierId $textType,
        saleDate $textType,
        subtotal $doubleType,
        vatAmount $doubleType,
        totalAmount $doubleType,
        paidAmount $doubleType,
        changeAmount $doubleType,
        status $textType,
        paymentMethod $textType,
        notes $textTypeNullable,
        isPrinted $boolType,
        needsSync $boolType,
        createdAt $textType,
        updatedAt $textType
      )
    ''');

    // Sale Items table
    await db.execute('''
      CREATE TABLE sale_items (
        id $idType,
        saleId $textType,
        productId $textType,
        productName $textType,
        unitPrice $doubleType,
        quantity $intType,
        vatRate $doubleType,
        vatAmount $doubleType,
        subtotal $doubleType,
        total $doubleType,
        FOREIGN KEY (saleId) REFERENCES sales (id) ON DELETE CASCADE
      )
    ''');

    // Company Info table
    await db.execute('''
      CREATE TABLE company_info (
        id $idType,
        name $textType,
        nameArabic $textType,
        address $textType,
        addressArabic $textType,
        phone $textType,
        email $textTypeNullable,
        vatNumber $textType,
        crnNumber $textType,
        logoPath $textTypeNullable,
        createdAt $textType,
        updatedAt $textType
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_products_barcode ON products(barcode)');
    await db.execute('CREATE INDEX idx_products_category ON products(category)');
    await db.execute('CREATE INDEX idx_sales_date ON sales(saleDate)');
    await db.execute('CREATE INDEX idx_sales_cashier ON sales(cashierId)');
    await db.execute('CREATE INDEX idx_sale_items_sale ON sale_items(saleId)');
  }

  // User operations
  Future<User> createUser(User user) async {
    final db = await database;
    await db.insert('users', user.toMap());
    return user;
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final result = await db.query('users');
    return result.map((map) => User.fromMap(map)).toList();
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Product operations
  Future<Product> createProduct(Product product) async {
    final db = await database;
    await db.insert('products', product.toMap());
    return product;
  }

  Future<Product?> getProduct(String id) async {
    final db = await database;
    final maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    final db = await database;
    final maps = await db.query(
      'products',
      where: 'barcode = ?',
      whereArgs: [barcode],
    );

    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Product>> getAllProducts({bool activeOnly = false}) async {
    final db = await database;
    final result = await db.query(
      'products',
      where: activeOnly ? 'isActive = ?' : null,
      whereArgs: activeOnly ? [1] : null,
      orderBy: 'name ASC',
    );
    return result.map((map) => Product.fromMap(map)).toList();
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    final db = await database;
    final result = await db.query(
      'products',
      where: 'category = ? AND isActive = ?',
      whereArgs: [category, 1],
      orderBy: 'name ASC',
    );
    return result.map((map) => Product.fromMap(map)).toList();
  }

  Future<List<String>> getProductCategories() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT DISTINCT category FROM products WHERE isActive = 1 ORDER BY category ASC',
    );
    return result.map((map) => map['category'] as String).toList();
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(String id) async {
    final db = await database;
    return db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Customer operations
  Future<Customer> createCustomer(Customer customer) async {
    final db = await database;
    await db.insert('customers', customer.toMap());
    return customer;
  }

  Future<Customer?> getCustomer(String id) async {
    final db = await database;
    final maps = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Customer.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Customer>> getAllCustomers({bool activeOnly = false}) async {
    final db = await database;
    final result = await db.query(
      'customers',
      where: activeOnly ? 'isActive = ?' : null,
      whereArgs: activeOnly ? [1] : null,
      orderBy: 'name ASC',
    );
    return result.map((map) => Customer.fromMap(map)).toList();
  }

  Future<int> updateCustomer(Customer customer) async {
    final db = await database;
    return db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(String id) async {
    final db = await database;
    return db.delete(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Sale operations
  Future<Sale> createSale(Sale sale) async {
    final db = await database;
    await db.insert('sales', sale.toMap());

    // Insert sale items
    for (var item in sale.items) {
      await db.insert('sale_items', item.toMap());
    }

    return sale;
  }

  Future<Sale?> getSale(String id) async {
    final db = await database;
    final saleMaps = await db.query(
      'sales',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (saleMaps.isEmpty) return null;

    final itemMaps = await db.query(
      'sale_items',
      where: 'saleId = ?',
      whereArgs: [id],
    );

    final items = itemMaps.map((map) => SaleItem.fromMap(map)).toList();
    return Sale.fromMap(saleMaps.first, items);
  }

  Future<List<Sale>> getAllSales() async {
    final db = await database;
    final saleMaps = await db.query(
      'sales',
      orderBy: 'saleDate DESC',
    );

    final sales = <Sale>[];
    for (var saleMap in saleMaps) {
      final itemMaps = await db.query(
        'sale_items',
        where: 'saleId = ?',
        whereArgs: [saleMap['id']],
      );
      final items = itemMaps.map((map) => SaleItem.fromMap(map)).toList();
      sales.add(Sale.fromMap(saleMap, items));
    }

    return sales;
  }

  Future<List<Sale>> getSalesByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final saleMaps = await db.query(
      'sales',
      where: 'saleDate BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'saleDate DESC',
    );

    final sales = <Sale>[];
    for (var saleMap in saleMaps) {
      final itemMaps = await db.query(
        'sale_items',
        where: 'saleId = ?',
        whereArgs: [saleMap['id']],
      );
      final items = itemMaps.map((map) => SaleItem.fromMap(map)).toList();
      sales.add(Sale.fromMap(saleMap, items));
    }

    return sales;
  }

  Future<int> updateSale(Sale sale) async {
    final db = await database;
    return db.update(
      'sales',
      sale.toMap(),
      where: 'id = ?',
      whereArgs: [sale.id],
    );
  }

  // Company Info operations
  Future<CompanyInfo> createOrUpdateCompanyInfo(CompanyInfo info) async {
    final db = await database;
    final existing = await db.query('company_info', limit: 1);

    if (existing.isEmpty) {
      await db.insert('company_info', info.toMap());
    } else {
      await db.update(
        'company_info',
        info.toMap(),
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    }
    return info;
  }

  Future<CompanyInfo?> getCompanyInfo() async {
    final db = await database;
    final maps = await db.query('company_info', limit: 1);

    if (maps.isNotEmpty) {
      return CompanyInfo.fromMap(maps.first);
    }
    return null;
  }

  // Sync operations
  Future<List<Product>> getProductsNeedingSync() async {
    final db = await database;
    final result = await db.query(
      'products',
      where: 'needsSync = ?',
      whereArgs: [1],
    );
    return result.map((map) => Product.fromMap(map)).toList();
  }

  Future<List<Customer>> getCustomersNeedingSync() async {
    final db = await database;
    final result = await db.query(
      'customers',
      where: 'needsSync = ?',
      whereArgs: [1],
    );
    return result.map((map) => Customer.fromMap(map)).toList();
  }

  Future<List<Sale>> getSalesNeedingSync() async {
    final db = await database;
    final saleMaps = await db.query(
      'sales',
      where: 'needsSync = ?',
      whereArgs: [1],
    );

    final sales = <Sale>[];
    for (var saleMap in saleMaps) {
      final itemMaps = await db.query(
        'sale_items',
        where: 'saleId = ?',
        whereArgs: [saleMap['id']],
      );
      final items = itemMaps.map((map) => SaleItem.fromMap(map)).toList();
      sales.add(Sale.fromMap(saleMap, items));
    }

    return sales;
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
