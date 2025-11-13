// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Retail Management System';

  @override
  String get appSubtitle => 'Point of Sale System';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get refresh => 'Refresh';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get confirm => 'Confirm';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get close => 'Close';

  @override
  String get submit => 'Submit';

  @override
  String get loginTitle => 'Retail Management';

  @override
  String get loginSubtitle => 'Point of Sale System';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get login => 'LOGIN';

  @override
  String get logout => 'Logout';

  @override
  String get pleaseEnterUsername => 'Please enter username';

  @override
  String get pleaseEnterPassword => 'Please enter password';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get invalidCredentials => 'Invalid username or password';

  @override
  String get initializingSystem => 'Initializing system...';

  @override
  String initializationError(String error) {
    return 'Initialization error: $error';
  }

  @override
  String get dashboard => 'Dashboard';

  @override
  String get welcome => 'Welcome';

  @override
  String get totalSales => 'Total Sales';

  @override
  String get totalProducts => 'Total Products';

  @override
  String get totalCustomers => 'Total Customers';

  @override
  String get recentSales => 'Recent Sales';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get viewAll => 'View All';

  @override
  String get statistics => 'Statistics';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get products => 'Products';

  @override
  String get productList => 'Product List';

  @override
  String get addProduct => 'Add Product';

  @override
  String get editProduct => 'Edit Product';

  @override
  String get deleteProduct => 'Delete Product';

  @override
  String get productName => 'Product Name';

  @override
  String get productCode => 'Product Code';

  @override
  String get price => 'Price';

  @override
  String get cost => 'Cost';

  @override
  String get quantity => 'Quantity';

  @override
  String get category => 'Category';

  @override
  String get description => 'Description';

  @override
  String get barcode => 'Barcode';

  @override
  String get inStock => 'In Stock';

  @override
  String get outOfStock => 'Out of Stock';

  @override
  String get lowStock => 'Low Stock';

  @override
  String get productDetails => 'Product Details';

  @override
  String get stockLevel => 'Stock Level';

  @override
  String get categories => 'Categories';

  @override
  String get addCategory => 'Add Category';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get deleteCategory => 'Delete Category';

  @override
  String get categoryName => 'Category Name';

  @override
  String get categoryDescription => 'Category Description';

  @override
  String get customers => 'Customers';

  @override
  String get customerList => 'Customer List';

  @override
  String get addCustomer => 'Add Customer';

  @override
  String get editCustomer => 'Edit Customer';

  @override
  String get deleteCustomer => 'Delete Customer';

  @override
  String get customerName => 'Customer Name';

  @override
  String get customerCode => 'Customer Code';

  @override
  String get phone => 'Phone';

  @override
  String get email => 'Email';

  @override
  String get address => 'Address';

  @override
  String get customerDetails => 'Customer Details';

  @override
  String get totalPurchases => 'Total Purchases';

  @override
  String get customerInformation => 'Customer Information';

  @override
  String get customer => 'Customer';

  @override
  String get customerId => 'Customer ID';

  @override
  String get sales => 'Sales';

  @override
  String get salesList => 'Sales List';

  @override
  String get newSale => 'New Sale';

  @override
  String get saleDetails => 'Sale Details';

  @override
  String get invoiceNumber => 'Invoice Number';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get items => 'Items';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get discount => 'Discount';

  @override
  String get tax => 'Tax';

  @override
  String get total => 'Total';

  @override
  String get payment => 'Payment';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get cash => 'Cash';

  @override
  String get card => 'Card';

  @override
  String get change => 'Change';

  @override
  String get printInvoice => 'Print Invoice';

  @override
  String get completeSale => 'Complete Sale';

  @override
  String get users => 'Users';

  @override
  String get userList => 'User List';

  @override
  String get addUser => 'Add User';

  @override
  String get editUser => 'Edit User';

  @override
  String get deleteUser => 'Delete User';

  @override
  String get fullName => 'Full Name';

  @override
  String get role => 'Role';

  @override
  String get admin => 'Admin';

  @override
  String get cashier => 'Cashier';

  @override
  String get createdAt => 'Created At';

  @override
  String get lastLogin => 'Last Login';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get settings => 'Settings';

  @override
  String get generalSettings => 'General Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get changeTheme => 'Change Theme';

  @override
  String get preferences => 'Preferences';

  @override
  String get notifications => 'Notifications';

  @override
  String get backup => 'Backup';

  @override
  String get restore => 'Restore';

  @override
  String get about => 'About';

  @override
  String get saveSuccess => 'Saved successfully';

  @override
  String get deleteSuccess => 'Deleted successfully';

  @override
  String get updateSuccess => 'Updated successfully';

  @override
  String get saveFailed => 'Save failed';

  @override
  String get deleteFailed => 'Delete failed';

  @override
  String get updateFailed => 'Update failed';

  @override
  String get confirmDelete => 'Are you sure you want to delete this item?';

  @override
  String get confirmLogout => 'Are you sure you want to logout?';

  @override
  String get confirmExit => 'Are you sure you want to exit the application?';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get noItemsFound => 'No items found';

  @override
  String get searchResults => 'Search Results';

  @override
  String get requiredField => 'This field is required';

  @override
  String get invalidEmail => 'Invalid email address';

  @override
  String get invalidPhone => 'Invalid phone number';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get enterValidEmail => 'Please enter a valid email';

  @override
  String get enterValidPhone => 'Please enter a valid phone number';

  @override
  String get enterValidPrice => 'Please enter a valid price';

  @override
  String get enterValidQuantity => 'Please enter a valid quantity';

  @override
  String get nameTooShort => 'Name is too short';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get view => 'View';

  @override
  String get print => 'Print';

  @override
  String get export => 'Export';

  @override
  String get import => 'Import';

  @override
  String get download => 'Download';

  @override
  String get upload => 'Upload';

  @override
  String get share => 'Share';

  @override
  String get copy => 'Copy';

  @override
  String get paste => 'Paste';

  @override
  String get clear => 'Clear';

  @override
  String get reset => 'Reset';

  @override
  String get apply => 'Apply';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get custom => 'Custom';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get selectDate => 'Select Date';

  @override
  String get selectTime => 'Select Time';

  @override
  String get cashierMode => 'Cashier Mode';

  @override
  String get scanBarcode => 'Scan Barcode';

  @override
  String get addItem => 'Add Item';

  @override
  String get removeItem => 'Remove Item';

  @override
  String get clearCart => 'Clear Cart';

  @override
  String get checkout => 'Checkout';

  @override
  String get paymentReceived => 'Payment Received';

  @override
  String get returnChange => 'Return Change';

  @override
  String get saleCompleted => 'Sale Completed';

  @override
  String get thankYou => 'Thank you!';

  @override
  String get reports => 'Reports';

  @override
  String get salesReport => 'Sales Report';

  @override
  String get inventoryReport => 'Inventory Report';

  @override
  String get customerReport => 'Customer Report';

  @override
  String get generateReport => 'Generate Report';

  @override
  String get reportPeriod => 'Report Period';

  @override
  String get companyInformation => 'Company Information';

  @override
  String get companyNameEnglish => 'Company Name (English)';

  @override
  String get companyNameArabic => 'Company Name (Arabic)';

  @override
  String get addressEnglish => 'Address (English)';

  @override
  String get addressArabic => 'Address (Arabic)';

  @override
  String get required => 'Required';

  @override
  String get vatNumber => 'VAT Number';

  @override
  String get crnNumber => 'CRN Number';

  @override
  String get saveCompanyInformation => 'Save Company Information';

  @override
  String get companyInfoSavedSuccess => 'Company info saved successfully';

  @override
  String errorLoadingCompanyInfo(String error) {
    return 'Error loading company info: $error';
  }

  @override
  String errorSaving(String error) {
    return 'Error saving: $error';
  }

  @override
  String get changesAppliedImmediately => 'Changes will be applied immediately';

  @override
  String get dataSynchronization => 'Data Synchronization';

  @override
  String get syncDescription =>
      'Sync your local data with the cloud when internet connection is available.';

  @override
  String get syncing => 'Syncing...';

  @override
  String get syncNow => 'Sync Now';

  @override
  String get version => 'Version';

  @override
  String get appVersion => '1.0.0';

  @override
  String get posWithOfflineSupport => 'Point of Sale with Offline Support';

  @override
  String get pointOfSale => 'Point of Sale';

  @override
  String get productsManagement => 'Products Management';

  @override
  String get customersManagement => 'Customers Management';

  @override
  String get usersManagement => 'Users Management';

  @override
  String get cannotDeleteCategory => 'Cannot Delete Category';

  @override
  String get categoryHasProducts =>
      'This category has products associated with it';

  @override
  String deleteProductConfirm(String productName) {
    return 'Delete $productName?';
  }

  @override
  String deleteCategoryConfirm(String categoryName) {
    return 'Delete $categoryName? This action cannot be undone.';
  }

  @override
  String get deleteCustomerConfirm =>
      'Are you sure you want to delete this customer?';

  @override
  String deleteUserConfirm(String username) {
    return 'Delete user $username? This action cannot be undone.';
  }

  @override
  String get returnSale => 'Return Sale';

  @override
  String returnSaleConfirm(String invoiceNumber) {
    return 'Return sale $invoiceNumber?';
  }

  @override
  String get printInvoiceQuestion => 'Would you like to print the invoice?';

  @override
  String get complete => 'Complete';

  @override
  String get name => 'Name';

  @override
  String get stock => 'Stock';

  @override
  String get vat => 'VAT %';

  @override
  String get actions => 'Actions';

  @override
  String get status => 'Status';

  @override
  String get invoiceCount => 'Invoice Count';

  @override
  String get noSalesFound => 'No sales found';

  @override
  String get noCustomersFound => 'No customers found';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get noUsersFound => 'No users found';

  @override
  String get cannotDeleteOwnAccount => 'You cannot delete your own account';

  @override
  String get selectACategory => 'Select a category';

  @override
  String get invalid => 'Invalid';

  @override
  String get units => 'units';

  @override
  String failedToLoadCategories(String error) {
    return 'Failed to load categories: $error';
  }

  @override
  String get descriptionOptional => 'Description (Optional)';

  @override
  String get pleaseEnterCategoryName => 'Please enter a category name';

  @override
  String get categoryAddedSuccess => 'Category added successfully';

  @override
  String get categoryUpdatedSuccess => 'Category updated successfully';

  @override
  String get categoryDeletedSuccess => 'Category deleted successfully';

  @override
  String errorSavingCategory(String error) {
    return 'Error saving category: $error';
  }

  @override
  String errorDeletingCategory(String error) {
    return 'Error deleting category: $error';
  }

  @override
  String get noCategoriesFound => 'No categories found';

  @override
  String productCount(int count) {
    return '$count product(s)';
  }

  @override
  String get tooltipEdit => 'Edit';

  @override
  String get tooltipDelete => 'Delete';

  @override
  String get userDeletedSuccess => 'User deleted successfully';

  @override
  String get failedToDeleteUser => 'Failed to delete user';

  @override
  String get usernameLabel => 'Username';

  @override
  String get roleLabel => 'Role';

  @override
  String get statusLabel => 'Status';

  @override
  String get userCreatedSuccess => 'User created successfully';

  @override
  String get userUpdatedSuccess => 'User updated successfully';

  @override
  String get anErrorOccurred => 'An error occurred';

  @override
  String get usernameRequired => 'Username is required';

  @override
  String get usernameMinLength => 'Username must be at least 3 characters';

  @override
  String get fullNameRequired => 'Full name is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get passwordLeaveEmpty => 'Password (leave empty to keep current)';

  @override
  String get companyInfoNotConfigured => 'Company info not configured';

  @override
  String printError(String error) {
    return 'Print error: $error';
  }

  @override
  String get invoice => 'Invoice';

  @override
  String invoiceLabel(String invoiceNumber) {
    return 'Invoice: $invoiceNumber';
  }

  @override
  String dateLabel(String date) {
    return 'Date: $date';
  }

  @override
  String totalLabel(String total) {
    return 'Total: SAR $total';
  }

  @override
  String statusLabelText(String status) {
    return 'Status: $status';
  }

  @override
  String get completed => 'Completed';

  @override
  String get returned => 'Returned';

  @override
  String get reprint => 'Reprint';

  @override
  String get return_sale => 'Return';

  @override
  String get itemsLabel => 'Items:';

  @override
  String get subtotalLabel => 'Subtotal:';

  @override
  String get vatLabel => 'VAT:';

  @override
  String get totalLabelColon => 'Total:';

  @override
  String get paidLabel => 'Paid:';

  @override
  String get changeLabel => 'Change:';

  @override
  String get saleReturnedSuccess => 'Sale returned successfully';

  @override
  String get errorLoadingCategories => 'Error loading categories';

  @override
  String get productNameRequired => 'Product Name *';

  @override
  String get barcodeRequired => 'Barcode *';

  @override
  String get categoryRequired => 'Category *';

  @override
  String get priceRequired => 'Price *';

  @override
  String get costRequired => 'Cost *';

  @override
  String get quantityRequired => 'Quantity *';

  @override
  String get vatRateRequired => 'VAT % *';

  @override
  String get usernameFieldLabel => 'Username *';

  @override
  String get fullNameFieldLabel => 'Full Name *';

  @override
  String get passwordFieldLabel => 'Password *';

  @override
  String get roleFieldLabel => 'Role *';

  @override
  String get nameFieldLabel => 'Name';

  @override
  String get customerNameRequired => 'Customer Name *';

  @override
  String get emailFieldLabel => 'Email';

  @override
  String get phoneFieldLabel => 'Phone';

  @override
  String get vatNumberFieldLabel => 'VAT Number';

  @override
  String get crnNumberFieldLabel => 'CRN Number';

  @override
  String get saudiNationalAddress => 'Saudi National Address';

  @override
  String get buildingNumber => 'Building Number';

  @override
  String get streetName => 'Street Name';

  @override
  String get district => 'District';

  @override
  String get city => 'City';

  @override
  String get postalCode => 'Postal Code';

  @override
  String get additionalNumber => 'Additional Number';

  @override
  String phoneLabel(String phone) {
    return 'Phone: $phone';
  }

  @override
  String emailLabel(String email) {
    return 'Email: $email';
  }

  @override
  String vatLabel2(String vatNumber) {
    return 'VAT';
  }

  @override
  String addressLabel(String address) {
    return 'Address: $address';
  }

  @override
  String get cart => 'Cart';

  @override
  String cartItems(int count) {
    return '$count items';
  }

  @override
  String get cartIsEmpty => 'Cart is empty';

  @override
  String get scanOrEnterBarcode => 'Scan or enter barcode...';

  @override
  String productAddedToCart(String productName) {
    return '$productName added to cart';
  }

  @override
  String get productNotFound => 'Product not found';

  @override
  String get subtotalColon => 'Subtotal:';

  @override
  String get vatColon => 'VAT:';

  @override
  String get totalColon => 'Total:';

  @override
  String get walkInCustomer => 'Walk-in Customer';

  @override
  String get amountPaid => 'Amount Paid';

  @override
  String changeColon(String amount) {
    return 'Change: SAR $amount';
  }

  @override
  String get insufficientPayment => 'Insufficient payment';

  @override
  String get cashPayment => 'Cash';

  @override
  String get cardPayment => 'Card';

  @override
  String get transferPayment => 'Transfer';

  @override
  String get allDataSynchronized => 'All data is already synchronized';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String successfullySynchronized(int count) {
    return 'Successfully synchronized $count items';
  }

  @override
  String get syncFailed => 'Sync failed';

  @override
  String get exportInvoicesToPdf => 'Export Invoices to PDF';

  @override
  String get exportCustomerInvoices => 'Export Customer Invoices to PDF';

  @override
  String customerLabel(String name) {
    return 'Customer: $name';
  }

  @override
  String get selectPeriod => 'Select Period:';

  @override
  String get allTime => 'All Time';

  @override
  String get lastMonth => 'Last Month';

  @override
  String get lastThreeMonths => 'Last 3 Months';

  @override
  String get lastYear => 'Last Year';

  @override
  String get customDateRange => 'Custom Date Range';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get preview => 'Preview';

  @override
  String totalInvoices(int count) {
    return 'Total Invoices: $count';
  }

  @override
  String totalAmount(String amount) {
    return 'Total Amount: $amount';
  }

  @override
  String get exporting => 'Exporting...';

  @override
  String get exportToPdf => 'Export to PDF';

  @override
  String get loadingStatistics => 'Loading statistics...';

  @override
  String get invoices => 'Invoices';

  @override
  String invoicesCount(int count) {
    return 'Invoices: $count';
  }

  @override
  String invoicesTotal(int count, String total) {
    return 'Invoices: $count | Total: $total';
  }

  @override
  String get companyInfoNotFound =>
      'Company information not found. Please configure in Settings.';

  @override
  String get noInvoicesFound => 'No invoices found for the selected period.';

  @override
  String exportedInvoicesSuccess(int count) {
    return 'Successfully exported $count invoices to PDF';
  }

  @override
  String errorExportingInvoices(String error) {
    return 'Error exporting invoices: $error';
  }

  @override
  String loginSuccess(String username) {
    return 'Login successful! Welcome $username';
  }

  @override
  String get defaultCredentials => 'Default Credentials';

  @override
  String get adminCredentials => 'Admin: admin / admin123';

  @override
  String get cashierCredentials => 'Cashier: cashier / cashier123';

  @override
  String get switchTheme => 'Switch Theme';

  @override
  String get switchLanguage => 'Switch Language';

  @override
  String get printSettings => 'Print Settings';

  @override
  String get printFormat => 'Print Format';

  @override
  String get displayOptions => 'Display Options';

  @override
  String get showCompanyLogo => 'Show Company Logo';

  @override
  String get displayLogoPlaceholder =>
      'Display logo placeholder in invoice header';

  @override
  String get showQrCode => 'Show QR Code';

  @override
  String get displayZatcaQrCode => 'Display ZATCA-compliant QR code';

  @override
  String get showCustomerInformation => 'Show Customer Information';

  @override
  String get displayCustomerDetails =>
      'Display customer details when available';

  @override
  String get showNotes => 'Show Notes';

  @override
  String get displaySaleNotes => 'Display sale notes when available';

  @override
  String get selectFormat => 'Select Format';

  @override
  String get printNow => 'Print Now';

  @override
  String get thermalReceiptPrinter => 'Thermal receipt printer';

  @override
  String get standardPaperFormat => 'Standard paper format';

  @override
  String get a4Format => 'A4 (210×297mm)';

  @override
  String get thermal80mmFormat => '80mm Thermal';

  @override
  String get thermal58mmFormat => '58mm Thermal';

  @override
  String mmWidth(String width) {
    return '${width}mm width';
  }

  @override
  String get analyticsDashboard => 'Analytics Dashboard';

  @override
  String get keyMetrics => 'Key Metrics';

  @override
  String get totalVat => 'Total VAT';

  @override
  String get vatCollected => 'VAT collected';

  @override
  String get activeProducts => 'active';

  @override
  String get activeCustomers => 'active';

  @override
  String get completedInvoices => 'completed invoices';

  @override
  String get bestSellingProducts => 'Best Selling Products';

  @override
  String get lowStockNotifications => 'Low Stock Notifications';

  @override
  String get latestSalesInvoices => 'Latest Sales Invoices';

  @override
  String get salesTrend => 'Sales Trend';

  @override
  String get salesByCategory => 'Sales by Category';

  @override
  String get timePeriod => 'Time Period';

  @override
  String get last7Days => 'Last 7 Days';

  @override
  String get customPeriod => 'Custom Period';

  @override
  String get selectStartAndEndDates =>
      'Select the start and end dates for your custom period';

  @override
  String get selectStartDate => 'Select start date';

  @override
  String get selectEndDate => 'Select end date';

  @override
  String get duration => 'Duration';

  @override
  String get days => 'days';

  @override
  String durationDays(int count) {
    return 'Duration: $count days';
  }

  @override
  String get cancelled => 'Cancelled';

  @override
  String get unitsLeft => 'units left';

  @override
  String get critical => 'Critical';

  @override
  String viewAllItems(int count) {
    return 'View all $count items';
  }

  @override
  String viewAllLowStockItems(int count) {
    return 'View all $count low stock items';
  }

  @override
  String viewAllInvoices(int count) {
    return 'View all $count invoices';
  }

  @override
  String get noSalesDataAvailable => 'No sales data available';

  @override
  String get noInvoicesAvailable => 'No invoices available';

  @override
  String get noCategoryDataAvailable => 'No category data available';

  @override
  String get allProductsWellStocked => 'All products are well stocked';

  @override
  String errorLoadingInvoice(String error) {
    return 'Error loading invoice: $error';
  }

  @override
  String get refreshDashboard => 'Refresh Dashboard';

  @override
  String get invoiceStatistics => 'Invoice Statistics';

  @override
  String get loadingDashboardData => 'Loading dashboard data...';

  @override
  String get errorLoadingDashboard => 'Error loading dashboard';

  @override
  String get retry => 'Retry';

  @override
  String get salesLabel => 'Sales';

  @override
  String quantitySold(String quantity) {
    return 'Qty: $quantity';
  }

  @override
  String salesCount(int count) {
    return '$count sales';
  }

  @override
  String get transfer => 'Transfer';
}
