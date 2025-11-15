import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Retail Management System'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Point of Sale System'**
  String get appSubtitle;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Retail Management'**
  String get loginTitle;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @pleaseEnterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter username'**
  String get pleaseEnterUsername;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get pleaseEnterPassword;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password'**
  String get invalidCredentials;

  /// No description provided for @initializingSystem.
  ///
  /// In en, this message translates to:
  /// **'Initializing system...'**
  String get initializingSystem;

  /// No description provided for @initializationError.
  ///
  /// In en, this message translates to:
  /// **'Initialization error: {error}'**
  String initializationError(String error);

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @totalProducts.
  ///
  /// In en, this message translates to:
  /// **'Total Products'**
  String get totalProducts;

  /// No description provided for @totalCustomers.
  ///
  /// In en, this message translates to:
  /// **'Total Customers'**
  String get totalCustomers;

  /// No description provided for @recentSales.
  ///
  /// In en, this message translates to:
  /// **'Recent Sales'**
  String get recentSales;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @productList.
  ///
  /// In en, this message translates to:
  /// **'Product List'**
  String get productList;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// No description provided for @deleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get deleteProduct;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// No description provided for @productCode.
  ///
  /// In en, this message translates to:
  /// **'Product Code'**
  String get productCode;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inStock;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @productDetails.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productDetails;

  /// No description provided for @stockLevel.
  ///
  /// In en, this message translates to:
  /// **'Stock Level'**
  String get stockLevel;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @categoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Category Description'**
  String get categoryDescription;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @customerList.
  ///
  /// In en, this message translates to:
  /// **'Customer List'**
  String get customerList;

  /// No description provided for @addCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add Customer'**
  String get addCustomer;

  /// No description provided for @editCustomer.
  ///
  /// In en, this message translates to:
  /// **'Edit Customer'**
  String get editCustomer;

  /// No description provided for @deleteCustomer.
  ///
  /// In en, this message translates to:
  /// **'Delete Customer'**
  String get deleteCustomer;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customerName;

  /// No description provided for @customerCode.
  ///
  /// In en, this message translates to:
  /// **'Customer Code'**
  String get customerCode;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @customerDetails.
  ///
  /// In en, this message translates to:
  /// **'Customer Details'**
  String get customerDetails;

  /// No description provided for @totalPurchases.
  ///
  /// In en, this message translates to:
  /// **'Total Purchases'**
  String get totalPurchases;

  /// No description provided for @customerInformation.
  ///
  /// In en, this message translates to:
  /// **'Customer Information'**
  String get customerInformation;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @customerId.
  ///
  /// In en, this message translates to:
  /// **'Customer ID'**
  String get customerId;

  /// No description provided for @sales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get sales;

  /// No description provided for @salesList.
  ///
  /// In en, this message translates to:
  /// **'Sales List'**
  String get salesList;

  /// No description provided for @newSale.
  ///
  /// In en, this message translates to:
  /// **'New Sale'**
  String get newSale;

  /// No description provided for @saleDetails.
  ///
  /// In en, this message translates to:
  /// **'Sale Details'**
  String get saleDetails;

  /// No description provided for @invoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'Invoice Number'**
  String get invoiceNumber;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @printInvoice.
  ///
  /// In en, this message translates to:
  /// **'Print Invoice'**
  String get printInvoice;

  /// No description provided for @completeSale.
  ///
  /// In en, this message translates to:
  /// **'Complete Sale'**
  String get completeSale;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @userList.
  ///
  /// In en, this message translates to:
  /// **'User List'**
  String get userList;

  /// No description provided for @addUser.
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get addUser;

  /// No description provided for @editUser.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get editUser;

  /// No description provided for @deleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get deleteUser;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get createdAt;

  /// No description provided for @lastLogin.
  ///
  /// In en, this message translates to:
  /// **'Last Login'**
  String get lastLogin;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @generalSettings.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get generalSettings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @selectTheme.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @changeTheme.
  ///
  /// In en, this message translates to:
  /// **'Change Theme'**
  String get changeTheme;

  /// No description provided for @themeColorScheme.
  ///
  /// In en, this message translates to:
  /// **'Theme Color Scheme'**
  String get themeColorScheme;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @saveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get saveSuccess;

  /// No description provided for @deleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get deleteSuccess;

  /// No description provided for @updateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Updated successfully'**
  String get updateSuccess;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed'**
  String get saveFailed;

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed'**
  String get deleteFailed;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed'**
  String get updateFailed;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get confirmDelete;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get confirmLogout;

  /// No description provided for @confirmExit.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit the application?'**
  String get confirmExit;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get noItemsFound;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResults;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get invalidPhone;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @enterValidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get enterValidPhone;

  /// No description provided for @enterValidPrice.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price'**
  String get enterValidPrice;

  /// No description provided for @enterValidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid quantity'**
  String get enterValidQuantity;

  /// No description provided for @nameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name is too short'**
  String get nameTooShort;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @paste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// No description provided for @cashier.
  ///
  /// In en, this message translates to:
  /// **'Cashier'**
  String get cashier;

  /// No description provided for @scanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get scanBarcode;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @removeItem.
  ///
  /// In en, this message translates to:
  /// **'Remove Item'**
  String get removeItem;

  /// No description provided for @clearCart.
  ///
  /// In en, this message translates to:
  /// **'Clear Cart'**
  String get clearCart;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @paymentReceived.
  ///
  /// In en, this message translates to:
  /// **'Payment Received'**
  String get paymentReceived;

  /// No description provided for @returnChange.
  ///
  /// In en, this message translates to:
  /// **'Return Change'**
  String get returnChange;

  /// No description provided for @saleCompleted.
  ///
  /// In en, this message translates to:
  /// **'Sale Completed'**
  String get saleCompleted;

  /// No description provided for @thankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you!'**
  String get thankYou;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @salesReport.
  ///
  /// In en, this message translates to:
  /// **'Sales Report'**
  String get salesReport;

  /// No description provided for @inventoryReport.
  ///
  /// In en, this message translates to:
  /// **'Inventory Report'**
  String get inventoryReport;

  /// No description provided for @customerReport.
  ///
  /// In en, this message translates to:
  /// **'Customer Report'**
  String get customerReport;

  /// No description provided for @generateReport.
  ///
  /// In en, this message translates to:
  /// **'Generate Report'**
  String get generateReport;

  /// No description provided for @reportPeriod.
  ///
  /// In en, this message translates to:
  /// **'Report Period'**
  String get reportPeriod;

  /// No description provided for @companyNameEnglish.
  ///
  /// In en, this message translates to:
  /// **'Company Name (English)'**
  String get companyNameEnglish;

  /// No description provided for @companyNameArabic.
  ///
  /// In en, this message translates to:
  /// **'Company Name (Arabic)'**
  String get companyNameArabic;

  /// No description provided for @addressEnglish.
  ///
  /// In en, this message translates to:
  /// **'Address (English)'**
  String get addressEnglish;

  /// No description provided for @addressArabic.
  ///
  /// In en, this message translates to:
  /// **'Address (Arabic)'**
  String get addressArabic;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @vatNumber.
  ///
  /// In en, this message translates to:
  /// **'VAT Number'**
  String get vatNumber;

  /// No description provided for @crnNumber.
  ///
  /// In en, this message translates to:
  /// **'CRN Number'**
  String get crnNumber;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @currencySAR.
  ///
  /// In en, this message translates to:
  /// **'Saudi Riyal (SAR - ر.س)'**
  String get currencySAR;

  /// No description provided for @currencyUSD.
  ///
  /// In en, this message translates to:
  /// **'US Dollar (USD - \$)'**
  String get currencyUSD;

  /// No description provided for @currencyEUR.
  ///
  /// In en, this message translates to:
  /// **'Euro (EUR - €)'**
  String get currencyEUR;

  /// No description provided for @currencyGBP.
  ///
  /// In en, this message translates to:
  /// **'British Pound (GBP - £)'**
  String get currencyGBP;

  /// No description provided for @currencyAED.
  ///
  /// In en, this message translates to:
  /// **'UAE Dirham (AED - د.إ)'**
  String get currencyAED;

  /// No description provided for @currencyKWD.
  ///
  /// In en, this message translates to:
  /// **'Kuwaiti Dinar (KWD - د.ك)'**
  String get currencyKWD;

  /// No description provided for @currencyBHD.
  ///
  /// In en, this message translates to:
  /// **'Bahraini Dinar (BHD - د.ب)'**
  String get currencyBHD;

  /// No description provided for @currencyQAR.
  ///
  /// In en, this message translates to:
  /// **'Qatari Riyal (QAR - ر.ق)'**
  String get currencyQAR;

  /// No description provided for @currencyOMR.
  ///
  /// In en, this message translates to:
  /// **'Omani Rial (OMR - ر.ع)'**
  String get currencyOMR;

  /// No description provided for @currencyJOD.
  ///
  /// In en, this message translates to:
  /// **'Jordanian Dinar (JOD - د.أ)'**
  String get currencyJOD;

  /// No description provided for @currencyEGP.
  ///
  /// In en, this message translates to:
  /// **'Egyptian Pound (EGP - ج.م)'**
  String get currencyEGP;

  /// No description provided for @saveCompanyInformation.
  ///
  /// In en, this message translates to:
  /// **'Save Company Information'**
  String get saveCompanyInformation;

  /// No description provided for @companyInfoSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Company info saved successfully'**
  String get companyInfoSavedSuccess;

  /// No description provided for @errorLoadingCompanyInfo.
  ///
  /// In en, this message translates to:
  /// **'Error loading company info: {error}'**
  String errorLoadingCompanyInfo(String error);

  /// No description provided for @errorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving: {error}'**
  String errorSaving(String error);

  /// No description provided for @changesAppliedImmediately.
  ///
  /// In en, this message translates to:
  /// **'Changes will be applied immediately'**
  String get changesAppliedImmediately;

  /// No description provided for @dataSynchronization.
  ///
  /// In en, this message translates to:
  /// **'Data Synchronization'**
  String get dataSynchronization;

  /// No description provided for @syncDescription.
  ///
  /// In en, this message translates to:
  /// **'Sync your local data with the cloud when internet connection is available.'**
  String get syncDescription;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'1.0.0'**
  String get appVersion;

  /// No description provided for @posWithOfflineSupport.
  ///
  /// In en, this message translates to:
  /// **'Point of Sale with Offline Support'**
  String get posWithOfflineSupport;

  /// No description provided for @pointOfSale.
  ///
  /// In en, this message translates to:
  /// **'Point of Sale'**
  String get pointOfSale;

  /// No description provided for @productsManagement.
  ///
  /// In en, this message translates to:
  /// **'Products Management'**
  String get productsManagement;

  /// No description provided for @customersManagement.
  ///
  /// In en, this message translates to:
  /// **'Customers Management'**
  String get customersManagement;

  /// No description provided for @usersManagement.
  ///
  /// In en, this message translates to:
  /// **'Users Management'**
  String get usersManagement;

  /// No description provided for @cannotDeleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Cannot Delete Category'**
  String get cannotDeleteCategory;

  /// No description provided for @categoryHasProducts.
  ///
  /// In en, this message translates to:
  /// **'This category has products associated with it'**
  String get categoryHasProducts;

  /// No description provided for @deleteProductConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {productName}?'**
  String deleteProductConfirm(String productName);

  /// No description provided for @deleteCategoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {categoryName}? This action cannot be undone.'**
  String deleteCategoryConfirm(String categoryName);

  /// No description provided for @deleteCustomerConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this customer?'**
  String get deleteCustomerConfirm;

  /// No description provided for @deleteUserConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete user {username}? This action cannot be undone.'**
  String deleteUserConfirm(String username);

  /// No description provided for @returnSale.
  ///
  /// In en, this message translates to:
  /// **'Return Sale'**
  String get returnSale;

  /// No description provided for @returnSaleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Return sale {invoiceNumber}?'**
  String returnSaleConfirm(String invoiceNumber);

  /// No description provided for @printInvoiceQuestion.
  ///
  /// In en, this message translates to:
  /// **'Would you like to print the invoice?'**
  String get printInvoiceQuestion;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @vat.
  ///
  /// In en, this message translates to:
  /// **'VAT %'**
  String get vat;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @invoiceCount.
  ///
  /// In en, this message translates to:
  /// **'Invoice Count'**
  String get invoiceCount;

  /// No description provided for @noSalesFound.
  ///
  /// In en, this message translates to:
  /// **'No sales found'**
  String get noSalesFound;

  /// No description provided for @noCustomersFound.
  ///
  /// In en, this message translates to:
  /// **'No customers found'**
  String get noCustomersFound;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// No description provided for @cannotDeleteOwnAccount.
  ///
  /// In en, this message translates to:
  /// **'You cannot delete your own account'**
  String get cannotDeleteOwnAccount;

  /// No description provided for @selectACategory.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get selectACategory;

  /// No description provided for @invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid'**
  String get invalid;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'units'**
  String get units;

  /// No description provided for @failedToLoadCategories.
  ///
  /// In en, this message translates to:
  /// **'Failed to load categories: {error}'**
  String failedToLoadCategories(String error);

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// No description provided for @pleaseEnterCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a category name'**
  String get pleaseEnterCategoryName;

  /// No description provided for @categoryAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Category added successfully'**
  String get categoryAddedSuccess;

  /// No description provided for @categoryUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Category updated successfully'**
  String get categoryUpdatedSuccess;

  /// No description provided for @categoryDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Category deleted successfully'**
  String get categoryDeletedSuccess;

  /// No description provided for @errorSavingCategory.
  ///
  /// In en, this message translates to:
  /// **'Error saving category: {error}'**
  String errorSavingCategory(String error);

  /// No description provided for @errorDeletingCategory.
  ///
  /// In en, this message translates to:
  /// **'Error deleting category: {error}'**
  String errorDeletingCategory(String error);

  /// No description provided for @noCategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No categories found'**
  String get noCategoriesFound;

  /// No description provided for @productCount.
  ///
  /// In en, this message translates to:
  /// **'{count} product(s)'**
  String productCount(int count);

  /// No description provided for @tooltipEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get tooltipEdit;

  /// No description provided for @tooltipDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get tooltipDelete;

  /// No description provided for @userDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'User deleted successfully'**
  String get userDeletedSuccess;

  /// No description provided for @failedToDeleteUser.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete user'**
  String get failedToDeleteUser;

  /// No description provided for @userCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'User created successfully'**
  String get userCreatedSuccess;

  /// No description provided for @userUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'User updated successfully'**
  String get userUpdatedSuccess;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get anErrorOccurred;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get usernameRequired;

  /// No description provided for @usernameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get usernameMinLength;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get fullNameRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordLeaveEmpty.
  ///
  /// In en, this message translates to:
  /// **'Password (leave empty to keep current)'**
  String get passwordLeaveEmpty;

  /// No description provided for @printError.
  ///
  /// In en, this message translates to:
  /// **'Print error: {error}'**
  String printError(String error);

  /// No description provided for @invoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get invoice;

  /// No description provided for @invoiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Invoice: {invoiceNumber}'**
  String invoiceLabel(String invoiceNumber);

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String dateLabel(String date);

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total: SAR {total}'**
  String totalLabel(String total);

  /// No description provided for @statusLabelText.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String statusLabelText(String status);

  /// No description provided for @reprint.
  ///
  /// In en, this message translates to:
  /// **'Reprint'**
  String get reprint;

  /// No description provided for @return_sale.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get return_sale;

  /// No description provided for @itemsLabel.
  ///
  /// In en, this message translates to:
  /// **'Items:'**
  String get itemsLabel;

  /// No description provided for @subtotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Subtotal:'**
  String get subtotalLabel;

  /// No description provided for @vatLabel.
  ///
  /// In en, this message translates to:
  /// **'VAT:'**
  String get vatLabel;

  /// No description provided for @totalLabelColon.
  ///
  /// In en, this message translates to:
  /// **'Total:'**
  String get totalLabelColon;

  /// No description provided for @paidLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid:'**
  String get paidLabel;

  /// No description provided for @changeLabel.
  ///
  /// In en, this message translates to:
  /// **'Change:'**
  String get changeLabel;

  /// No description provided for @saleReturnedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sale returned successfully'**
  String get saleReturnedSuccess;

  /// No description provided for @errorLoadingCategories.
  ///
  /// In en, this message translates to:
  /// **'Error loading categories'**
  String get errorLoadingCategories;

  /// No description provided for @productNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Product Name *'**
  String get productNameRequired;

  /// No description provided for @barcodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Barcode *'**
  String get barcodeRequired;

  /// No description provided for @categoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Category *'**
  String get categoryRequired;

  /// No description provided for @priceRequired.
  ///
  /// In en, this message translates to:
  /// **'Price *'**
  String get priceRequired;

  /// No description provided for @costRequired.
  ///
  /// In en, this message translates to:
  /// **'Cost *'**
  String get costRequired;

  /// No description provided for @quantityRequired.
  ///
  /// In en, this message translates to:
  /// **'Quantity *'**
  String get quantityRequired;

  /// No description provided for @vatRateRequired.
  ///
  /// In en, this message translates to:
  /// **'VAT % *'**
  String get vatRateRequired;

  /// No description provided for @usernameFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Username *'**
  String get usernameFieldLabel;

  /// No description provided for @fullNameFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name *'**
  String get fullNameFieldLabel;

  /// No description provided for @passwordFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Password *'**
  String get passwordFieldLabel;

  /// No description provided for @roleFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Role *'**
  String get roleFieldLabel;

  /// No description provided for @customerNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Customer Name *'**
  String get customerNameRequired;

  /// No description provided for @emailFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailFieldLabel;

  /// No description provided for @phoneFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneFieldLabel;

  /// No description provided for @vatNumberFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'VAT Number'**
  String get vatNumberFieldLabel;

  /// No description provided for @crnNumberFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'CRN Number'**
  String get crnNumberFieldLabel;

  /// No description provided for @saudiNationalAddress.
  ///
  /// In en, this message translates to:
  /// **'Saudi National Address'**
  String get saudiNationalAddress;

  /// No description provided for @buildingNumber.
  ///
  /// In en, this message translates to:
  /// **'Building Number'**
  String get buildingNumber;

  /// No description provided for @streetName.
  ///
  /// In en, this message translates to:
  /// **'Street Name'**
  String get streetName;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @postalCode.
  ///
  /// In en, this message translates to:
  /// **'Postal Code'**
  String get postalCode;

  /// No description provided for @additionalNumber.
  ///
  /// In en, this message translates to:
  /// **'Additional Number'**
  String get additionalNumber;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone: {phone}'**
  String phoneLabel(String phone);

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email: {email}'**
  String emailLabel(String email);

  /// No description provided for @vatLabel2.
  ///
  /// In en, this message translates to:
  /// **'VAT'**
  String vatLabel2(String vatNumber);

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address: {address}'**
  String addressLabel(String address);

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @cartItems.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String cartItems(int count);

  /// No description provided for @cartIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Cart is empty'**
  String get cartIsEmpty;

  /// No description provided for @scanOrEnterBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan or enter barcode...'**
  String get scanOrEnterBarcode;

  /// No description provided for @productAddedToCart.
  ///
  /// In en, this message translates to:
  /// **'{productName} added to cart'**
  String productAddedToCart(String productName);

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get productNotFound;

  /// No description provided for @walkInCustomer.
  ///
  /// In en, this message translates to:
  /// **'Walk-in Customer'**
  String get walkInCustomer;

  /// No description provided for @amountPaid.
  ///
  /// In en, this message translates to:
  /// **'Amount Paid'**
  String get amountPaid;

  /// No description provided for @changeColon.
  ///
  /// In en, this message translates to:
  /// **'Change: SAR {amount}'**
  String changeColon(String amount);

  /// No description provided for @insufficientPayment.
  ///
  /// In en, this message translates to:
  /// **'Insufficient payment'**
  String get insufficientPayment;

  /// No description provided for @cashPayment.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cashPayment;

  /// No description provided for @cardPayment.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get cardPayment;

  /// No description provided for @transferPayment.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transferPayment;

  /// No description provided for @allDataSynchronized.
  ///
  /// In en, this message translates to:
  /// **'All data is already synchronized'**
  String get allDataSynchronized;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @successfullySynchronized.
  ///
  /// In en, this message translates to:
  /// **'Successfully synchronized {count} items'**
  String successfullySynchronized(int count);

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncFailed;

  /// No description provided for @exportInvoicesToPdf.
  ///
  /// In en, this message translates to:
  /// **'Export Invoices to PDF'**
  String get exportInvoicesToPdf;

  /// No description provided for @exportCustomerInvoices.
  ///
  /// In en, this message translates to:
  /// **'Export Customer Invoices to PDF'**
  String get exportCustomerInvoices;

  /// No description provided for @customerLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer: {name}'**
  String customerLabel(String name);

  /// No description provided for @selectPeriod.
  ///
  /// In en, this message translates to:
  /// **'Select Period:'**
  String get selectPeriod;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @lastThreeMonths.
  ///
  /// In en, this message translates to:
  /// **'Last 3 Months'**
  String get lastThreeMonths;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview:'**
  String get preview;

  /// No description provided for @totalInvoices.
  ///
  /// In en, this message translates to:
  /// **'Total Invoices: {count}'**
  String totalInvoices(int count);

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount: {amount}'**
  String totalAmount(String amount);

  /// No description provided for @exporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting...'**
  String get exporting;

  /// No description provided for @exportToPdf.
  ///
  /// In en, this message translates to:
  /// **'Export to PDF'**
  String get exportToPdf;

  /// No description provided for @loadingStatistics.
  ///
  /// In en, this message translates to:
  /// **'Loading statistics...'**
  String get loadingStatistics;

  /// No description provided for @invoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoices;

  /// No description provided for @invoicesCount.
  ///
  /// In en, this message translates to:
  /// **'Invoices: {count}'**
  String invoicesCount(int count);

  /// No description provided for @invoicesTotal.
  ///
  /// In en, this message translates to:
  /// **'Invoices: {count} | Total: {total}'**
  String invoicesTotal(int count, String total);

  /// No description provided for @companyInfoNotFound.
  ///
  /// In en, this message translates to:
  /// **'Company information not found. Please configure in Settings.'**
  String get companyInfoNotFound;

  /// No description provided for @noInvoicesFound.
  ///
  /// In en, this message translates to:
  /// **'No invoices found for the selected period.'**
  String get noInvoicesFound;

  /// No description provided for @exportedInvoicesSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully exported {count} invoices to PDF'**
  String exportedInvoicesSuccess(int count);

  /// No description provided for @errorExportingInvoices.
  ///
  /// In en, this message translates to:
  /// **'Error exporting invoices: {error}'**
  String errorExportingInvoices(String error);

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful! Welcome {username}'**
  String loginSuccess(String username);

  /// No description provided for @defaultCredentials.
  ///
  /// In en, this message translates to:
  /// **'Default Credentials'**
  String get defaultCredentials;

  /// No description provided for @adminCredentials.
  ///
  /// In en, this message translates to:
  /// **'Admin: admin / admin123'**
  String get adminCredentials;

  /// No description provided for @cashierCredentials.
  ///
  /// In en, this message translates to:
  /// **'Cashier: cashier / cashier123'**
  String get cashierCredentials;

  /// No description provided for @switchTheme.
  ///
  /// In en, this message translates to:
  /// **'Switch Theme'**
  String get switchTheme;

  /// No description provided for @switchLanguage.
  ///
  /// In en, this message translates to:
  /// **'Switch Language'**
  String get switchLanguage;

  /// No description provided for @printSettings.
  ///
  /// In en, this message translates to:
  /// **'Print Settings'**
  String get printSettings;

  /// No description provided for @printFormat.
  ///
  /// In en, this message translates to:
  /// **'Print Format'**
  String get printFormat;

  /// No description provided for @displayOptions.
  ///
  /// In en, this message translates to:
  /// **'Display Options'**
  String get displayOptions;

  /// No description provided for @showCompanyLogo.
  ///
  /// In en, this message translates to:
  /// **'Show Company Logo'**
  String get showCompanyLogo;

  /// No description provided for @displayLogoPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Display logo placeholder in invoice header'**
  String get displayLogoPlaceholder;

  /// No description provided for @showQrCode.
  ///
  /// In en, this message translates to:
  /// **'Show QR Code'**
  String get showQrCode;

  /// No description provided for @displayZatcaQrCode.
  ///
  /// In en, this message translates to:
  /// **'Display ZATCA-compliant QR code'**
  String get displayZatcaQrCode;

  /// No description provided for @showCustomerInformation.
  ///
  /// In en, this message translates to:
  /// **'Show Customer Information'**
  String get showCustomerInformation;

  /// No description provided for @displayCustomerDetails.
  ///
  /// In en, this message translates to:
  /// **'Display customer details when available'**
  String get displayCustomerDetails;

  /// No description provided for @showNotes.
  ///
  /// In en, this message translates to:
  /// **'Show Notes'**
  String get showNotes;

  /// No description provided for @displaySaleNotes.
  ///
  /// In en, this message translates to:
  /// **'Display sale notes when available'**
  String get displaySaleNotes;

  /// No description provided for @selectFormat.
  ///
  /// In en, this message translates to:
  /// **'Select Format'**
  String get selectFormat;

  /// No description provided for @printNow.
  ///
  /// In en, this message translates to:
  /// **'Print Now'**
  String get printNow;

  /// No description provided for @thermalReceiptPrinter.
  ///
  /// In en, this message translates to:
  /// **'Thermal receipt printer'**
  String get thermalReceiptPrinter;

  /// No description provided for @standardPaperFormat.
  ///
  /// In en, this message translates to:
  /// **'Standard paper format'**
  String get standardPaperFormat;

  /// No description provided for @a4Format.
  ///
  /// In en, this message translates to:
  /// **'A4 (210x297mm)'**
  String get a4Format;

  /// No description provided for @thermal80mmFormat.
  ///
  /// In en, this message translates to:
  /// **'80mm Thermal'**
  String get thermal80mmFormat;

  /// No description provided for @thermal58mmFormat.
  ///
  /// In en, this message translates to:
  /// **'58mm Thermal'**
  String get thermal58mmFormat;

  /// No description provided for @mmWidth.
  ///
  /// In en, this message translates to:
  /// **'{width}mm width'**
  String mmWidth(String width);

  /// No description provided for @analyticsDashboard.
  ///
  /// In en, this message translates to:
  /// **'Analytics Dashboard'**
  String get analyticsDashboard;

  /// No description provided for @keyMetrics.
  ///
  /// In en, this message translates to:
  /// **'Key Metrics'**
  String get keyMetrics;

  /// No description provided for @totalVat.
  ///
  /// In en, this message translates to:
  /// **'Total VAT'**
  String get totalVat;

  /// No description provided for @vatCollected.
  ///
  /// In en, this message translates to:
  /// **'VAT collected'**
  String get vatCollected;

  /// No description provided for @activeProducts.
  ///
  /// In en, this message translates to:
  /// **'active'**
  String get activeProducts;

  /// No description provided for @activeCustomers.
  ///
  /// In en, this message translates to:
  /// **'active'**
  String get activeCustomers;

  /// No description provided for @completedInvoices.
  ///
  /// In en, this message translates to:
  /// **'completed invoices'**
  String get completedInvoices;

  /// No description provided for @bestSellingProducts.
  ///
  /// In en, this message translates to:
  /// **'Best Selling Products'**
  String get bestSellingProducts;

  /// No description provided for @lowStockNotifications.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Notifications'**
  String get lowStockNotifications;

  /// No description provided for @latestSalesInvoices.
  ///
  /// In en, this message translates to:
  /// **'Latest Sales Invoices'**
  String get latestSalesInvoices;

  /// No description provided for @salesTrend.
  ///
  /// In en, this message translates to:
  /// **'Sales Trend'**
  String get salesTrend;

  /// No description provided for @salesByCategory.
  ///
  /// In en, this message translates to:
  /// **'Sales by Category'**
  String get salesByCategory;

  /// No description provided for @timePeriod.
  ///
  /// In en, this message translates to:
  /// **'Time Period'**
  String get timePeriod;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// No description provided for @customPeriod.
  ///
  /// In en, this message translates to:
  /// **'Custom Period'**
  String get customPeriod;

  /// No description provided for @selectStartAndEndDates.
  ///
  /// In en, this message translates to:
  /// **'Select the start and end dates for your custom period'**
  String get selectStartAndEndDates;

  /// No description provided for @selectStartDate.
  ///
  /// In en, this message translates to:
  /// **'Select start date'**
  String get selectStartDate;

  /// No description provided for @selectEndDate.
  ///
  /// In en, this message translates to:
  /// **'Select end date'**
  String get selectEndDate;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @durationDays.
  ///
  /// In en, this message translates to:
  /// **'Duration: {count} days'**
  String durationDays(int count);

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @unitsLeft.
  ///
  /// In en, this message translates to:
  /// **'units left'**
  String get unitsLeft;

  /// No description provided for @critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// No description provided for @viewAllItems.
  ///
  /// In en, this message translates to:
  /// **'View all {count} items'**
  String viewAllItems(int count);

  /// No description provided for @viewAllLowStockItems.
  ///
  /// In en, this message translates to:
  /// **'View all {count} low stock items'**
  String viewAllLowStockItems(int count);

  /// No description provided for @viewAllInvoices.
  ///
  /// In en, this message translates to:
  /// **'View all {count} invoices'**
  String viewAllInvoices(int count);

  /// No description provided for @noSalesDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No sales data available'**
  String get noSalesDataAvailable;

  /// No description provided for @noInvoicesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No invoices available'**
  String get noInvoicesAvailable;

  /// No description provided for @noCategoryDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No category data available'**
  String get noCategoryDataAvailable;

  /// No description provided for @allProductsWellStocked.
  ///
  /// In en, this message translates to:
  /// **'All products are well stocked'**
  String get allProductsWellStocked;

  /// No description provided for @errorLoadingInvoice.
  ///
  /// In en, this message translates to:
  /// **'Error loading invoice: {error}'**
  String errorLoadingInvoice(String error);

  /// No description provided for @refreshDashboard.
  ///
  /// In en, this message translates to:
  /// **'Refresh Dashboard'**
  String get refreshDashboard;

  /// No description provided for @invoiceStatistics.
  ///
  /// In en, this message translates to:
  /// **'Invoice Statistics'**
  String get invoiceStatistics;

  /// No description provided for @loadingDashboardData.
  ///
  /// In en, this message translates to:
  /// **'Loading dashboard data...'**
  String get loadingDashboardData;

  /// No description provided for @errorLoadingDashboard.
  ///
  /// In en, this message translates to:
  /// **'Error loading dashboard'**
  String get errorLoadingDashboard;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @salesLabel.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get salesLabel;

  /// No description provided for @quantitySold.
  ///
  /// In en, this message translates to:
  /// **'Qty: {quantity}'**
  String quantitySold(String quantity);

  /// No description provided for @salesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} sales'**
  String salesCount(int count);

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @vatEnabled.
  ///
  /// In en, this message translates to:
  /// **'VAT Enabled'**
  String get vatEnabled;

  /// No description provided for @vatDisabled.
  ///
  /// In en, this message translates to:
  /// **'VAT Disabled'**
  String get vatDisabled;

  /// No description provided for @vatEnabledDescription.
  ///
  /// In en, this message translates to:
  /// **'VAT will be calculated and added to product prices'**
  String get vatEnabledDescription;

  /// No description provided for @vatDisabledDescription.
  ///
  /// In en, this message translates to:
  /// **'VAT calculation is turned off'**
  String get vatDisabledDescription;

  /// No description provided for @businessDetailsAndContactInformation.
  ///
  /// In en, this message translates to:
  /// **'Business details and contact information'**
  String get businessDetailsAndContactInformation;

  /// No description provided for @configureInvoicePrintingOptions.
  ///
  /// In en, this message translates to:
  /// **'Configure invoice printing options'**
  String get configureInvoicePrintingOptions;

  /// No description provided for @defaultVatRate.
  ///
  /// In en, this message translates to:
  /// **'Default VAT rate'**
  String get defaultVatRate;

  /// No description provided for @setDefaultVatRateDescription.
  ///
  /// In en, this message translates to:
  /// **'Set the default VAT rate to be applied automatically to all products'**
  String get setDefaultVatRateDescription;

  /// No description provided for @vatRateLabel.
  ///
  /// In en, this message translates to:
  /// **'VAT Rate (%)'**
  String get vatRateLabel;

  /// No description provided for @vatRateHint.
  ///
  /// In en, this message translates to:
  /// **'15.0'**
  String get vatRateHint;

  /// No description provided for @currentVatRate.
  ///
  /// In en, this message translates to:
  /// **'Current VAT Rate'**
  String get currentVatRate;

  /// No description provided for @vatCalculationMethod.
  ///
  /// In en, this message translates to:
  /// **'VAT Calculation Method'**
  String get vatCalculationMethod;

  /// No description provided for @chooseVatCalculationMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose whether VAT is included in the product price or added on top'**
  String get chooseVatCalculationMethod;

  /// No description provided for @vatIncludedInPrice.
  ///
  /// In en, this message translates to:
  /// **'VAT Included in Price'**
  String get vatIncludedInPrice;

  /// No description provided for @vatExcludedFromPrice.
  ///
  /// In en, this message translates to:
  /// **'VAT Excluded from Price'**
  String get vatExcludedFromPrice;

  /// No description provided for @vatIncludedInPriceDescription.
  ///
  /// In en, this message translates to:
  /// **'Product prices include VAT (VAT will be extracted from the total)'**
  String get vatIncludedInPriceDescription;

  /// No description provided for @vatExcludedFromPriceDescription.
  ///
  /// In en, this message translates to:
  /// **'Product prices exclude VAT (VAT will be added to the total)'**
  String get vatExcludedFromPriceDescription;

  /// No description provided for @vatRateAppliedToNewProducts.
  ///
  /// In en, this message translates to:
  /// **'This VAT rate will be automatically applied to all new products. Changes apply immediately.'**
  String get vatRateAppliedToNewProducts;

  /// No description provided for @vatIncludedInPriceNote.
  ///
  /// In en, this message translates to:
  /// **'VAT {rate}% - Included in price'**
  String vatIncludedInPriceNote(String rate);

  /// No description provided for @vatExcludedFromPriceNote.
  ///
  /// In en, this message translates to:
  /// **'VAT {rate}% - Excluded from price'**
  String vatExcludedFromPriceNote(String rate);

  /// No description provided for @pricesIncludeVatNote.
  ///
  /// In en, this message translates to:
  /// **'Prices shown include VAT - VAT will be extracted from the listed price'**
  String get pricesIncludeVatNote;

  /// No description provided for @pricesExcludeVatNote.
  ///
  /// In en, this message translates to:
  /// **'Prices shown exclude VAT - VAT will be added on top of the listed price'**
  String get pricesExcludeVatNote;

  /// No description provided for @priceVatIncluded.
  ///
  /// In en, this message translates to:
  /// **'Price (Incl. VAT)'**
  String get priceVatIncluded;

  /// No description provided for @priceVatExcluded.
  ///
  /// In en, this message translates to:
  /// **'Price (Excl. VAT)'**
  String get priceVatExcluded;

  /// No description provided for @beforeVat.
  ///
  /// In en, this message translates to:
  /// **'Before VAT'**
  String get beforeVat;

  /// No description provided for @afterVat.
  ///
  /// In en, this message translates to:
  /// **'After VAT'**
  String get afterVat;

  /// No description provided for @vatBreakdown.
  ///
  /// In en, this message translates to:
  /// **'VAT Breakdown'**
  String get vatBreakdown;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @vatAmountCalculatedAutomatically.
  ///
  /// In en, this message translates to:
  /// **'VAT amount calculated automatically ({rate}%)'**
  String vatAmountCalculatedAutomatically(String rate);

  /// No description provided for @dataImportExport.
  ///
  /// In en, this message translates to:
  /// **'Data Import & Export'**
  String get dataImportExport;

  /// No description provided for @dataImportExportDescription.
  ///
  /// In en, this message translates to:
  /// **'Import or export your business data'**
  String get dataImportExportDescription;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @selectDataToImport.
  ///
  /// In en, this message translates to:
  /// **'Select Data to Import'**
  String get selectDataToImport;

  /// No description provided for @selectDataToExport.
  ///
  /// In en, this message translates to:
  /// **'Select Data to Export'**
  String get selectDataToExport;

  /// No description provided for @selectMultipleDataTypes.
  ///
  /// In en, this message translates to:
  /// **'Select one or more data types to proceed'**
  String get selectMultipleDataTypes;

  /// No description provided for @selectSingleDataType.
  ///
  /// In en, this message translates to:
  /// **'Select a data type to proceed'**
  String get selectSingleDataType;

  /// No description provided for @allData.
  ///
  /// In en, this message translates to:
  /// **'All Data'**
  String get allData;

  /// No description provided for @allDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Export or import all data types'**
  String get allDataDescription;

  /// No description provided for @productsDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Product inventory and pricing information'**
  String get productsDataDescription;

  /// No description provided for @categoriesDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Product categories and classifications'**
  String get categoriesDataDescription;

  /// No description provided for @customersDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Customer contact and business information'**
  String get customersDataDescription;

  /// No description provided for @salesDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Sales transactions and invoices'**
  String get salesDataDescription;

  /// No description provided for @usersDataDescription.
  ///
  /// In en, this message translates to:
  /// **'User accounts and permissions'**
  String get usersDataDescription;

  /// No description provided for @settingsDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Company information and system settings'**
  String get settingsDataDescription;

  /// No description provided for @exportFormat.
  ///
  /// In en, this message translates to:
  /// **'Export Format'**
  String get exportFormat;

  /// No description provided for @importFile.
  ///
  /// In en, this message translates to:
  /// **'Import File'**
  String get importFile;

  /// No description provided for @selectFile.
  ///
  /// In en, this message translates to:
  /// **'Select File'**
  String get selectFile;

  /// No description provided for @fileSelected.
  ///
  /// In en, this message translates to:
  /// **'File Selected'**
  String get fileSelected;

  /// No description provided for @noFileSelected.
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get noFileSelected;

  /// No description provided for @importing.
  ///
  /// In en, this message translates to:
  /// **'Importing...'**
  String get importing;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data imported successfully'**
  String get importSuccess;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully'**
  String get exportSuccess;

  /// No description provided for @importError.
  ///
  /// In en, this message translates to:
  /// **'Import failed'**
  String get importError;

  /// No description provided for @exportError.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get exportError;

  /// No description provided for @importSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Successfully imported {count} items'**
  String importSuccessMessage(int count);

  /// No description provided for @exportSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Data exported to: {path}'**
  String exportSuccessMessage(String path);

  /// No description provided for @importWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: Importing data will merge with existing data. Duplicate entries will be replaced.'**
  String get importWarning;

  /// No description provided for @exportWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: Sensitive data like user passwords will not be exported for security reasons.'**
  String get exportWarning;

  /// No description provided for @selectFileToImport.
  ///
  /// In en, this message translates to:
  /// **'Please select a file to import'**
  String get selectFileToImport;

  /// No description provided for @selectDataTypesToProceed.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one data type to proceed'**
  String get selectDataTypesToProceed;

  /// No description provided for @unsupportedFileFormat.
  ///
  /// In en, this message translates to:
  /// **'Unsupported file format. Please select a JSON or CSV file.'**
  String get unsupportedFileFormat;

  /// No description provided for @fileNotFound.
  ///
  /// In en, this message translates to:
  /// **'File not found. Please select a valid file.'**
  String get fileNotFound;

  /// No description provided for @invalidFileContent.
  ///
  /// In en, this message translates to:
  /// **'Invalid file content. Please check the file format.'**
  String get invalidFileContent;

  /// No description provided for @importInProgress.
  ///
  /// In en, this message translates to:
  /// **'Import in progress...'**
  String get importInProgress;

  /// No description provided for @exportInProgress.
  ///
  /// In en, this message translates to:
  /// **'Export in progress...'**
  String get exportInProgress;

  /// No description provided for @openFile.
  ///
  /// In en, this message translates to:
  /// **'Open File'**
  String get openFile;

  /// No description provided for @detectedDataTypes.
  ///
  /// In en, this message translates to:
  /// **'Detected Data Types'**
  String get detectedDataTypes;

  /// No description provided for @detectedDataTypesDescription.
  ///
  /// In en, this message translates to:
  /// **'We found the following data in your file. You can modify the selection before importing.'**
  String get detectedDataTypesDescription;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemsCount(int count);

  /// No description provided for @appConfigNotAppliedNote.
  ///
  /// In en, this message translates to:
  /// **'Note: This file contains appearance settings (theme, colors, language, VAT settings) that will be automatically applied after import. You may need to restart the app to see all changes.'**
  String get appConfigNotAppliedNote;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
