# Flutter Retail Management App - Quick Reference Guide

## Essential File Locations

### Core Application Files
| File | Purpose | Lines |
|------|---------|-------|
| `lib/main.dart` | App entry point, provider setup, theme, routing | 117 |
| `pubspec.yaml` | Dependencies and assets | 72 |

### State Management (Providers)
| File | Manages | Key Methods |
|------|---------|------------|
| `lib/providers/auth_provider.dart` | Authentication, session | login(), logout(), checkAuthStatus() |
| `lib/providers/user_provider.dart` | Staff users, sales stats | loadUsers(), addUser(), updateUser(), deleteUser() |
| `lib/providers/product_provider.dart` | Products, categories | loadProducts(), addProduct(), updateProduct() |
| `lib/providers/customer_provider.dart` | Customers | loadCustomers(), addCustomer(), updateCustomer() |
| `lib/providers/sale_provider.dart` | Sales/invoices | loadSales(), createSale(), generateInvoice() |

### UI Screens
| File | Purpose | Role |
|------|---------|------|
| `lib/screens/login_screen.dart` | User authentication | All |
| `lib/screens/dashboard_screen.dart` | Main navigation hub | Admin, Cashier |
| `lib/screens/cashier_screen.dart` | Point of sale | Cashier |
| `lib/screens/products_screen.dart` | Product management | Admin |
| `lib/screens/categories_screen.dart` | Category management | Admin |
| `lib/screens/customers_screen.dart` | Customer management | Admin |
| `lib/screens/users_screen.dart` | Staff management | Admin only |
| `lib/screens/settings_screen.dart` | App configuration | Admin |

### Database & Services
| File | Type | Purpose |
|------|------|---------|
| `lib/database/drift_database.dart` | Database | Main Drift database with all CRUD operations |
| `lib/database/connection/` | Connection | Platform-specific database connections |
| `lib/services/auth_service.dart` | Service | Authentication, session, permissions |
| `lib/services/invoice_service.dart` | Service | PDF generation and printing |
| `lib/services/sync_service.dart` | Service | Server synchronization |

### Models & Utils
| File | Purpose |
|------|---------|
| `lib/models/` | Data models (User, Product, Customer, Sale, Category, CompanyInfo) |
| `lib/utils/zatca_qr_generator.dart` | ZATCA (Saudi Tax Authority) QR code generation |

---

## Development Workflow

### Adding a New Feature

1. **Create the Model** (if needed)
   ```
   lib/models/your_model.dart
   ```

2. **Create/Update the Provider**
   ```
   lib/providers/your_provider.dart
   ```
   - Extend `ChangeNotifier`
   - Define state variables
   - Provide getters
   - Implement async methods
   - Call `notifyListeners()`

3. **Update Database** (if needed)
   - Add table to `drift_database.dart`
   - Add CRUD methods
   - Run: `flutter pub run build_runner build`

4. **Create/Update the Screen**
   ```
   lib/screens/your_screen.dart
   ```
   - Use `Consumer<YourProvider>` for state
   - Access provider via `context.read<YourProvider>()`
   - Dispatch actions on user interaction

5. **Add to Navigation**
   - Update `dashboard_screen.dart`
   - Add menu item or navigation button

---

## Key Architecture Patterns

### Provider State Access Pattern
```dart
// Read (one-time access)
context.read<AuthProvider>().logout();

// Watch (reactive updates)
Consumer<AuthProvider>(
  builder: (context, authProvider, _) {
    return Text('User: ${authProvider.currentUser?.fullName}');
  },
)

// Listen (side effects)
context.listen<AuthProvider>((provider) {
  // React to changes
});
```

### Async Operation Pattern
```dart
// In Provider:
Future<void> myOperation() async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();
  
  try {
    // Do work
    _errorMessage = null;
  } catch (e) {
    _errorMessage = 'Failed: ${e.toString()}';
  }
  
  _isLoading = false;
  notifyListeners();
}

// In Screen:
ElevatedButton(
  onPressed: () {
    context.read<MyProvider>().myOperation();
  },
  child: const Text('Action'),
)
```

### Responsive Design
```dart
// Using ScreenUtil (already configured for 1920x1080)
import 'package:flutter_screenutil/flutter_screenutil.dart';

Padding(
  padding: EdgeInsets.all(16.w),  // Width-based
  child: Text(
    'Hello',
    style: TextStyle(fontSize: 16.sp),  // Size-based
  ),
)
```

---

## Common Development Tasks

### Create a New Screen
```
1. Create file: lib/screens/new_screen.dart
2. Use Consumer for provider access
3. Add to dashboard navigation
4. Import necessary providers
```

### Add a Provider Method
```dart
class MyProvider with ChangeNotifier {
  Future<void> myNewMethod() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Implementation
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### Access User Role
```dart
// In Provider:
final authProvider = context.read<AuthProvider>();
bool isAdmin = authProvider.isAdmin;
bool isCashier = authProvider.isCashier;

// For permission checks:
final authService = AuthService();
bool hasPermission = await authService.isAdmin();
```

### Work with Database
```dart
final db = AppDatabase();

// Query
final users = await db.getAllUsers();
final user = await db.getUserById('id');

// Create
await db.createUser(user);

// Update
await db.updateUser(updatedUser);

// Delete
await db.deleteUser('id');
```

---

## Configuration & Settings

### App Title
- `pubspec.yaml`: `name: retail_management`
- `lib/main.dart` line 35: `title: 'Retail Management System'`

### Design Size (Responsive)
- `lib/main.dart` line 30: `designSize: const Size(1920, 1080)`

### Primary Theme Color
- `lib/main.dart` line 38: `primarySwatch: Colors.blue`

### Material Design Version
- `lib/main.dart` line 39: `useMaterial3: true`

### Database
- Type: Drift (SQLite)
- Tables: 6 main tables
- Default: In-memory for web, file-based for mobile

### Authentication
- Method: Username/Password
- Storage: SharedPreferences (session)
- Database: Users table
- Roles: admin, cashier

---

## Important Dependencies

### What's Installed & Used
- `provider: ^6.1.1` - State management
- `drift: ^2.14.0` - Database
- `intl: ^0.19.0` - Localization (installed but not used)
- `flutter_screenutil: ^5.9.0` - Responsive design
- `shared_preferences: ^2.2.2` - Session storage

### What's Available for Enhancement
- `intl: ^0.19.0` - Ready for localization
- Material 3 - Ready for theme enhancement

---

## Database Schema Quick View

```
Users
├── id (PK)
├── username
├── password
├── fullName
├── role (admin/cashier)
├── isActive
├── createdAt
└── lastLoginAt

Products ←─ Categories
├── id (PK)          ├── id (PK)
├── name             ├── name
├── barcode          ├── description
├── price            ├── imageUrl
├── quantity         ├── isActive
├── categoryId (FK)  ├── createdAt
├── vatRate          └── updatedAt
├── createdAt
└── updatedAt

Customers
├── id (PK)
├── name
├── email
├── phone
├── crnNumber
├── vatNumber
└── saudiAddress

Sales ←─ Users ←─ Products
├── id (PK)
├── invoiceNumber
├── customerId
├── cashierId (FK)
├── saleDate
├── subtotal
├── vatAmount
├── totalAmount
├── paidAmount
├── changeAmount
├── status
├── paymentMethod
├── notes
└── isPrinted
```

---

## Useful Commands

```bash
# Get dependencies
flutter pub get

# Generate code (Drift database)
flutter pub run build_runner build

# Generate localization files (future)
flutter gen-l10n

# Run app
flutter run

# Build APK (Android)
flutter build apk

# Build for Web
flutter build web

# Clean build
flutter clean

# Run tests
flutter test

# Analyze code
flutter analyze
```

---

## Best Practices Used in This Project

1. **Provider Pattern**: ChangeNotifier for state management
2. **Separation of Concerns**: UI, Business Logic, Data layers
3. **Async Operations**: Proper loading/error state handling
4. **Type Safety**: Dart's strong typing for models
5. **Responsive Design**: ScreenUtil for multiple screen sizes
6. **Database**: Type-safe Drift ORM
7. **Authentication**: Role-based access control
8. **Session Management**: SharedPreferences storage

---

## For Implementing Theme & Localization

### Files You'll Need to Create

**Theme Support**:
- `lib/config/app_theme.dart` - Theme definitions (light/dark)
- `lib/providers/theme_provider.dart` - Theme state management

**Localization Support**:
- `lib/l10n/app_en.arb` - English translations
- `lib/l10n/app_ar.arb` - Arabic translations
- `lib/providers/localization_provider.dart` - Language state management

### Files You'll Need to Modify

- `lib/main.dart` - Add providers, update MaterialApp
- `pubspec.yaml` - Enable localization generation
- `lib/screens/settings_screen.dart` - Add theme/language controls
- All screen files - Replace hardcoded strings with localized versions

### Estimated Effort
- Theme: 2-3 hours
- Localization: 3-4 hours
- Testing: 1-2 hours
- **Total: 6-9 hours**

---

## Debugging Tips

### Provider Issues
```dart
// Check if provider is in MultiProvider
// Check if using correct provider type
// Use Consumer for debugging provider state
```

### State Updates Not Showing
```dart
// Ensure notifyListeners() is called
// Check if using Consumer or context.watch()
// Not using context.read() for watching state
```

### Database Errors
```dart
// Run: flutter pub run build_runner build
// Verify table definitions in drift_database.dart
// Check database initialization
```

### Responsive Design Issues
```dart
// Check ScreenUtil initialization
// Use .w, .h, .sp for responsive sizing
// Test on different screen sizes
```

---

## Key Contacts & Resources

### Documentation
- Flutter: https://flutter.dev/docs
- Provider: https://pub.dev/packages/provider
- Drift: https://drift.simonbinder.eu/
- intl: https://pub.dev/packages/intl

### Project Documentation
- `FLUTTER_ANALYSIS_SUMMARY.md` - Executive summary
- `FLUTTER_PROJECT_STRUCTURE.md` - Detailed structure
- `FLUTTER_ARCHITECTURE.md` - Architecture diagrams
- `THEME_LOCALIZATION_INTEGRATION.md` - Integration guide
- `MIGRATION.md` - Database migration notes

