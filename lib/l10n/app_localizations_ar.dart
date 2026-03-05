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
  String get welcomeMessage => 'ادارتك الماليه بقت في ايديك';

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
  String get recommendFeature => 'اقتراح ميزة';

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
  String get inYourHand => 'في ايديك';

  @override
  String get allInYourHand => 'كل حاجه في ايديك';

  @override
  String get signInMessage => 'سجل دخولك وشوف اللي فاتك فالبيزنس بتاعك';

  @override
  String get registerMessage => 'ادخل دلوقتي وتابع البيزنس بتاعك';

  @override
  String get pleaseSelectCharacter => 'يرجى اختيار شخصية أولاً';

  @override
  String get continueAsGuest => 'المتابعة كضيف';

  @override
  String get joinApplication => 'انضم إلى التطبيق';

  @override
  String get invalidEmail =>
      'يرجى إدخال بريد إلكتروني صحيح (مثال: name@gmail.com أو name@hotmail.com)';

  @override
  String get passwordRequirements => 'كلمة المرور يجب أن تحتوي على:';

  @override
  String get passwordRequirementLength => '8 أحرف على الأقل';

  @override
  String get passwordRequirementUppercase => 'حرف كبير واحد (A-Z)';

  @override
  String get passwordRequirementLowercase => 'حرف صغير واحد (a-z)';

  @override
  String get passwordRequirementDigit => 'رقم واحد (0-9)';

  @override
  String get passwordTooWeak => 'يرجى تقوية كلمة المرور (انظر المتطلبات أدناه)';

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
  String get egypt => 'مصر';

  @override
  String get home => 'الرئيسية';

  @override
  String get profile => 'الاعدادات';

  @override
  String get notAvailable => 'غير متاح';

  @override
  String get addNote => 'اضافة ملاحظة';

  @override
  String get egp => 'جنيه';

  @override
  String get clientReport => 'تقرير العميل';

  @override
  String get addYourNote => 'قم باضافة ملاحظتك';

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
  String get printReport => 'طباعة التقرير';

  @override
  String get total => 'الاجمالي: ';

  @override
  String get paid => 'المدفوع: ';

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

  @override
  String get addOrderByVoice => 'إضافة طلب بالصوت';

  @override
  String get tapToSpeak => 'اضغط على الميكروفون وقل طلبك';

  @override
  String get listening => 'جاري الاستماع...';

  @override
  String get voicePermissionDenied =>
      'مطلوب السماح للميكروفون لإضافة الطلبات بالصوت';

  @override
  String get allowMicrophone => 'يرجى السماح للميكروفون من إعدادات التطبيق';

  @override
  String get transcript => 'ما قلته';

  @override
  String get addOrderFromVoice => 'إضافة هذا الطلب';

  @override
  String get orderAddedByVoice => 'تم إضافة الطلب من الصوت';

  @override
  String get geminiNotConfigured =>
      'أضف مفتاح Gemini API في app_keys.dart لاستخدام الطلبات الصوتية';

  @override
  String get aboutUs => 'من نحن';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get termsAndConditions => 'الشروط والأحكام';

  @override
  String get aboutUsContent =>
      'بين إيديك هو تطبيق إدارة أعمال مصمم لأصحاب المشاريع الصغيرة في مصر الذين يبيعون بالأجل ويحتاجون إلى طريقة بسيطة لمتابعة ما يدين به العملاء.\n\nبدلاً من تسجيل الديون في دفتر أو محاولة التذكر من دفع ومن لم يدفع، يحفظ تطبيق بين إيديك كل شيء في مكان واحد — العملاء، الطلبات، المدفوعات، والتقارير — في متناول يدك على هاتفك في أي وقت.\n\nأبرز المميزات:\n• إضافة وإدارة العملاء مع بيانات التواصل\n• إنشاء الطلبات ومتابعة المدفوع والمتبقي\n• تسجيل الدفعات الجزئية على مدار الوقت\n• إرسال تذكير بالدفع عبر واتساب مباشرة من التطبيق\n• إضافة الطلبات بالصوت باستخدام الذكاء الاصطناعي — تكلم بالعربي أو الإنجليزي\n• إنشاء وطباعة تقارير PDF احترافية لكل طلب أو عميل\n• دعم كامل للعربية والإنجليزية مع تخطيط RTL\n• الوضع الداكن والفاتح\n\nصُمم تطبيق بين إيديك ليكون بسيطاً وسريعاً ومركزاً. لا ميزات غير ضرورية — فقط الأدوات التي يحتاجها صاحب العمل فعلاً كل يوم.\n\nشكراً لاستخدامك تطبيق بين إيديك.';

  @override
  String get privacyPolicyContent =>
      'سياسة الخصوصية — بين إيديك\n\nآخر تحديث: 2025\n\n1. المعلومات التي نجمعها\nيجمع تطبيق بين إيديك فقط المعلومات التي تقدمها مباشرة:\n• اسمك وبريدك الإلكتروني عند التسجيل\n• أسماء العملاء وأرقام هواتفهم وملاحظاتهم التي تضيفها\n• تفاصيل الطلبات وسجلات المدفوعات التي تنشئها\n• صورة الملف الشخصي الاختيارية\n\nنحن لا نجمع بيانات الموقع أو معرّفات الجهاز أو أي معلومات تتجاوز ما تدخله في التطبيق.\n\n2. كيف نستخدم معلوماتك\nتُستخدم بياناتك فقط لتوفير وظائف التطبيق:\n• عرض عملائك وطلباتك\n• حساب ملخصات المدفوعات والتقارير\n• إرسال تذكيرات واتساب (فقط عند الضغط على الزر)\n• إنشاء تقارير PDF\n\nنحن لا نبيع أو نشارك أو نؤجر معلوماتك الشخصية لأي طرف ثالث.\n\n3. تخزين البيانات\nيتم تخزين جميع البيانات بأمان في Google Firebase (Firestore و Firebase Auth). Firebase هي خدمة من Google تمتثل لمعايير حماية البيانات الدولية. بياناتك مرتبطة بحسابك ولا يمكن للمستخدمين الآخرين الوصول إليها.\n\n4. ميزة الصوت\nإذا استخدمت ميزة الطلب الصوتي، يتم معالجة الصوت المنطوق بواسطة خدمة التعرف على الكلام من Google ثم تحليله بواسطة Google Gemini AI لاستخراج تفاصيل الطلب. لا يقوم التطبيق بتخزين الصوت.\n\n5. حذف البيانات\nيمكنك حذف حسابك وجميع البيانات المرتبطة به في أي وقت عن طريق التواصل معنا. العملاء المحذوفون يتم إخفاؤهم (حذف ناعم) ويمكن حذفهم نهائياً عند الطلب.\n\n6. الأمان\nنتخذ خطوات معقولة لحماية بياناتك. الوصول إلى حسابك محمي بواسطة Firebase Authentication. نوصي باستخدام كلمة مرور قوية.\n\n7. التغييرات على هذه السياسة\nقد نحدّث هذه السياسة من وقت لآخر. استمرار استخدام التطبيق بعد التغييرات يعني قبولك للسياسة المحدثة.\n\n8. التواصل\nلأي أسئلة تتعلق بالخصوصية، يرجى التواصل معنا عبر نموذج التغذية الراجعة في التطبيق.';

  @override
  String get termsAndConditionsContent =>
      'الشروط والأحكام — بين إيديك\n\nآخر تحديث: 2025\n\nباستخدام تطبيق بين إيديك، فإنك توافق على الشروط التالية. يرجى قراءتها بعناية.\n\n1. استخدام التطبيق\nتطبيق بين إيديك مقدَّم للاستخدام الشخصي والمشاريع الصغيرة. توافق على استخدام التطبيق للأغراض القانونية فقط وبطريقة لا تنتهك حقوق الآخرين.\n\n2. حسابك\nأنت مسؤول عن الحفاظ على سرية بيانات حسابك. أنت مسؤول عن جميع الأنشطة التي تحدث تحت حسابك. أخطرنا فوراً إذا اشتبهت في وصول غير مصرح به.\n\n3. بياناتك\nأنت تمتلك البيانات التي تدخلها في التطبيق (العملاء، الطلبات، المدفوعات). باستخدام التطبيق، تمنحنا إذناً لتخزين هذه البيانات ومعالجتها فقط لتقديم خدمات التطبيق.\n\n4. دقة المعلومات\nتطبيق بين إيديك هو أداة لمساعدتك في تتبع بيانات عملك. دقة التقارير والإجماليات والملخصات تعتمد كلياً على البيانات التي تدخلها. نحن لسنا مسؤولين عن القرارات المالية المتخذة بناءً على المعلومات الموجودة في التطبيق.\n\n5. تكامل واتساب\nميزة تذكير واتساب تفتح واتساب برسالة جاهزة. إرسال الرسالة هو إجراءك أنت. نحن لسنا مسؤولين عن محتوى الرسائل التي ترسلها أو أي عواقب ناتجة عنها.\n\n6. ميزات الصوت والذكاء الاصطناعي\nتستخدم ميزة الطلب الصوتي التعرف على الكلام والذكاء الاصطناعي لاقتراح تفاصيل الطلب. أنت مسؤول عن مراجعة وتأكيد البيانات المقترحة قبل الحفظ. نحن لسنا مسؤولين عن الأخطاء في الاقتراحات المولّدة بالذكاء الاصطناعي.\n\n7. توفر الخدمة\nنسعى للحفاظ على توفر التطبيق في جميع الأوقات لكننا لا نضمن الخدمة المتواصلة. قد نحدّث أو نعدّل أو نوقف الميزات في أي وقت.\n\n8. تحديد المسؤولية\nتطبيق بين إيديك مقدَّم كما هو. نحن لسنا مسؤولين عن أي فقدان للبيانات أو خسارة مالية أو أضرار أخرى ناتجة عن استخدام التطبيق أو عدم القدرة على استخدامه.\n\n9. التغييرات على الشروط\nقد نحدّث هذه الشروط من وقت لآخر. استمرار استخدام التطبيق بعد التغييرات يعني قبول الشروط الجديدة.\n\n10. التواصل\nللأسئلة حول هذه الشروط، يرجى التواصل معنا عبر نموذج التغذية الراجعة في التطبيق.';

  @override
  String get confirmOrder => 'تأكيد الطلب';

  @override
  String get confirmOrderMessage => 'راجع الطلب أدناه. هل تضيفه؟';

  @override
  String get confirm => 'تأكيد';
}
