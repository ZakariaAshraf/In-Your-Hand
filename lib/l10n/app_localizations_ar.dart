// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get welcome => 'مرحباً';

  @override
  String get settings => 'الاعدادات';

  @override
  String get search => 'بحث';

  @override
  String get themeMode => 'وضع الألوان';

  @override
  String get language => 'اللغة';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get pleaseWriteEmail => 'يرجى كتابة عنوان بريدك الإلكتروني';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get profileUpdatedSuccessfully => 'تم تحديث الملف الشخصي بنجاح!';

  @override
  String get password => 'كلمة المرور';

  @override
  String get forgetPassword => 'نسيت كلمة المرور؟';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get dontHaveAccount => 'ليس لديك حساب';

  @override
  String get create => 'إنشاء!';

  @override
  String get register => 'تسجيل';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل';

  @override
  String get loginFailed =>
      'فشل تسجيل الدخول. يرجى التحقق من البريد الإلكتروني أو كلمة المرور';

  @override
  String get registerFailed => 'فشل التسجيل. يرجى التحقق من جميع الحقول';

  @override
  String get continuee => 'متابعة';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String error(Object error) {
    return 'خطأ: $error';
  }

  @override
  String get errorTitle => 'خطأ';

  @override
  String get skip => 'تخطي';

  @override
  String get letsStart => 'لنبدأ ->';

  @override
  String get chooseYourCharacter => 'اختر شخصيتك';

  @override
  String get chooseCharacterDescription =>
      'اختر الملف الشخصي الذي يصفك بشكل أفضل لتخصيص رحلتك.';

  @override
  String get pleaseSelectCharacter => 'يرجى اختيار شخصية أولاً';

  @override
  String get continueAsGuest => 'المتابعة كضيف';

  @override
  String get joinApplication => 'انضم إلى التطبيق';

  @override
  String get pleaseFillAllFields => 'يرجى ملء جميع الحقول';

  @override
  String get orContinueWith => 'أو المتابعة مع';

  @override
  String get selectAvatar => 'اختر الصورة الرمزية';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get preferences => 'التفضيلات';

  @override
  String get supportAndAccount => 'الدعم والحساب';

  @override
  String get helpAndSupport => 'المساعدة والدعم';

  @override
  String get cairoEgypt => 'القاهرة، مصر';

  @override
  String get home => 'الرئيسية';

  @override
  String get profile => 'الاعدادات';

  @override
  String get notAvailable => 'غير متاح';

  @override
  String get orders => 'الطلبات';

  @override
  String get clients => 'العملاء';

  @override
  String get totalOrders => 'إجمالي الطلبات';

  @override
  String get unpaid => 'غير مدفوع';

  @override
  String get addOrder => '+ إضافة طلب';

  @override
  String get addOrderTitle => 'إضافة طلب';

  @override
  String get addClient => '+ إضافة عميل';

  @override
  String get addClientTitle => 'إضافة عميل';

  @override
  String get noOrders => 'لا توجد طلبات';

  @override
  String get noOrdersForThisStatus => 'لا توجد طلبات لهذه الحالة';

  @override
  String get youDontHaveAnyOrders => 'ليس لديك أي طلبات';

  @override
  String get client => 'العميل';

  @override
  String get selectClient => 'اختر عميلاً';

  @override
  String get description => 'الوصف';

  @override
  String get totalAmountLabel => 'المبلغ الإجمالي';

  @override
  String get whatIsOrderFor => 'ما هو الطلب؟';

  @override
  String get totalAmount => 'المبلغ الإجمالي (\$) *';

  @override
  String get paidAmount => 'المبلغ المدفوع (\$)';

  @override
  String get processing => 'جاري المعالجة';

  @override
  String get saveOrder => '✓ حفظ الطلب';

  @override
  String get paidAmountCannotExceedTotal =>
      'المبلغ المدفوع لا يمكن أن يتجاوز الإجمالي';

  @override
  String get noClientsFound => 'لم يتم العثور على عملاء';

  @override
  String get searchClient => 'بحث عن عميل...';

  @override
  String get orderDetails => 'تفاصيل الطلب';

  @override
  String get deletedClient => 'عميل محذوف';

  @override
  String get unknownClient => 'عميل غير معروف';

  @override
  String get totalUnpaid => 'إجمالي غير المدفوع';

  @override
  String get addPayment => 'إضافة دفعة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get created => 'تاريخ الإنشاء';

  @override
  String get status => 'الحالة';

  @override
  String get deleteOrder => 'حذف الطلب';

  @override
  String get deleteOrderConfirm => 'هل أنت متأكد أنك تريد حذف هذا الطلب؟';

  @override
  String get delete => 'حذف';

  @override
  String get name => 'الاسم';

  @override
  String get clientName => 'اسم العميل';

  @override
  String get phone => 'الهاتف';

  @override
  String get notes => 'ملاحظات';

  @override
  String get notesAboutClient => 'ملاحظات عن هذا العميل';

  @override
  String get saveClient => '✓ حفظ العميل';

  @override
  String get noResults => 'لا توجد نتائج';

  @override
  String get noClientsMatchSearch => 'لا يوجد عملاء يطابقون بحثك';

  @override
  String get emptyList => 'قائمة فارغة';

  @override
  String get youDontHaveAnyClients => 'ليس لديك أي عملاء';

  @override
  String get editClient => 'تعديل العميل';

  @override
  String get edit => 'تعديل';

  @override
  String get deleteClient => 'حذف العميل';

  @override
  String get deleteClientConfirm => 'هل أنت متأكد أنك تريد حذف هذا العميل؟';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get orderFilterAll => 'الكل';

  @override
  String get orderFilterPending => 'قيد الانتظار';

  @override
  String get orderFilterPartial => 'جزئي';

  @override
  String get orderFilterPaid => 'مدفوع';

  @override
  String get orderStatusPending => 'قيد الانتظار';

  @override
  String get orderStatusPartial => 'جزئي';

  @override
  String get orderStatusPaid => 'مدفوع';

  @override
  String get errorLoadingClients => 'خطأ في تحميل العملاء';

  @override
  String get whatsappDefaultMessage => 'مرحباً، من تطبيق إن يور هاند';

  @override
  String get checkAllData => 'عرض كل البيانات';

  @override
  String get dashboardTitle => 'لوحة التحكم';

  @override
  String get totalClientsWithDebt => 'إجمالي العملاء المديونين';

  @override
  String get clientsWithDebtTitle => 'العملاء المديونون';

  @override
  String get checkThem => 'عرضهم';

  @override
  String get totalPaid => 'إجمالي المدفوع';

  @override
  String get sendReminder => 'إرسال تذكير';

  @override
  String get paymentHistory => 'سجل المدفوعات';

  @override
  String get amountLabel => 'المبلغ';

  @override
  String get dateLabel => 'التاريخ';

  @override
  String get totalPaidMustNotExceedTotalAmount =>
      'يجب ألا يتجاوز إجمالي المدفوع المبلغ الإجمالي';

  @override
  String get showReport => 'عرض التقرير';

  @override
  String get pdfPreviewTitle => 'معاينة PDF';
}
