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
  String get loginSubtitle => 'نظام نقاط البيع';

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
  String get totalSales => 'إجمالي المبيعات';

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
  String get addProduct => 'إضافة منتج';

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
  String get cost => 'التكلفة';

  @override
  String get quantity => 'الكمية';

  @override
  String get category => 'الفئة';

  @override
  String get description => 'الوصف';

  @override
  String get barcode => 'الرمز الشريطي';

  @override
  String get inStock => 'متوفر';

  @override
  String get outOfStock => 'نفذ من المخزون';

  @override
  String get lowStock => 'مخزون منخفض';

  @override
  String get productDetails => 'تفاصيل المنتج';

  @override
  String get stockLevel => 'مستوى المخزون';

  @override
  String get categories => 'الفئات';

  @override
  String get addCategory => 'إضافة فئة';

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
  String get cash => 'نقدي';

  @override
  String get card => 'بطاقة';

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
  String get cashier => 'أمين الصندوق';

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
  String get print => 'طباعة';

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
  String get cashierMode => 'وضع أمين الصندوق';

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
  String get companyInformation => 'معلومات الشركة';

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
}
