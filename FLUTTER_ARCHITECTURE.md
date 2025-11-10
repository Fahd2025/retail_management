# Flutter Architecture & Data Flow Diagram

## 1. Application Layer Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                          MyApp Widget                            │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              MultiProvider (State Setup)                    │ │
│  │  ┌──────────────────────────────────────────────────────┐  │ │
│  │  │ - AuthProvider          (Authentication & Session)  │  │ │
│  │  │ - ProductProvider       (Product Management)        │  │ │
│  │  │ - CustomerProvider      (Customer Management)       │  │ │
│  │  │ - SaleProvider          (Sales/Invoice)            │  │ │
│  │  │ - UserProvider          (Staff Management)         │  │ │
│  │  └──────────────────────────────────────────────────────┘  │ │
│  │                                                              │ │
│  │  ┌────────────────────────────────────────────────────────┐ │ │
│  │  │            ScreenUtilInit (Responsive UI)            │ │ │
│  │  │            Design Size: 1920x1080                    │ │ │
│  │  └────────────────────────────────────────────────────────┘ │ │
│  │                                                              │ │
│  │  ┌────────────────────────────────────────────────────────┐ │ │
│  │  │              MaterialApp (Theme)                       │ │ │
│  │  │  - Primary Color: Blue                               │ │ │
│  │  │  - Material 3 Enabled                                │ │ │
│  │  │  - Home: AuthWrapper (Routing)                       │ │ │
│  │  └────────────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## 2. State Management Data Flow

```
User Action (e.g., Login)
    │
    ▼
Screen Widget (e.g., LoginScreen)
    │
    ├─ Reads Provider (Provider.of<AuthProvider>)
    │
    ▼
AuthProvider (ChangeNotifier)
    │
    ├─ Updates internal state (_isLoading, _currentUser, _errorMessage)
    │
    ├─ Calls notifyListeners()
    │
    ▼
AuthService (Business Logic)
    │
    ├─ Calls DatabaseHelper methods
    │
    ├─ Updates SharedPreferences
    │
    ▼
AppDatabase (Drift - Data Layer)
    │
    ├─ Queries SQLite
    │
    ▼
UI Rebuilds via Consumer<AuthProvider>
    │
    └─ Displays new state
```

## 3. Database Schema Overview

```
┌──────────────────────┐
│       Users          │
├──────────────────────┤
│ id (PK)              │
│ username             │
│ password             │
│ fullName             │
│ role (admin/cashier) │
│ isActive             │
│ createdAt            │
│ lastLoginAt          │
└──────────────────────┘

┌──────────────────────┐      ┌──────────────────────┐
│    Categories        │      │     Products         │
├──────────────────────┤      ├──────────────────────┤
│ id (PK)              │      │ id (PK)              │
│ name                 │      │ name                 │
│ description          │◄─────│ categoryId (FK)      │
│ imageUrl             │      │ barcode              │
│ isActive             │      │ price                │
│ createdAt            │      │ quantity             │
│ updatedAt            │      │ imageUrl             │
│ needsSync            │      │ vatRate              │
└──────────────────────┘      │ createdAt            │
                              │ updatedAt            │
                              │ needsSync            │
                              └──────────────────────┘

┌──────────────────────┐      ┌──────────────────────┐
│    Customers         │      │      Sales           │
├──────────────────────┤      ├──────────────────────┤
│ id (PK)              │      │ id (PK)              │
│ name                 │      │ invoiceNumber        │
│ email                │      │ customerId (FK)      │
│ phone                │      │ cashierId (FK)       │
│ crnNumber            │      │ saleDate             │
│ vatNumber            │      │ subtotal             │
│ saudiAddress         │      │ vatAmount            │
│ isActive             │      │ totalAmount          │
│ createdAt            │      │ paidAmount           │
│ updatedAt            │      │ changeAmount         │
│ needsSync            │      │ status               │
└──────────────────────┘      │ paymentMethod        │
                              │ isPrinted            │
                              │ needsSync            │
                              └──────────────────────┘

┌──────────────────────┐
│    SaleItems         │
├──────────────────────┤
│ id (PK)              │
│ saleId (FK)          │
│ productId (FK)       │
│ quantity             │
│ unitPrice            │
│ subtotal             │
│ vatAmount            │
│ totalAmount          │
└──────────────────────┘
```

## 4. Screen Navigation Structure

```
┌────────────────────┐
│  AuthWrapper       │
│  (Routing Logic)   │
└─────┬──────────────┘
      │
      ├─ isLoggedIn = false ──────┐
      │                           │
      │                    ┌──────▼──────────┐
      │                    │  LoginScreen    │
      │                    │  (Email/Pass)   │
      │                    └──────┬──────────┘
      │                           │
      │ ┌──────────────────────────┘
      │ │
      └─┴─ isLoggedIn = true
          │
      ┌───▼────────────────────┐
      │  DashboardScreen       │
      │  (Navigation Hub)      │
      └───┬────────────────────┘
          │
          ├──► CashierScreen (Point of Sale)
          ├──► ProductsScreen (Product Mgmt)
          ├──► CategoriesScreen (Category Mgmt)
          ├──► CustomersScreen (Customer Mgmt)
          ├──► UsersScreen (Staff Mgmt)
          ├──► SalesScreen (Sales History)
          └──► SettingsScreen (Configuration)
```

## 5. Provider Dependencies & Relationships

```
┌─────────────────────────────────────┐
│      AuthProvider                   │
│  - currentUser                      │
│  - isLoggedIn                       │
│  - isAdmin / isCashier             │
│  - login() / logout()               │
│  - checkAuthStatus()                │
│                                     │
│  Dependencies:                      │
│  ├─ AuthService                    │
│  └─ AppDatabase                    │
└─────────────────────────────────────┘
                                      
┌─────────────────────────────────────┐
│      ProductProvider                │
│  - products[]                       │
│  - categories[]                     │
│  - loadProducts()                   │
│  - addProduct()                     │
│  - updateProduct()                  │
│  - deleteProduct()                  │
│  - getProductByBarcode()            │
│                                     │
│  Dependencies:                      │
│  └─ AppDatabase                    │
└─────────────────────────────────────┘
                                      
┌─────────────────────────────────────┐
│      CustomerProvider               │
│  - customers[]                      │
│  - loadCustomers()                  │
│  - addCustomer()                    │
│  - updateCustomer()                 │
│  - deleteCustomer()                 │
│                                     │
│  Dependencies:                      │
│  └─ AppDatabase                    │
└─────────────────────────────────────┘
                                      
┌─────────────────────────────────────┐
│      SaleProvider                   │
│  - sales[]                          │
│  - loadSales()                      │
│  - createSale()                     │
│  - updateSale()                     │
│  - generateInvoice()                │
│                                     │
│  Dependencies:                      │
│  ├─ AppDatabase                    │
│  └─ InvoiceService                 │
└─────────────────────────────────────┘
                                      
┌─────────────────────────────────────┐
│      UserProvider                   │
│  - users[]                          │
│  - userSalesStats{}                 │
│  - loadUsers()                      │
│  - addUser()                        │
│  - updateUser()                     │
│  - deleteUser()                     │
│                                     │
│  Dependencies:                      │
│  └─ AppDatabase                    │
└─────────────────────────────────────┘
```

## 6. Service Layer Architecture

```
┌─────────────────────────────────────┐
│        AuthService                  │
│  - login()                          │
│  - logout()                         │
│  - getCurrentUser()                 │
│  - getCurrentUserRole()             │
│  - isAdmin()                        │
│                                     │
│  Uses:                              │
│  ├─ AppDatabase                    │
│  └─ SharedPreferences              │
└─────────────────────────────────────┘
                                      
┌─────────────────────────────────────┐
│      InvoiceService                 │
│  - generatePDF()                    │
│  - printInvoice()                   │
│                                     │
│  Uses:                              │
│  ├─ pdf package                    │
│  ├─ printing package               │
│  └─ ZatcaQrGenerator               │
└─────────────────────────────────────┘
                                      
┌─────────────────────────────────────┐
│       SyncService                   │
│  - syncToServer()                   │
│  - fetchFromServer()                │
│                                     │
│  Uses:                              │
│  ├─ http package                   │
│  ├─ connectivity_plus              │
│  └─ AppDatabase                    │
└─────────────────────────────────────┘
```

## 7. Persistence & Storage Strategy

```
┌──────────────────────────────────────────────────┐
│           Storage Layers                         │
├──────────────────────────────────────────────────┤
│                                                  │
│  SharedPreferences (Session)                     │
│  ├─ user_id                                      │
│  ├─ username                                     │
│  └─ user_role                                    │
│                                                  │
│  Drift/SQLite Database                          │
│  ├─ All business data (Products, Orders, etc)   │
│  └─ Sync status (needsSync flag)                │
│                                                  │
│  Potential Future Additions:                     │
│  ├─ Theme Preference (light/dark)               │
│  ├─ Language Preference (en/ar)                 │
│  └─ UI Preferences                              │
│                                                  │
└──────────────────────────────────────────────────┘
```

