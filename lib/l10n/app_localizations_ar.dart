// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'نظام إدارة البيع بالتجزئة';

  @override
  String get appSubtitle => 'نظام نقاط البيع';

  @override
  String get ok => 'موافق';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get add => 'إضافة';

  @override
  String get search => 'بحث';

  @override
  String get filter => 'تصفية';

  @override
  String get refresh => 'تحديث';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get error => 'خطأ';

  @override
  String get success => 'نجاح';

  @override
  String get confirm => 'تأكيد';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get close => 'إغلاق';

  @override
  String get submit => 'إرسال';

  @override
  String get loginTitle => 'إدارة البيع بالتجزئة';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get password => 'كلمة المرور';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get pleaseEnterUsername => 'الرجاء إدخال اسم المستخدم';

  @override
  String get pleaseEnterPassword => 'الرجاء إدخال كلمة المرور';

  @override
  String get loginFailed => 'فشل تسجيل الدخول';

  @override
  String get invalidCredentials => 'اسم المستخدم أو كلمة المرور غير صحيحة';

  @override
  String get initializingSystem => 'جاري تهيئة النظام...';

  @override
  String initializationError(String error) {
    return 'خطأ في التهيئة: $error';
  }

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get welcome => 'مرحباً';

  @override
  String get totalProducts => 'إجمالي المنتجات';

  @override
  String get totalCustomers => 'إجمالي العملاء';

  @override
  String get recentSales => 'المبيعات الأخيرة';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get statistics => 'الإحصائيات';

  @override
  String get today => 'اليوم';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get products => 'المنتجات';

  @override
  String get productList => 'قائمة المنتجات';

  @override
  String get editProduct => 'تعديل المنتج';

  @override
  String get deleteProduct => 'حذف المنتج';

  @override
  String get productName => 'اسم المنتج';

  @override
  String get productCode => 'رمز المنتج';

  @override
  String get price => 'السعر';

  @override
  String get quantity => 'الكمية';

  @override
  String get category => 'الفئة';

  @override
  String get description => 'الوصف';

  @override
  String get inStock => 'متوفر';

  @override
  String get outOfStock => 'نفذ من المخزون';

  @override
  String get productDetails => 'تفاصيل المنتج';

  @override
  String get stockLevel => 'مستوى المخزون';

  @override
  String get categories => 'الفئات';

  @override
  String get editCategory => 'تعديل الفئة';

  @override
  String get deleteCategory => 'حذف الفئة';

  @override
  String get categoryName => 'اسم الفئة';

  @override
  String get categoryDescription => 'وصف الفئة';

  @override
  String get customers => 'العملاء';

  @override
  String get customerList => 'قائمة العملاء';

  @override
  String get addCustomer => 'إضافة عميل';

  @override
  String get editCustomer => 'تعديل العميل';

  @override
  String get deleteCustomer => 'حذف العميل';

  @override
  String get customerName => 'اسم العميل';

  @override
  String get customerCode => 'رمز العميل';

  @override
  String get phone => 'الهاتف';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get address => 'العنوان';

  @override
  String get customerDetails => 'تفاصيل العميل';

  @override
  String get totalPurchases => 'إجمالي المشتريات';

  @override
  String get customerInformation => 'معلومات العميل';

  @override
  String get customer => 'العميل';

  @override
  String get customerId => 'معرف العميل';

  @override
  String get sales => 'المبيعات';

  @override
  String get salesList => 'قائمة المبيعات';

  @override
  String get newSale => 'عملية بيع جديدة';

  @override
  String get saleDetails => 'تفاصيل البيع';

  @override
  String get invoiceNumber => 'رقم الفاتورة';

  @override
  String get date => 'التاريخ';

  @override
  String get time => 'الوقت';

  @override
  String get items => 'العناصر';

  @override
  String get subtotal => 'المجموع الفرعي';

  @override
  String get discount => 'الخصم';

  @override
  String get tax => 'الضريبة';

  @override
  String get total => 'الإجمالي';

  @override
  String get payment => 'الدفع';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get change => 'الباقي';

  @override
  String get printInvoice => 'طباعة الفاتورة';

  @override
  String get completeSale => 'إتمام البيع';

  @override
  String get users => 'المستخدمون';

  @override
  String get userList => 'قائمة المستخدمين';

  @override
  String get addUser => 'إضافة مستخدم';

  @override
  String get editUser => 'تعديل المستخدم';

  @override
  String get deleteUser => 'حذف المستخدم';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get role => 'الدور';

  @override
  String get admin => 'مدير';

  @override
  String get createdAt => 'تاريخ الإنشاء';

  @override
  String get lastLogin => 'آخر تسجيل دخول';

  @override
  String get active => 'نشط';

  @override
  String get inactive => 'غير نشط';

  @override
  String get settings => 'الإعدادات';

  @override
  String get generalSettings => 'الإعدادات العامة';

  @override
  String get appearance => 'المظهر';

  @override
  String get language => 'اللغة';

  @override
  String get theme => 'السمة';

  @override
  String get lightMode => 'الوضع النهاري';

  @override
  String get darkMode => 'الوضع الليلي';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get selectTheme => 'اختر السمة';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get changeTheme => 'تغيير السمة';

  @override
  String get preferences => 'التفضيلات';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get backup => 'نسخ احتياطي';

  @override
  String get restore => 'استعادة';

  @override
  String get about => 'حول';

  @override
  String get saveSuccess => 'تم الحفظ بنجاح';

  @override
  String get deleteSuccess => 'تم الحذف بنجاح';

  @override
  String get updateSuccess => 'تم التحديث بنجاح';

  @override
  String get saveFailed => 'فشل الحفظ';

  @override
  String get deleteFailed => 'فشل الحذف';

  @override
  String get updateFailed => 'فشل التحديث';

  @override
  String get confirmDelete => 'هل أنت متأكد من حذف هذا العنصر؟';

  @override
  String get confirmLogout => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get confirmExit => 'هل أنت متأكد من الخروج من التطبيق؟';

  @override
  String get noDataAvailable => 'لا توجد بيانات متاحة';

  @override
  String get noItemsFound => 'لم يتم العثور على عناصر';

  @override
  String get searchResults => 'نتائج البحث';

  @override
  String get requiredField => 'هذا الحقل مطلوب';

  @override
  String get invalidEmail => 'عنوان البريد الإلكتروني غير صحيح';

  @override
  String get invalidPhone => 'رقم الهاتف غير صحيح';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب';

  @override
  String get enterValidEmail => 'الرجاء إدخال بريد إلكتروني صحيح';

  @override
  String get enterValidPhone => 'الرجاء إدخال رقم هاتف صحيح';

  @override
  String get enterValidPrice => 'الرجاء إدخال سعر صحيح';

  @override
  String get enterValidQuantity => 'الرجاء إدخال كمية صحيحة';

  @override
  String get nameTooShort => 'الاسم قصير جداً';

  @override
  String get passwordTooShort => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get view => 'عرض';

  @override
  String get export => 'تصدير';

  @override
  String get import => 'استيراد';

  @override
  String get download => 'تحميل';

  @override
  String get upload => 'رفع';

  @override
  String get share => 'مشاركة';

  @override
  String get copy => 'نسخ';

  @override
  String get paste => 'لصق';

  @override
  String get clear => 'مسح';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get apply => 'تطبيق';

  @override
  String get daily => 'يومي';

  @override
  String get weekly => 'أسبوعي';

  @override
  String get monthly => 'شهري';

  @override
  String get yearly => 'سنوي';

  @override
  String get custom => 'مخصص';

  @override
  String get from => 'من';

  @override
  String get to => 'إلى';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get selectTime => 'اختر الوقت';

  @override
  String get cashier => 'أمين الصندوق';

  @override
  String get scanBarcode => 'مسح الرمز الشريطي';

  @override
  String get addItem => 'إضافة عنصر';

  @override
  String get removeItem => 'إزالة عنصر';

  @override
  String get clearCart => 'مسح السلة';

  @override
  String get checkout => 'الدفع';

  @override
  String get paymentReceived => 'تم استلام الدفعة';

  @override
  String get returnChange => 'إرجاع الباقي';

  @override
  String get saleCompleted => 'تم إتمام البيع';

  @override
  String get thankYou => 'شكراً لك!';

  @override
  String get reports => 'التقارير';

  @override
  String get salesReport => 'تقرير المبيعات';

  @override
  String get inventoryReport => 'تقرير المخزون';

  @override
  String get customerReport => 'تقرير العملاء';

  @override
  String get generateReport => 'إنشاء تقرير';

  @override
  String get reportPeriod => 'فترة التقرير';

  @override
  String get companyNameEnglish => 'اسم الشركة (إنجليزي)';

  @override
  String get companyNameArabic => 'اسم الشركة (عربي)';

  @override
  String get addressEnglish => 'العنوان (إنجليزي)';

  @override
  String get addressArabic => 'العنوان (عربي)';

  @override
  String get required => 'مطلوب';

  @override
  String get vatNumber => 'الرقم الضريبي';

  @override
  String get crnNumber => 'رقم السجل التجاري';

  @override
  String get currency => 'العملة';

  @override
  String get selectCurrency => 'اختر العملة';

  @override
  String get currencySAR => 'الريال السعودي (SAR - ر.س)';

  @override
  String get currencyUSD => 'الدولار الأمريكي (USD - \$)';

  @override
  String get currencyEUR => 'اليورو (EUR - €)';

  @override
  String get currencyGBP => 'الجنيه الإسترليني (GBP - £)';

  @override
  String get currencyAED => 'الدرهم الإماراتي (AED - د.إ)';

  @override
  String get currencyKWD => 'الدينار الكويتي (KWD - د.ك)';

  @override
  String get currencyBHD => 'الدينار البحريني (BHD - د.ب)';

  @override
  String get currencyQAR => 'الريال القطري (QAR - ر.ق)';

  @override
  String get currencyOMR => 'الريال العماني (OMR - ر.ع)';

  @override
  String get currencyJOD => 'الدينار الأردني (JOD - د.أ)';

  @override
  String get currencyEGP => 'الجنيه المصري (EGP - ج.م)';

  @override
  String get saveCompanyInformation => 'حفظ معلومات الشركة';

  @override
  String get companyInfoSavedSuccess => 'تم حفظ معلومات الشركة بنجاح';

  @override
  String errorLoadingCompanyInfo(String error) {
    return 'خطأ في تحميل معلومات الشركة: $error';
  }

  @override
  String errorSaving(String error) {
    return 'خطأ في الحفظ: $error';
  }

  @override
  String get changesAppliedImmediately => 'سيتم تطبيق التغييرات على الفور';

  @override
  String get dataSynchronization => 'مزامنة البيانات';

  @override
  String get syncDescription =>
      'مزامنة بياناتك المحلية مع السحابة عند توفر الاتصال بالإنترنت.';

  @override
  String get syncing => 'جاري المزامنة...';

  @override
  String get syncNow => 'مزامنة الآن';

  @override
  String get version => 'الإصدار';

  @override
  String get appVersion => '1.0.0';

  @override
  String get posWithOfflineSupport => 'نظام نقاط البيع مع دعم العمل بلا اتصال';

  @override
  String get pointOfSale => 'نقطة البيع';

  @override
  String get productsManagement => 'إدارة المنتجات';

  @override
  String get customersManagement => 'إدارة العملاء';

  @override
  String get usersManagement => 'إدارة المستخدمين';

  @override
  String get cannotDeleteCategory => 'لا يمكن حذف الفئة';

  @override
  String get categoryHasProducts => 'هذه الفئة تحتوي على منتجات مرتبطة بها';

  @override
  String deleteProductConfirm(String productName) {
    return 'حذف $productName؟';
  }

  @override
  String deleteCategoryConfirm(String categoryName) {
    return 'حذف $categoryName؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get deleteCustomerConfirm => 'هل أنت متأكد من حذف هذا العميل؟';

  @override
  String deleteUserConfirm(String username) {
    return 'حذف المستخدم $username؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get returnSale => 'إرجاع البيع';

  @override
  String returnSaleConfirm(String invoiceNumber) {
    return 'إرجاع البيع $invoiceNumber؟';
  }

  @override
  String get printInvoiceQuestion => 'هل تريد طباعة الفاتورة؟';

  @override
  String get complete => 'إتمام';

  @override
  String get name => 'الاسم';

  @override
  String get stock => 'المخزون';

  @override
  String get vat => 'الضريبة %';

  @override
  String get actions => 'الإجراءات';

  @override
  String get status => 'الحالة';

  @override
  String get invoiceCount => 'عدد الفواتير';

  @override
  String get noSalesFound => 'لم يتم العثور على مبيعات';

  @override
  String get noCustomersFound => 'لم يتم العثور على عملاء';

  @override
  String get noProductsFound => 'لم يتم العثور على منتجات';

  @override
  String get noUsersFound => 'لم يتم العثور على مستخدمين';

  @override
  String get cannotDeleteOwnAccount => 'لا يمكنك حذف حسابك الخاص';

  @override
  String get selectACategory => 'اختر فئة';

  @override
  String get invalid => 'غير صحيح';

  @override
  String get units => 'وحدات';

  @override
  String failedToLoadCategories(String error) {
    return 'فشل تحميل الفئات: $error';
  }

  @override
  String get descriptionOptional => 'الوصف (اختياري)';

  @override
  String get pleaseEnterCategoryName => 'الرجاء إدخال اسم الفئة';

  @override
  String get categoryAddedSuccess => 'تمت إضافة الفئة بنجاح';

  @override
  String get categoryUpdatedSuccess => 'تم تحديث الفئة بنجاح';

  @override
  String get categoryDeletedSuccess => 'تم حذف الفئة بنجاح';

  @override
  String errorSavingCategory(String error) {
    return 'خطأ في حفظ الفئة: $error';
  }

  @override
  String errorDeletingCategory(String error) {
    return 'خطأ في حذف الفئة: $error';
  }

  @override
  String get noCategoriesFound => 'لم يتم العثور على فئات';

  @override
  String productCount(int count) {
    return '$count منتج';
  }

  @override
  String get tooltipEdit => 'تعديل';

  @override
  String get tooltipDelete => 'حذف';

  @override
  String get userDeletedSuccess => 'تم حذف المستخدم بنجاح';

  @override
  String get failedToDeleteUser => 'فشل حذف المستخدم';

  @override
  String get userCreatedSuccess => 'تم إنشاء المستخدم بنجاح';

  @override
  String get userUpdatedSuccess => 'تم تحديث المستخدم بنجاح';

  @override
  String get anErrorOccurred => 'حدث خطأ';

  @override
  String get usernameRequired => 'اسم المستخدم مطلوب';

  @override
  String get usernameMinLength => 'يجب أن يكون اسم المستخدم 3 أحرف على الأقل';

  @override
  String get fullNameRequired => 'الاسم الكامل مطلوب';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get passwordMinLength => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get passwordLeaveEmpty =>
      'كلمة المرور (اتركها فارغة للاحتفاظ بالحالية)';

  @override
  String printError(String error) {
    return 'خطأ في الطباعة: $error';
  }

  @override
  String get invoice => 'الفاتورة';

  @override
  String invoiceLabel(String invoiceNumber) {
    return 'الفاتورة: $invoiceNumber';
  }

  @override
  String dateLabel(String date) {
    return 'التاريخ: $date';
  }

  @override
  String totalLabel(String total) {
    return 'الإجمالي: $total ر.س';
  }

  @override
  String statusLabelText(String status) {
    return 'الحالة: $status';
  }

  @override
  String get reprint => 'إعادة الطباعة';

  @override
  String get return_sale => 'إرجاع';

  @override
  String get itemsLabel => 'العناصر:';

  @override
  String get subtotalLabel => 'المجموع الفرعي:';

  @override
  String get vatLabel => 'الضريبة:';

  @override
  String get totalLabelColon => 'الإجمالي:';

  @override
  String get paidLabel => 'المدفوع:';

  @override
  String get changeLabel => 'الباقي:';

  @override
  String get saleReturnedSuccess => 'تم إرجاع البيع بنجاح';

  @override
  String get errorLoadingCategories => 'خطأ في تحميل الفئات';

  @override
  String get productNameRequired => 'اسم المنتج *';

  @override
  String get barcodeRequired => 'الرمز الشريطي *';

  @override
  String get categoryRequired => 'الفئة *';

  @override
  String get priceRequired => 'السعر *';

  @override
  String get costRequired => 'التكلفة *';

  @override
  String get quantityRequired => 'الكمية *';

  @override
  String get vatRateRequired => 'الضريبة % *';

  @override
  String get usernameFieldLabel => 'اسم المستخدم *';

  @override
  String get fullNameFieldLabel => 'الاسم الكامل *';

  @override
  String get passwordFieldLabel => 'كلمة المرور *';

  @override
  String get roleFieldLabel => 'الدور *';

  @override
  String get customerNameRequired => 'اسم العميل *';

  @override
  String get emailFieldLabel => 'البريد الإلكتروني';

  @override
  String get phoneFieldLabel => 'الهاتف';

  @override
  String get vatNumberFieldLabel => 'الرقم الضريبي';

  @override
  String get crnNumberFieldLabel => 'رقم السجل التجاري';

  @override
  String get saudiNationalAddress => 'العنوان الوطني السعودي';

  @override
  String get buildingNumber => 'رقم المبنى';

  @override
  String get streetName => 'اسم الشارع';

  @override
  String get district => 'الحي';

  @override
  String get city => 'المدينة';

  @override
  String get postalCode => 'الرمز البريدي';

  @override
  String get additionalNumber => 'الرقم الإضافي';

  @override
  String phoneLabel(String phone) {
    return 'الهاتف: $phone';
  }

  @override
  String emailLabel(String email) {
    return 'البريد: $email';
  }

  @override
  String vatLabel2(String vatNumber) {
    return 'ضريبة القيمة المضافة';
  }

  @override
  String addressLabel(String address) {
    return 'العنوان: $address';
  }

  @override
  String get cart => 'السلة';

  @override
  String cartItems(int count) {
    return '$count عناصر';
  }

  @override
  String get cartIsEmpty => 'السلة فارغة';

  @override
  String get scanOrEnterBarcode => 'امسح أو أدخل الرمز الشريطي...';

  @override
  String productAddedToCart(String productName) {
    return 'تمت إضافة $productName إلى السلة';
  }

  @override
  String get productNotFound => 'المنتج غير موجود';

  @override
  String get walkInCustomer => 'عميل عابر';

  @override
  String get amountPaid => 'المبلغ المدفوع';

  @override
  String changeColon(String amount) {
    return 'الباقي: $amount ر.س';
  }

  @override
  String get insufficientPayment => 'المبلغ المدفوع غير كافٍ';

  @override
  String get cashPayment => 'نقدي';

  @override
  String get cardPayment => 'بطاقة';

  @override
  String get transferPayment => 'تحويل';

  @override
  String get allDataSynchronized => 'جميع البيانات متزامنة بالفعل';

  @override
  String get noInternetConnection => 'لا يوجد اتصال بالإنترنت';

  @override
  String successfullySynchronized(int count) {
    return 'تمت مزامنة $count عنصر بنجاح';
  }

  @override
  String get syncFailed => 'فشلت المزامنة';

  @override
  String get exportInvoicesToPdf => 'تصدير الفواتير إلى PDF';

  @override
  String get exportCustomerInvoices => 'تصدير فواتير العميل إلى PDF';

  @override
  String customerLabel(String name) {
    return 'العميل: $name';
  }

  @override
  String get selectPeriod => 'اختر الفترة:';

  @override
  String get allTime => 'كل الفترات';

  @override
  String get lastThreeMonths => 'آخر 3 أشهر';

  @override
  String get preview => 'معاينة';

  @override
  String totalInvoices(int count) {
    return 'إجمالي الفواتير: $count';
  }

  @override
  String totalAmount(String amount) {
    return 'المبلغ الإجمالي: $amount';
  }

  @override
  String get exporting => 'جاري التصدير...';

  @override
  String get exportToPdf => 'تصدير إلى PDF';

  @override
  String get loadingStatistics => 'جاري تحميل الإحصائيات...';

  @override
  String get invoices => 'الفواتير';

  @override
  String invoicesCount(int count) {
    return 'الفواتير: $count';
  }

  @override
  String invoicesTotal(int count, String total) {
    return 'الفواتير: $count | الإجمالي: $total';
  }

  @override
  String get companyInfoNotFound =>
      'معلومات الشركة غير موجودة. يرجى التكوين في الإعدادات.';

  @override
  String get noInvoicesFound => 'لم يتم العثور على فواتير للفترة المحددة.';

  @override
  String exportedInvoicesSuccess(int count) {
    return 'تم تصدير $count فاتورة إلى PDF بنجاح';
  }

  @override
  String errorExportingInvoices(String error) {
    return 'خطأ في تصدير الفواتير: $error';
  }

  @override
  String loginSuccess(String username) {
    return 'تم تسجيل الدخول بنجاح! مرحباً $username';
  }

  @override
  String get defaultCredentials => 'بيانات الدخول الافتراضية';

  @override
  String get adminCredentials => 'المدير: admin / admin123';

  @override
  String get cashierCredentials => 'أمين الصندوق: cashier / cashier123';

  @override
  String get switchTheme => 'تبديل السمة';

  @override
  String get switchLanguage => 'تبديل اللغة';

  @override
  String get printSettings => 'إعدادات الطباعة';

  @override
  String get printFormat => 'تنسيق الطباعة';

  @override
  String get displayOptions => 'خيارات العرض';

  @override
  String get showCompanyLogo => 'إظهار شعار الشركة';

  @override
  String get displayLogoPlaceholder => 'عرض مكان الشعار في رأس الفاتورة';

  @override
  String get showQrCode => 'إظهار رمز الاستجابة السريعة';

  @override
  String get displayZatcaQrCode =>
      'عرض رمز QR المتوافق مع هيئة الزكاة والضريبة والجمارك';

  @override
  String get showCustomerInformation => 'إظهار معلومات العميل';

  @override
  String get displayCustomerDetails => 'عرض تفاصيل العميل عند توفرها';

  @override
  String get showNotes => 'إظهار الملاحظات';

  @override
  String get displaySaleNotes => 'عرض ملاحظات البيع عند توفرها';

  @override
  String get selectFormat => 'اختر التنسيق';

  @override
  String get printNow => 'اطبع الآن';

  @override
  String get thermalReceiptPrinter => 'طابعة إيصالات حرارية';

  @override
  String get standardPaperFormat => 'تنسيق ورق قياسي';

  @override
  String get a4Format => 'A4 (210×297 ملم)';

  @override
  String get thermal80mmFormat => 'حراري 80 ملم';

  @override
  String get thermal58mmFormat => 'حراري 58 ملم';

  @override
  String mmWidth(String width) {
    return 'عرض $width ملم';
  }

  @override
  String get analyticsDashboard => 'لوحة التحليلات';

  @override
  String get keyMetrics => 'المؤشرات الرئيسية';

  @override
  String get totalVat => 'إجمالي ضريبة القيمة المضافة';

  @override
  String get vatCollected => 'ضريبة القيمة المضافة المحصلة';

  @override
  String get activeProducts => 'نشط';

  @override
  String get activeCustomers => 'نشط';

  @override
  String get completedInvoices => 'فاتورة مكتملة';

  @override
  String get bestSellingProducts => 'المنتجات الأكثر مبيعاً';

  @override
  String get lowStockNotifications => 'تنبيهات المخزون المنخفض';

  @override
  String get latestSalesInvoices => 'آخر فواتير المبيعات';

  @override
  String get salesTrend => 'اتجاه المبيعات';

  @override
  String get salesByCategory => 'المبيعات حسب الفئة';

  @override
  String get timePeriod => 'الفترة الزمنية';

  @override
  String get last7Days => 'آخر 7 أيام';

  @override
  String get customPeriod => 'فترة مخصصة';

  @override
  String get selectStartAndEndDates =>
      'حدد تاريخ البداية والنهاية للفترة المخصصة';

  @override
  String get selectStartDate => 'اختر تاريخ البداية';

  @override
  String get selectEndDate => 'اختر تاريخ النهاية';

  @override
  String get duration => 'المدة';

  @override
  String get days => 'أيام';

  @override
  String durationDays(int count) {
    return 'المدة: $count أيام';
  }

  @override
  String get cancelled => 'ملغى';

  @override
  String get unitsLeft => 'وحدة متبقية';

  @override
  String get critical => 'حرج';

  @override
  String viewAllItems(int count) {
    return 'عرض كل $count عنصر';
  }

  @override
  String viewAllLowStockItems(int count) {
    return 'عرض كل $count عنصر منخفض المخزون';
  }

  @override
  String viewAllInvoices(int count) {
    return 'عرض كل $count فاتورة';
  }

  @override
  String get noSalesDataAvailable => 'لا توجد بيانات مبيعات متاحة';

  @override
  String get noInvoicesAvailable => 'لا توجد فواتير متاحة';

  @override
  String get noCategoryDataAvailable => 'لا توجد بيانات فئات متاحة';

  @override
  String get allProductsWellStocked => 'جميع المنتجات متوفرة بمخزون جيد';

  @override
  String errorLoadingInvoice(String error) {
    return 'خطأ في تحميل الفاتورة: $error';
  }

  @override
  String get refreshDashboard => 'تحديث لوحة التحكم';

  @override
  String get invoiceStatistics => 'إحصائيات الفواتير';

  @override
  String get loadingDashboardData => 'جاري تحميل بيانات لوحة التحكم...';

  @override
  String get errorLoadingDashboard => 'خطأ في تحميل لوحة التحكم';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get salesLabel => 'المبيعات';

  @override
  String quantitySold(String quantity) {
    return 'الكمية: $quantity';
  }

  @override
  String salesCount(int count) {
    return '$count عملية بيع';
  }

  @override
  String get transfer => 'تحويل';

  @override
  String get vatEnabled => 'الضريبة مفعلة';

  @override
  String get vatDisabled => 'الضريبة غير مفعلة';

  @override
  String get vatEnabledDescription =>
      'سيتم حساب الضريبة وإضافتها إلى أسعار المنتجات';

  @override
  String get vatDisabledDescription => 'حساب الضريبة معطل';

  @override
  String get businessDetailsAndContactInformation =>
      'تفاصيل العمل ومعلومات الاتصال';

  @override
  String get configureInvoicePrintingOptions => 'تهيئة خيارات طباعة الفاتورة';

  @override
  String get defaultVatRate => 'معدل الضريبة الافتراضي';

  @override
  String get setDefaultVatRateDescription =>
      'حدد معدل الضريبة الافتراضي ليتم تطبيقه تلقائيًا على جميع المنتجات';

  @override
  String get vatRateLabel => 'معدل الضريبة (%)';

  @override
  String get vatRateHint => '15.0';

  @override
  String get currentVatRate => 'معدل الضريبة الحالي';

  @override
  String get vatCalculationMethod => 'طريقة حساب الضريبة';

  @override
  String get chooseVatCalculationMethod =>
      'اختر ما إذا كانت الضريبة مدرجة في سعر المنتج أو تضاف لاحقًا';

  @override
  String get vatIncludedInPrice => 'السعر شامل الضريبة';

  @override
  String get vatExcludedFromPrice => 'السعر غير شامل الضريبة';

  @override
  String get vatIncludedInPriceDescription =>
      'أسعار المنتجات تشمل الضريبة (سيتم استخراج الضريبة من الإجمالي)';

  @override
  String get vatExcludedFromPriceDescription =>
      'أسعار المنتجات لا تشمل الضريبة (سيتم إضافة الضريبة إلى الإجمالي)';

  @override
  String get vatRateAppliedToNewProducts =>
      'سيتم تطبيق معدل الضريبة هذا تلقائيًا على جميع المنتجات الجديدة. التغييرات تُطبّق فورًا.';

  @override
  String vatIncludedInPriceNote(String rate) {
    return 'ضريبة القيمة المضافة $rate% - مدرجة في السعر';
  }

  @override
  String vatExcludedFromPriceNote(String rate) {
    return 'ضريبة القيمة المضافة $rate% - مستبعدة من السعر';
  }

  @override
  String get pricesIncludeVatNote =>
      'الأسعار الموضحة تشمل الضريبة - سيتم استخراج الضريبة من السعر المذكور';

  @override
  String get pricesExcludeVatNote =>
      'الأسعار الموضحة لا تشمل الضريبة - سيتم إضافة الضريبة على السعر المذكور';

  @override
  String get priceVatIncluded => 'السعر (شامل الضريبة)';

  @override
  String get priceVatExcluded => 'السعر (غير شامل الضريبة)';

  @override
  String get beforeVat => 'قبل الضريبة';

  @override
  String get afterVat => 'بعد الضريبة';

  @override
  String get vatBreakdown => 'تفصيل الضريبة';

  @override
  String get amount => 'المبلغ';

  @override
  String vatAmountCalculatedAutomatically(String rate) {
    return 'مبلغ الضريبة محسوب تلقائيًا ($rate%)';
  }
}
