# CLAUDE.md - AI Assistant Guide for Retail Management System

This document provides comprehensive guidance for AI assistants working on this Flutter-based retail management system. Last updated: 2025-11-14

## Table of Contents
- [Project Overview](#project-overview)
- [Technology Stack](#technology-stack)
- [Codebase Structure](#codebase-structure)
- [Development Workflows](#development-workflows)
- [Key Conventions](#key-conventions)
- [Database Schema](#database-schema)
- [State Management](#state-management)
- [Localization & RTL](#localization--rtl)
- [Testing Strategy](#testing-strategy)
- [Common Tasks](#common-tasks)
- [Important Gotchas](#important-gotchas)

---

## Project Overview

**Name**: Retail Management System
**Version**: 1.0.0+1
**Type**: Multi-platform Flutter application (Web, Android, iOS)
**Purpose**: Comprehensive retail/POS system with offline support, invoice printing, and ZATCA compliance
**Primary Market**: Saudi Arabia (bilingual English/Arabic with VAT compliance)

### Key Features
- Role-based authentication (Admin, Cashier)
- Product & category management with Arabic support
- Customer management with Saudi business fields (VAT number, CRN, National Address)
- Point of Sale (POS) interface with barcode scanning
- Multi-format invoice printing (A4, Thermal 80mm, Thermal 58mm)
- ZATCA-compliant QR code generation
- Dashboard analytics with charts
- Offline-first architecture with sync capabilities
- Configurable VAT settings (enable/disable, rates, pricing modes)
- Dark mode support
- Bilingual UI (English/Arabic with RTL)

### Current Status (as of latest commits)
- Recent work focused on VAT settings, invoice templates, and Arabic translations
- Active development on payment handling and translation updates
- Comprehensive documentation in `/docs` directory (17 files)

---

## Technology Stack

### Framework & Language
- **Flutter**: >=3.0.0 (SDK constraint: >=3.0.0 <4.0.0)
- **Dart**: >=3.0.0
- **Material Design**: Material 3 with custom theming

### State Management
- **Primary**: BLoC pattern (`flutter_bloc: ^9.1.1`, `bloc: ^9.1.0`)
  - Event-driven architecture
  - Reactive state updates
  - Uses `equatable: ^2.0.5` for state comparison
- **Legacy**: Provider pattern (still present in `/lib/providers/` but being phased out)

### Database & Persistence
- **Drift**: ^2.14.0 (SQL ORM, type-safe queries)
  - Mobile: SQLite3 native
  - Web: WASM-based SQLite via IndexedDB
  - Database name: `retail_management_db`
  - Schema version: 3 (check `lib/database/drift_database.dart`)
- **SharedPreferences**: ^2.2.2 (user preferences, theme, locale)
- **Path Provider**: ^2.1.1 (file system access)

### Core Dependencies
```yaml
# PDF & Printing
pdf: ^3.10.7
printing: ^5.11.1

# QR Codes (ZATCA compliance)
qr_flutter: ^4.1.0

# Networking
http: ^1.1.0
connectivity_plus: ^7.0.0

# Localization
intl: ^0.20.2
flutter_localizations: sdk

# Image Handling
image_picker: ^1.0.5
image: ^4.1.3

# UI/UX
flutter_screenutil: ^5.9.0  # Responsive design (1920x1080 base)
fl_chart: ^0.69.0           # Charts for analytics
animations: ^2.0.11         # Material animations

# Utilities
uuid: ^4.2.2
permission_handler: ^12.0.1
```

### Development Tools
```yaml
build_runner: ^2.4.0        # Code generation
drift_dev: ^2.14.0          # Drift code gen
flutter_lints: ^6.0.0       # Linting rules
```

---

## Codebase Structure

```
/home/user/retail_management/
├── lib/                           # Main application code (27,111 lines)
│   ├── main.dart                  # Entry point, BLoC providers, theme setup
│   │
│   ├── blocs/                     # BLoC state management (PRIMARY)
│   │   ├── auth/                  # Authentication state
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   └── auth_state.dart
│   │   ├── product/               # Product management
│   │   ├── customer/              # Customer management
│   │   ├── sale/                  # Sales/transactions
│   │   ├── user/                  # User management
│   │   ├── dashboard/             # Dashboard analytics
│   │   └── app_config/            # App configuration (theme, locale)
│   │
│   ├── database/                  # Data persistence layer
│   │   ├── drift_database.dart    # Schema definition (1,640 lines)
│   │   ├── drift_database.g.dart  # GENERATED - DO NOT EDIT
│   │   └── connection/            # Platform-specific DB connections
│   │       ├── native.dart        # Android/iOS
│   │       ├── web.dart           # Web (WASM)
│   │       └── unsupported.dart   # Fallback
│   │
│   ├── models/                    # Data models
│   │   ├── user.dart
│   │   ├── product.dart           # Bilingual fields (name/nameAr)
│   │   ├── category.dart          # Bilingual fields
│   │   ├── customer.dart          # Saudi business fields
│   │   ├── sale.dart
│   │   ├── company_info.dart
│   │   ├── print_format.dart      # Invoice format configs
│   │   └── dashboard_statistics.dart
│   │
│   ├── screens/                   # UI screens (8 main screens)
│   │   ├── login_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── analytics_dashboard_screen.dart
│   │   ├── products_screen.dart
│   │   ├── categories_screen.dart
│   │   ├── customers_screen.dart
│   │   ├── sales_screen.dart
│   │   ├── cashier_screen.dart    # POS interface
│   │   ├── users_screen.dart
│   │   └── settings_screen.dart
│   │
│   ├── services/                  # Business logic layer
│   │   ├── auth_service.dart
│   │   ├── invoice_service.dart   # PDF generation orchestrator
│   │   ├── customer_invoice_export_service.dart
│   │   ├── sync_service.dart      # Offline sync
│   │   ├── image_service.dart
│   │   └── invoice_templates/     # Factory pattern
│   │       ├── a4_invoice_template.dart
│   │       ├── thermal_80mm_template.dart
│   │       ├── thermal_58mm_template.dart
│   │       └── invoice_template_factory.dart
│   │
│   ├── widgets/                   # Reusable components
│   │   ├── dashboard/             # Dashboard-specific widgets
│   │   ├── form_bottom_sheet.dart
│   │   ├── print_format_selector.dart
│   │   ├── invoice_preview_dialog.dart
│   │   ├── company_logo_picker.dart
│   │   └── settings_section.dart
│   │
│   ├── providers/                 # LEGACY Provider pattern
│   │   ├── auth_provider.dart     # Being migrated to BLoC
│   │   ├── product_provider.dart  # Being migrated to BLoC
│   │   ├── customer_provider.dart
│   │   ├── sale_provider.dart
│   │   ├── user_provider.dart
│   │   ├── theme_provider.dart    # Theme state
│   │   └── locale_provider.dart   # Localization state
│   │
│   ├── config/                    # Configuration
│   │   ├── app_theme.dart         # Material 3 theme (1,129 lines)
│   │   ├── dark_theme_colors.dart # Dark mode color palette
│   │   └── app_typography.dart    # Typography system
│   │
│   ├── l10n/                      # Localization (CRITICAL)
│   │   ├── app_en.arb             # English (731 strings)
│   │   ├── app_ar.arb             # Arabic (506 strings)
│   │   ├── app_localizations.dart # GENERATED - DO NOT EDIT
│   │   ├── app_localizations_en.dart # GENERATED
│   │   └── app_localizations_ar.dart # GENERATED
│   │
│   └── utils/
│       └── zatca_qr_generator.dart # Saudi VAT QR codes
│
├── assets/
│   ├── images/                    # Company logos, graphics
│   ├── icons/                     # App icons
│   └── fonts/
│       └── NotoSansArabic-Regular.ttf  # Arabic font support
│
├── android/                       # Android platform code
├── ios/                          # iOS platform code (if present)
├── web/                          # Web platform code
│   ├── index.html
│   └── manifest.json             # PWA configuration
│
├── test/                         # Tests
│   ├── widget_test.dart
│   ├── invoice_template_test.dart
│   └── print_format_selector_test.dart
│
├── docs/                         # Comprehensive documentation (17 files)
│   ├── DOCUMENTATION_INDEX.md    # Start here
│   ├── QUICKSTART.md
│   ├── MIGRATION.md
│   ├── ARABIC_TRANSLATION_REQUIREMENTS.md  # MANDATORY for new features
│   ├── CUSTOM_INVOICE_PRINTING.md
│   ├── FLUTTER_ARCHITECTURE.md
│   └── ... (11 more docs)
│
├── pubspec.yaml                  # Dependencies
├── l10n.yaml                     # Localization config
└── analysis_options.yaml         # Dart analyzer (intentionally minimal)
```

---

## Development Workflows

### Initial Setup
```bash
# 1. Install dependencies
flutter pub get

# 2. Generate Drift database code (REQUIRED)
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Run the app
flutter run -d chrome              # Web
flutter run -d android             # Android
flutter run -d ios                 # iOS
```

### Database Schema Changes
When modifying database tables in `lib/database/drift_database.dart`:

```bash
# 1. Update schema version in drift_database.dart
# Find: @DriftDatabase(..., schemaVersion: 3)
# Update to: @DriftDatabase(..., schemaVersion: 4)

# 2. Add migration logic in onUpgrade() method

# 3. Regenerate code
flutter pub run build_runner build --delete-conflicting-outputs

# 4. For clean slate (development only)
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Watch Mode (Development)
```bash
# Auto-rebuild on changes (recommended during active development)
flutter pub run build_runner watch
```

### Localization Changes
When adding/modifying translations:

```bash
# 1. Edit ARB files: lib/l10n/app_en.arb, lib/l10n/app_ar.arb
# 2. Run flutter to regenerate localization files
flutter gen-l10n  # or just run the app, it auto-generates

# 3. Use in code:
# AppLocalizations.of(context)!.keyName
```

**CRITICAL**: ALL new features MUST include Arabic translations. See `docs/ARABIC_TRANSLATION_REQUIREMENTS.md`.

### Git Workflow
```bash
# Current branch (as of this session)
git branch
# claude/claude-md-mhz7xea0qgwmou5w-0182Uqhe8FoJbRL3P7FRgFsB

# Common workflow
git add .
git commit -m "feat: Brief description of changes"
git push -u origin <branch-name>

# CRITICAL: Branch must start with 'claude/' and match session ID
# Push failures (403) indicate branch name mismatch
```

### Building for Production
```bash
# Web
flutter build web --release
flutter build web --web-renderer auto  # Recommended

# Android
flutter build apk --release              # Testing
flutter build appbundle --release        # Play Store

# iOS
flutter build ios --release
```

---

## Key Conventions

### Coding Standards

#### 1. File Naming
- **Dart files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Functions**: `camelCase`
- **Constants**: `SCREAMING_SNAKE_CASE` or `camelCase` for const

#### 2. BLoC Pattern (PRIMARY STATE MANAGEMENT)
```dart
// Event naming: <Noun><Verb>
class ProductLoadRequested extends ProductEvent {}
class ProductCreated extends ProductEvent {
  final Product product;
  ProductCreated(this.product);
}

// State naming: <Noun><Adjective>
class ProductLoading extends ProductState {}
class ProductLoaded extends ProductState {
  final List<Product> products;
  ProductLoaded(this.products);
}

// BLoC file structure
lib/blocs/feature/
  ├── feature_bloc.dart    # BLoC class
  ├── feature_event.dart   # Events
  └── feature_state.dart   # States
```

#### 3. Localization Keys
```dart
// ARB file structure (app_en.arb, app_ar.arb)
{
  "keyName": "Translation",
  "@keyName": {
    "description": "Context for translators"
  },

  // With placeholders
  "greeting": "Hello {name}",
  "@greeting": {
    "description": "Greeting message",
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
}

// Usage in code
Text(AppLocalizations.of(context)!.keyName)
Text(AppLocalizations.of(context)!.greeting('Ahmed'))
```

#### 4. Bilingual Data Fields
ALL user-facing text fields should have Arabic equivalents:
```dart
class Product {
  final String name;      // English
  final String? nameAr;   // Arabic (nullable for backward compatibility)
  final String? description;
  final String? descriptionAr;
}

// Display logic
String getDisplayName(BuildContext context) {
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';
  return isArabic && nameAr != null ? nameAr! : name;
}
```

#### 5. Database Tables (Drift)
```dart
// Table class naming: PascalCase, typically plural
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  // ... more columns

  @override
  Set<Column> get primaryKey => {id};
}

// For custom table names
class CategoriesTable extends Table {
  @override
  String get tableName => 'categories';
}
```

#### 6. Theme Access
```dart
// ALWAYS use Theme.of(context) - never hardcode colors
final theme = Theme.of(context);
final colorScheme = theme.colorScheme;

Container(
  color: colorScheme.primary,       // ✅ Correct
  color: Colors.blue,               // ❌ Wrong - breaks dark mode
)
```

#### 7. Responsive Design
```dart
// Using ScreenUtil (base: 1920x1080)
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Sizes
width: 200.w,     // Responsive width
height: 100.h,    // Responsive height
fontSize: 16.sp,  // Responsive font size

// Spacing
SizedBox(width: 16.w, height: 16.h)
EdgeInsets.all(16.r)  // Responsive radius
```

#### 8. Invoice Templates
```dart
// Use factory pattern
final template = InvoiceTemplateFactory.create(
  config: printConfig,
  sale: saleData,
  // ...
);

// Available formats
- PrintFormat.a4         // 210x297mm
- PrintFormat.thermal80mm
- PrintFormat.thermal58mm
```

### Architectural Patterns

#### 1. Separation of Concerns
```
UI Layer (Screens/Widgets)
    ↓ (events)
BLoC Layer (Business Logic)
    ↓ (queries/commands)
Service Layer (Business rules)
    ↓ (CRUD operations)
Data Layer (Database)
```

#### 2. Dependency Injection
```dart
// main.dart - BLoCs provided at root
MultiBlocProvider(
  providers: [
    BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(database),
    ),
    // ... more BLoCs
  ],
  child: MyApp(),
)

// Access in widgets
final authBloc = context.read<AuthBloc>();
```

#### 3. Repository Pattern (Implicit)
Services and BLoCs directly use AppDatabase instance - no separate repository layer.

---

## Database Schema

### Schema Version: 3
Location: `lib/database/drift_database.dart`

### Tables Overview

#### 1. users
```dart
id: TEXT PRIMARY KEY (UUID)
username: TEXT (unique)
password: TEXT (hashed - security note: verify implementation)
fullName: TEXT
role: TEXT ('Admin', 'Cashier')
isActive: BOOLEAN
createdAt: TEXT (ISO 8601)
lastLoginAt: TEXT (nullable)
```

**Default users**:
- admin / admin123 (role: Admin)
- cashier / cashier123 (role: Cashier)

#### 2. categories
```dart
id: TEXT PRIMARY KEY (UUID)
name: TEXT
nameAr: TEXT (nullable)
description: TEXT (nullable)
descriptionAr: TEXT (nullable)
imageUrl: TEXT (nullable)
isActive: BOOLEAN
createdAt: TEXT
updatedAt: TEXT
needsSync: BOOLEAN (for offline sync)
```

#### 3. products
```dart
id: TEXT PRIMARY KEY (UUID)
name: TEXT
nameAr: TEXT (nullable)
description: TEXT (nullable)
descriptionAr: TEXT (nullable)
barcode: TEXT
price: REAL
cost: REAL
quantity: INTEGER (stock level)
categoryId: TEXT (FOREIGN KEY → categories.id)
imageUrl: TEXT (nullable)
isActive: BOOLEAN
vatRate: REAL (e.g., 0.15 for 15%)
createdAt: TEXT
updatedAt: TEXT
needsSync: BOOLEAN
```

#### 4. customers
```dart
id: TEXT PRIMARY KEY (UUID)
name: TEXT
email: TEXT (nullable)
phone: TEXT (nullable)
crnNumber: TEXT (nullable) - Commercial Registration Number
vatNumber: TEXT (nullable) - Format: 300xxxxxxxxxxxxx (15 digits)
saudiAddress: TEXT (nullable) - JSON string with address structure
isActive: BOOLEAN
createdAt: TEXT
updatedAt: TEXT
needsSync: BOOLEAN
```

#### 5. sales
```dart
id: TEXT PRIMARY KEY (UUID)
invoiceNumber: TEXT (unique, auto-generated)
customerId: TEXT (nullable, FK → customers.id)
cashierId: TEXT (FK → users.id)
saleDate: TEXT (ISO 8601)
subtotal: REAL
vatAmount: REAL
totalAmount: REAL
paidAmount: REAL
changeAmount: REAL
status: TEXT ('completed', 'returned', 'cancelled')
paymentMethod: TEXT ('Cash', 'Card', 'Transfer')
notes: TEXT (nullable)
createdAt: TEXT
updatedAt: TEXT
needsSync: BOOLEAN
```

#### 6. sale_items
```dart
id: TEXT PRIMARY KEY (UUID)
saleId: TEXT (FK → sales.id)
productId: TEXT (FK → products.id)
productName: TEXT (snapshot)
productNameAr: TEXT (nullable, snapshot)
quantity: INTEGER
unitPrice: REAL (snapshot)
vatRate: REAL (snapshot)
vatAmount: REAL
totalAmount: REAL
```

#### 7. company_info
```dart
id: TEXT PRIMARY KEY (single row, UUID)
name: TEXT
nameAr: TEXT (nullable)
address: TEXT (nullable)
addressAr: TEXT (nullable)
phone: TEXT (nullable)
email: TEXT (nullable)
vatNumber: TEXT (nullable)
crnNumber: TEXT (nullable)
logoPath: TEXT (nullable) - local file path
createdAt: TEXT
updatedAt: TEXT
```

### Database Access Patterns

```dart
// Get database instance
final database = AppDatabase();

// Example queries
final products = await database.getAllProducts();
final product = await database.getProductById(id);
await database.insertProduct(product);
await database.updateProduct(product);
await database.deleteProduct(id);

// Streams (for reactive UI)
database.watchAllProducts().listen((products) {
  // Update UI
});
```

### Migrations
```dart
// In drift_database.dart
@override
int get schemaVersion => 3;

@override
MigrationStrategy get migration {
  return MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        // Migration from v1 to v2
      }
      if (from < 3) {
        // Migration from v2 to v3
      }
    },
    beforeOpen: (details) async {
      // Seed data on first run
    },
  );
}
```

---

## State Management

### BLoC Pattern (Current Standard)

#### When to Use BLoC
- ✅ Feature-specific state (products, sales, customers)
- ✅ Business logic and validation
- ✅ Data fetching and caching
- ✅ Complex state transitions

#### BLoC Structure Example
```dart
// Event
abstract class ProductEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProductLoadRequested extends ProductEvent {}

class ProductCreated extends ProductEvent {
  final Product product;
  ProductCreated(this.product);

  @override
  List<Object?> get props => [product];
}

// State
abstract class ProductState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}
class ProductLoading extends ProductState {}
class ProductLoaded extends ProductState {
  final List<Product> products;
  ProductLoaded(this.products);

  @override
  List<Object?> get props => [products];
}
class ProductError extends ProductState {
  final String message;
  ProductError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final AppDatabase database;

  ProductBloc(this.database) : super(ProductInitial()) {
    on<ProductLoadRequested>(_onLoadRequested);
    on<ProductCreated>(_onCreated);
  }

  Future<void> _onLoadRequested(
    ProductLoadRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      final products = await database.getAllProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onCreated(
    ProductCreated event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await database.insertProduct(event.product);
      add(ProductLoadRequested()); // Reload
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}
```

#### Using BLoC in Widgets
```dart
// Trigger events
context.read<ProductBloc>().add(ProductLoadRequested());

// Listen to state (rebuild on change)
BlocBuilder<ProductBloc, ProductState>(
  builder: (context, state) {
    if (state is ProductLoading) {
      return CircularProgressIndicator();
    } else if (state is ProductLoaded) {
      return ListView(children: ...);
    } else if (state is ProductError) {
      return Text('Error: ${state.message}');
    }
    return SizedBox();
  },
)

// Listen to state (side effects)
BlocListener<ProductBloc, ProductState>(
  listener: (context, state) {
    if (state is ProductError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: ...,
)

// Combined
BlocConsumer<ProductBloc, ProductState>(
  listener: (context, state) { /* side effects */ },
  builder: (context, state) { /* UI */ },
)
```

### Provider Pattern (Legacy)

Still used for:
- Theme state (`ThemeProvider`)
- Locale state (`LocaleProvider`)

**Note**: New features should use BLoC, not Provider.

---

## Localization & RTL

### Supported Languages
- English (en) - 731 strings
- Arabic (ar) - 506 strings (ongoing translation)

### Adding Translations

#### 1. Add to ARB files
```json
// lib/l10n/app_en.arb
{
  "newFeatureTitle": "My New Feature",
  "@newFeatureTitle": {
    "description": "Title for the new feature screen"
  }
}

// lib/l10n/app_ar.arb
{
  "newFeatureTitle": "ميزتي الجديدة"
}
```

#### 2. Regenerate (automatic on next run)
```bash
flutter run  # Auto-generates
# or manually:
flutter gen-l10n
```

#### 3. Use in code
```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Text(AppLocalizations.of(context)!.newFeatureTitle)
```

### RTL Support

#### Automatic RTL
Flutter automatically handles RTL when locale is Arabic:
- `Row` → reversed
- `EdgeInsets.only(left: 10)` → right in RTL
- Text alignment → right in RTL

#### Force RTL for Arabic text
```dart
Directionality(
  textDirection: TextDirection.rtl,
  child: Text('نص عربي'),
)

// Or for specific text
Text(
  'نص عربي',
  textDirection: TextDirection.rtl,
)
```

#### Testing RTL
```dart
// Force RTL in MaterialApp (for testing)
MaterialApp(
  locale: Locale('ar'),
  // ...
)
```

### Translation Guidelines

**MANDATORY**: See `docs/ARABIC_TRANSLATION_REQUIREMENTS.md` for:
- Translation process
- Quality standards
- Cultural considerations
- Testing requirements

**Key points**:
- ALL user-facing strings must be localized
- Use descriptive keys (not abbreviations)
- Provide translator context in `@keyName` descriptions
- Test in both languages before committing
- Use proper Arabic typography (no Latin characters for Arabic words)

---

## Testing Strategy

### Current Test Coverage
- Basic widget tests (`test/widget_test.dart`)
- Invoice template tests (`test/invoice_template_test.dart`)
- Print format tests (`test/print_format_selector_test.dart`)

### Running Tests
```bash
# All tests
flutter test

# Specific file
flutter test test/invoice_template_test.dart

# With coverage
flutter test --coverage
```

### Testing Best Practices

#### 1. Widget Tests
```dart
testWidgets('Product list displays correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider(
        create: (_) => ProductBloc(mockDatabase),
        child: ProductsScreen(),
      ),
    ),
  );

  await tester.pump(); // Trigger build

  expect(find.text('Product 1'), findsOneWidget);
});
```

#### 2. BLoC Tests
```dart
blocTest<ProductBloc, ProductState>(
  'emits ProductLoaded when ProductLoadRequested is added',
  build: () => ProductBloc(mockDatabase),
  act: (bloc) => bloc.add(ProductLoadRequested()),
  expect: () => [
    ProductLoading(),
    ProductLoaded([mockProduct]),
  ],
);
```

#### 3. Database Tests
Use in-memory database for tests:
```dart
final database = AppDatabase.inMemory(); // If implemented
```

### Test Recommendations
- Write tests for critical business logic (sales calculations, VAT, etc.)
- Test BLoC state transitions
- Test invoice generation with various configurations
- Test RTL layout for Arabic
- Integration tests for complete user flows (login → sale → invoice)

---

## Common Tasks

### 1. Adding a New Screen

```dart
// 1. Create screen file
lib/screens/my_feature_screen.dart

// 2. Create BLoC if needed
lib/blocs/my_feature/
  ├── my_feature_bloc.dart
  ├── my_feature_event.dart
  └── my_feature_state.dart

// 3. Add route
// In main.dart or router
'/my-feature': (context) => MyFeatureScreen(),

// 4. Add translations
// app_en.arb: "myFeatureTitle": "My Feature"
// app_ar.arb: "myFeatureTitle": "ميزتي"

// 5. Add navigation
Navigator.pushNamed(context, '/my-feature');
```

### 2. Adding a New Database Table

```dart
// 1. Define table in lib/database/drift_database.dart
class MyTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  // ...

  @override
  Set<Column> get primaryKey => {id};
}

// 2. Add to @DriftDatabase annotation
@DriftDatabase(
  tables: [
    Users,
    Products,
    // ... existing tables
    MyTable,  // Add here
  ],
  daos: [],
)

// 3. Increment schemaVersion
@override
int get schemaVersion => 4;  // Was 3

// 4. Add migration
@override
MigrationStrategy get migration {
  return MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 4) {
        await migrator.createTable(myTable);
      }
    },
  );
}

// 5. Regenerate
flutter pub run build_runner build --delete-conflicting-outputs

// 6. Add CRUD methods in AppDatabase class
Future<List<MyTableData>> getAllMyData() => select(myTable).get();
```

### 3. Adding a New BLoC

```bash
# 1. Create directory
mkdir -p lib/blocs/my_feature

# 2. Create files (see State Management section for content)
touch lib/blocs/my_feature/my_feature_bloc.dart
touch lib/blocs/my_feature/my_feature_event.dart
touch lib/blocs/my_feature/my_feature_state.dart

# 3. Export in main.dart
# Add to MultiBlocProvider
BlocProvider<MyFeatureBloc>(
  create: (context) => MyFeatureBloc(database),
),
```

### 4. Modifying Invoice Templates

```dart
// Templates in: lib/services/invoice_templates/

// 1. Locate template (a4_invoice_template.dart, thermal_80mm, etc.)

// 2. Modify PDF widgets
// Use pdf package widgets: pw.Text, pw.Column, etc.

// 3. Test changes
// Run app → Create sale → Print invoice → Preview

// 4. Update tests if needed
// test/invoice_template_test.dart
```

### 5. Adding a New Translation

```dart
// 1. Add to app_en.arb
{
  "myNewKey": "English text",
  "@myNewKey": {
    "description": "Description for translator"
  }
}

// 2. Add to app_ar.arb
{
  "myNewKey": "النص العربي"
}

// 3. Use in code
Text(AppLocalizations.of(context)!.myNewKey)

// 4. Test in both languages
// Settings → Change language → Verify display
```

### 6. Configuring VAT Settings

```dart
// VAT settings stored in company_info table or app config

// 1. Enable/Disable VAT
// Settings → VAT Settings → Enable VAT toggle

// 2. Configure VAT rate
// Default: 15% (0.15)
// Editable in settings

// 3. VAT calculation modes
- VAT Included: Display price includes VAT
- VAT Excluded: VAT added at checkout

// 4. Invoice display
- Show/hide VAT breakdown
- Configurable VAT note text
```

### 7. Debugging Database Issues

```bash
# 1. Clear app data (development only)
flutter clean

# 2. Regenerate database code
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs

# 3. For web: Clear IndexedDB
# Browser DevTools → Application → IndexedDB → Delete retail_management_db

# 4. Check schema version
# lib/database/drift_database.dart → schemaVersion

# 5. Add debug prints
print('Current schema version: ${database.schemaVersion}');
```

---

## Important Gotchas

### 1. Database Code Generation
**Problem**: "Cannot find drift_database.g.dart" error
**Solution**: ALWAYS run `flutter pub run build_runner build --delete-conflicting-outputs` after:
- Cloning the repo
- Modifying database tables
- Switching branches with DB changes

### 2. Localization Not Working
**Problem**: Missing translations or `AppLocalizations` null
**Solution**:
- Ensure `generate: true` in `pubspec.yaml`
- Ensure `l10n.yaml` exists
- Run `flutter gen-l10n` or just run the app
- Wrap app with `MaterialApp.router` or `MaterialApp` with `localizationsDelegates`

### 3. Arabic Text Display Issues
**Problem**: Arabic text shows as boxes or disconnected letters
**Solution**:
- Ensure `NotoSansArabic` font is loaded (check `pubspec.yaml` fonts section)
- Use `textDirection: TextDirection.rtl` for Arabic text
- Verify font file exists: `assets/fonts/NotoSansArabic-Regular.ttf`

### 4. Theme Not Updating
**Problem**: Theme changes don't reflect immediately
**Solution**:
- Ensure `ThemeProvider` is listened to in `MaterialApp`
- Hot restart (not hot reload) after theme changes
- Check `SharedPreferences` persistence

### 5. BLoC State Not Updating
**Problem**: UI doesn't rebuild on state change
**Solution**:
- Ensure state classes override `props` getter (Equatable)
- Use `BlocBuilder` or `BlocConsumer`, not just `context.read`
- Emit new state instances (don't mutate existing state)
- Check if event is actually added: `context.read<Bloc>().add(event)`

### 6. Invoice Printing Issues
**Problem**: Invoice doesn't print or preview shows errors
**Solution**:
- Check `PrintFormat` configuration
- Verify all required data (company info, sale items) is present
- Test in browser (Web uses browser print dialog)
- Check PDF package version compatibility

### 7. Web Platform Limitations
**Problem**: Features work on mobile but not web
**Solution**:
- File operations: Use `web.dart` connection, IndexedDB
- Image picker: Has limitations on web (use fallback)
- Printing: Uses browser dialog (different from native)
- Check platform: `kIsWeb` from `package:flutter/foundation.dart`

### 8. Performance Issues
**Problem**: App slow or janky
**Solution**:
- Use `const` constructors where possible
- Avoid rebuilding entire tree (use `BlocBuilder` selectively)
- Use `RepaintBoundary` for expensive widgets
- Profile with Flutter DevTools
- Check for memory leaks (close streams, dispose controllers)

### 9. Git Push Failures (403)
**Problem**: Cannot push to remote
**Solution**:
- Verify branch name starts with `claude/`
- Ensure branch name matches session ID
- Use: `git push -u origin <correct-branch-name>`
- Retry with exponential backoff (2s, 4s, 8s, 16s) for network errors

### 10. Build Failures After Dependency Update
**Problem**: Build errors after `flutter pub upgrade`
**Solution**:
```bash
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

---

## Resources

### Documentation
- **Project Docs**: `/docs/` directory (17 comprehensive guides)
  - Start with: `DOCUMENTATION_INDEX.md`
  - Quickstart: `QUICKSTART.md`
  - Architecture: `FLUTTER_ARCHITECTURE.md`
  - Translations: `ARABIC_TRANSLATION_REQUIREMENTS.md`

### External Resources
- [Flutter Docs](https://flutter.dev/docs)
- [Drift Database](https://drift.simonbinder.eu/)
- [BLoC Library](https://bloclibrary.dev/)
- [Flutter Localization](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- [Material Design 3](https://m3.material.io/)

### Default Credentials (Development)
```
Admin:
  Username: admin
  Password: admin123

Cashier:
  Username: cashier
  Password: cashier123
```

### Key File Paths (Quick Reference)
```
Database: lib/database/drift_database.dart
Main Entry: lib/main.dart
Theme Config: lib/config/app_theme.dart
Translations: lib/l10n/app_en.arb, lib/l10n/app_ar.arb
Dependencies: pubspec.yaml
Localization Config: l10n.yaml
```

---

## AI Assistant Guidelines

### When Working on This Project

1. **ALWAYS** read relevant documentation first (`/docs` directory)
2. **NEVER** skip translation for new UI strings (English + Arabic required)
3. **ALWAYS** use BLoC pattern for new state management (not Provider)
4. **ALWAYS** test in both light and dark modes
5. **ALWAYS** test in both English and Arabic
6. **NEVER** hardcode colors (use `Theme.of(context).colorScheme`)
7. **ALWAYS** use responsive units (`ScreenUtil`: `.w`, `.h`, `.sp`)
8. **ALWAYS** regenerate after database changes (`build_runner`)
9. **ALWAYS** follow git branch naming: `claude/<session-id>`
10. **NEVER** commit generated files (`.g.dart`, `app_localizations_*.dart`)

### Before Making Changes
- [ ] Review existing similar implementations
- [ ] Check if translations exist for the feature
- [ ] Verify database schema version
- [ ] Understand the BLoC/event flow
- [ ] Review related documentation in `/docs`

### After Making Changes
- [ ] Run `flutter analyze` (should pass)
- [ ] Test in both languages
- [ ] Test in both light/dark modes
- [ ] Verify responsive design on different screen sizes
- [ ] Update relevant documentation if needed
- [ ] Add/update tests if applicable
- [ ] Commit with clear message: `feat:`, `fix:`, `docs:`, etc.

---

**Document Version**: 1.0
**Last Updated**: 2025-11-14
**Maintainer**: AI Assistants working on this project
**Status**: Active, comprehensive guide for all development work

For questions or updates to this guide, modify this file and commit with clear reasoning.
