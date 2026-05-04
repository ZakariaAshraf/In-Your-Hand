// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcome => 'Welcome';

  @override
  String get welcomeMessage => 'Your financial management is now in your hands';

  @override
  String get settings => 'Settings';

  @override
  String get search => 'Search';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get language => 'Language';

  @override
  String get changePassword => 'Change Password';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get logout => 'Logout';

  @override
  String get pleaseWriteEmail => 'Please write your Email Address';

  @override
  String get email => 'Email';

  @override
  String get fullName => 'Full Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully!';

  @override
  String get password => 'Password';

  @override
  String get forgetPassword => 'Forget Password ?';

  @override
  String get login => 'Login';

  @override
  String get dontHaveAccount => 'Don\'t have an account';

  @override
  String get create => 'Create!';

  @override
  String get register => 'Register';

  @override
  String get alreadyHaveAccount => 'Already have an account';

  @override
  String get loginFailed => 'Login failed. Please check your email or password';

  @override
  String get registerFailed => 'Register failed. Please check all fields';

  @override
  String get continuee => 'Continue';

  @override
  String get seeAll => 'See All';

  @override
  String get recommendFeature => 'Recommend a Feature';

  @override
  String error(Object error) {
    return 'Error: $error';
  }

  @override
  String get errorTitle => 'Error';

  @override
  String get skip => 'Skip';

  @override
  String get letsStart => 'Let\'s Start ->';

  @override
  String get chooseYourCharacter => 'Choose Your Character';

  @override
  String get chooseCharacterDescription =>
      'Select the profile that best describes you to personalize your journey.';

  @override
  String get businessMan => 'Business Man';

  @override
  String get businessWoman => 'Business Woman';

  @override
  String get inYourHand => 'In Your Hand.';

  @override
  String get allInYourHand => 'All in your hand';

  @override
  String get signInMessage =>
      'Sign in to show what you miss with your business';

  @override
  String get registerMessage => 'Register now and track your business';

  @override
  String get pleaseSelectCharacter => 'Please select a character first';

  @override
  String get continueAsGuest => 'Continue as a Guest';

  @override
  String get joinApplication => 'Join Application';

  @override
  String get invalidEmail =>
      'Please enter a valid email (e.g. name@gmail.com or name@hotmail.com)';

  @override
  String get passwordRequirements => 'Password must have:';

  @override
  String get passwordRequirementLength => 'At least 8 characters';

  @override
  String get passwordRequirementUppercase => 'One uppercase letter (A-Z)';

  @override
  String get passwordRequirementLowercase => 'One lowercase letter (a-z)';

  @override
  String get passwordRequirementDigit => 'One number (0-9)';

  @override
  String get passwordTooWeak =>
      'Please make the password stronger (see requirements below)';

  @override
  String get pleaseFillAllFields => 'Please fill all fields';

  @override
  String get orContinueWith => 'or continue with';

  @override
  String get selectAvatar => 'Select Avatar';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get preferences => 'PREFERENCES';

  @override
  String get supportAndAccount => 'SUPPORT & ACCOUNT';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get helpAddClient =>
      'Add a client from the Clients tab or the + button on Home';

  @override
  String get helpAddOrder =>
      'Add an order manually or by voice from the Orders tab';

  @override
  String get helpAddPayment =>
      'Open any order to record a partial or full payment';

  @override
  String get helpGeneratePdf =>
      'Open a client or order to generate and share a PDF report';

  @override
  String get helpVoiceOrder =>
      'Tap the mic on Add Order and speak in Arabic or English';

  @override
  String get helpContactMessage =>
      'Have a question or found a bug? We would love to hear from you.';

  @override
  String get helpSendFeedback => 'Send Feedback';

  @override
  String get cairoEgypt => 'Cairo, Egypt';

  @override
  String get egypt => 'Egypt';

  @override
  String get home => 'Home';

  @override
  String get profile => 'Settings';

  @override
  String get notAvailable => 'NOT AVAILABLE';

  @override
  String get addNote => 'Add Note';

  @override
  String get egp => 'EGP';

  @override
  String get clientReport => 'Client Report';

  @override
  String get addYourNote => 'Add your note';

  @override
  String get orders => 'Orders';

  @override
  String get clients => 'Clients';

  @override
  String get totalOrders => 'Total Orders';

  @override
  String get unpaid => 'Unpaid';

  @override
  String get addOrder => '+ Add Order';

  @override
  String get addOrderTitle => 'Add Order';

  @override
  String get addClient => '+ Add Client';

  @override
  String get addClientTitle => 'Add Client';

  @override
  String get noOrders => 'No orders';

  @override
  String get noOrdersForThisStatus => 'No orders for this status';

  @override
  String get youDontHaveAnyOrders => 'You don\'t have any orders';

  @override
  String get client => 'Client';

  @override
  String get selectClient => 'Select a client';

  @override
  String get description => 'Description';

  @override
  String get totalAmountLabel => 'Total Amount';

  @override
  String get whatIsOrderFor => 'What is the order for?';

  @override
  String get totalAmount => 'Total Amount (\$) *';

  @override
  String get paidAmount => 'Paid Amount (\$)';

  @override
  String get processing => 'Processing';

  @override
  String get saveOrder => '✓ Save Order';

  @override
  String get paidAmountCannotExceedTotal =>
      'Paid amount cannot exceed total amount';

  @override
  String get noClientsFound => 'No clients found';

  @override
  String get searchClient => 'Search client...';

  @override
  String get orderDetails => 'Order Details';

  @override
  String get deletedClient => 'Deleted Client';

  @override
  String get unknownClient => 'Unknown Client';

  @override
  String get totalUnpaid => 'Total Unpaid';

  @override
  String get addPayment => 'Add Payment';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get created => 'Created';

  @override
  String get status => 'Status';

  @override
  String get deleteOrder => 'Delete Order';

  @override
  String get deleteOrderConfirm =>
      'Are you sure you want to delete this order?';

  @override
  String get delete => 'Delete';

  @override
  String get name => 'Name';

  @override
  String get clientName => 'Client Name';

  @override
  String get phone => 'Phone';

  @override
  String get notes => 'Notes';

  @override
  String get notesAboutClient => 'Notes about this client';

  @override
  String get saveClient => '✓ Save Client';

  @override
  String get printReport => 'Print Report';

  @override
  String get total => 'total: ';

  @override
  String get paid => 'paid: ';

  @override
  String get noResults => 'No results';

  @override
  String get noClientsMatchSearch => 'No clients match your search';

  @override
  String get emptyList => 'Empty List';

  @override
  String get youDontHaveAnyClients => 'You don\'t have any clients';

  @override
  String get editClient => 'Edit Client';

  @override
  String get edit => 'Edit';

  @override
  String get call => 'Call';

  @override
  String get whatsApp => 'WhatsApp';

  @override
  String get report => 'Report';

  @override
  String get deleteClient => 'Delete Client';

  @override
  String get deleteClientConfirm =>
      'Are you sure you want to delete this client?';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get orderFilterAll => 'All';

  @override
  String get orderFilterPending => 'Pending';

  @override
  String get orderFilterPartial => 'Partial';

  @override
  String get orderFilterPaid => 'Paid';

  @override
  String get orderStatusPending => 'Pending';

  @override
  String get orderStatusPartial => 'Partial';

  @override
  String get orderStatusPaid => 'Paid';

  @override
  String get errorLoadingClients => 'Error loading clients';

  @override
  String get whatsappDefaultMessage => 'Hello, from In Your Hand app';

  @override
  String get checkAllData => 'Check all data';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get totalClientsWithDebt => 'Total clients with debt';

  @override
  String get clientsWithDebtTitle => 'Clients with debt';

  @override
  String get checkThem => 'Check them';

  @override
  String get totalPaid => 'Total Paid';

  @override
  String get sendReminder => 'Send Reminder';

  @override
  String get paymentHistory => 'Payment History';

  @override
  String get amountLabel => 'Amount';

  @override
  String get dateLabel => 'Date';

  @override
  String get totalPaidMustNotExceedTotalAmount =>
      'Total paid must not exceed total amount';

  @override
  String get showReport => 'Show Report';

  @override
  String get pdfPreviewTitle => 'PDF Preview';

  @override
  String get addOrderByVoice => 'Add order by voice';

  @override
  String get tapToSpeak => 'Tap the mic and speak your order';

  @override
  String get listening => 'Listening...';

  @override
  String get voicePermissionDenied =>
      'Microphone access is required for voice orders';

  @override
  String get allowMicrophone => 'Please allow microphone in app settings';

  @override
  String get transcript => 'What you said';

  @override
  String get addOrderFromVoice => 'Add this order';

  @override
  String get orderAddedByVoice => 'Order added from voice';

  @override
  String get geminiQuotaExceeded =>
      'Service is temporarily busy. Please try again in a few minutes.';

  @override
  String get voiceLimitReachedTitle => 'Monthly voice limit reached';

  @override
  String get voiceLimitReachedBody =>
      'You have 1 free voice order per month. You\'ve already used yours for this month. Unlimited voice orders are coming soon for premium users.';

  @override
  String get recommendFeatureHint =>
      'Tell us what you\'d like to see in the app...';

  @override
  String get feedbackSent => 'Thanks for your feedback!';

  @override
  String get feedbackFailed => 'Failed to send. Please try again.';

  @override
  String get howToUseTheApp => 'How to use the app';

  @override
  String get geminiNotConfigured =>
      'Add your Gemini API key in app_keys.dart to use voice orders';

  @override
  String get aboutUs => 'About Us';

  @override
  String get addNumberWithoutFirst0 => 'Add Number Without First 0';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsAndConditions => 'Terms and Conditions';

  @override
  String get aboutUsContent =>
      'In Your Hand is a business management app built for small business owners in Egypt who sell on credit and need a simple way to track what clients owe them.\n\nInstead of writing debts in a notebook or trying to remember who paid and who didn\'t, In Your Hand keeps everything in one place — clients, orders, payments, and reports — accessible from your phone at any time.\n\nKey features:\n• Add and manage clients with their contact details\n• Create orders and track how much has been paid and how much is still owed\n• Record partial payments over time\n• Send WhatsApp payment reminders directly from the app\n• Add orders by voice using AI — speak in Arabic or English\n• Generate and print professional PDF reports per order or per client\n• Full Arabic and English support with RTL layout\n• Dark mode and light mode\n\nIn Your Hand was designed to be simple, fast, and focused. No unnecessary features — just the tools a business owner actually needs every day.\n\nThank you for using In Your Hand.';

  @override
  String get privacyPolicyContent =>
      'Privacy Policy — In Your Hand\n\nLast updated: 2026\n\n1. Information We Collect\nIn Your Hand collects only the information you provide directly:\n• Your name and email address when you register\n• Client names, phone numbers, and notes you add\n• Order details and payment records you create\n• Optional profile photo\n\nWe do not collect location data, device identifiers, or any information beyond what you enter into the app.\n\n2. How We Use Your Information\nYour data is used solely to provide the app\'s functionality:\n• Displaying your clients and orders\n• Calculating payment summaries and reports\n• Sending WhatsApp reminders (only when you tap the button)\n• Generating PDF reports\n\nWe do not sell, share, or rent your personal information to any third party.\n\n3. Data Storage\nAll data is stored securely in Google Firebase (Firestore and Firebase Auth). Firebase is a Google service that complies with international data protection standards. Your data is associated with your account and is not accessible to other users.\n\n4. Voice Feature\nIf you use the voice order feature, your spoken audio is processed by Google\'s speech recognition service and then analyzed by Google Gemini AI to extract order details. Audio is not stored by the app.\n\n5. Data Deletion\nYou can delete your account and all associated data directly from Settings → Edit Profile → Delete Account.\n\n6. Security\nWe take reasonable steps to protect your data. Access to your account is protected by Firebase Authentication. We recommend using a strong password.\n\n7. Changes to This Policy\nWe may update this policy from time to time. Continued use of the app after changes means you accept the updated policy.\n\n8. Contact\nFor any privacy-related questions, please contact us through the app\'s feedback form.';

  @override
  String get termsAndConditionsContent =>
      'Terms and Conditions — In Your Hand\n\nLast updated: 2026\n\nBy using In Your Hand, you agree to the following terms. Please read them carefully.\n\n1. Use of the App\nIn Your Hand is provided for personal and small business use. You agree to use the app only for lawful purposes and in a way that does not infringe the rights of others.\n\n2. Your Account\nYou are responsible for maintaining the confidentiality of your account credentials. You are responsible for all activity that occurs under your account. Notify us immediately if you suspect unauthorized access.\n\n3. Your Data\nYou own the data you enter into the app (clients, orders, payments). By using the app, you grant us permission to store and process this data solely to provide the app\'s services.\n\n4. Accuracy of Information\nIn Your Hand is a tool to help you track your business data. The accuracy of reports, totals, and summaries depends entirely on the data you enter. We are not responsible for financial decisions made based on information in the app.\n\n5. WhatsApp Integration\nThe WhatsApp reminder feature opens WhatsApp with a pre-filled message. Sending the message is your action. We are not responsible for the content of messages you send or any consequences thereof.\n\n6. Voice and AI Features\nThe voice order feature uses speech recognition and AI to suggest order details. You are responsible for reviewing and confirming the suggested data before saving. We are not responsible for errors in AI-generated suggestions.\n\n7. Service Availability\nWe aim to keep the app available at all times but do not guarantee uninterrupted service. We may update, modify, or discontinue features at any time.\n\n8. Limitation of Liability\nIn Your Hand is provided as-is. We are not liable for any loss of data, financial loss, or other damages arising from the use or inability to use the app.\n\n9. Changes to Terms\nWe may update these terms from time to time. Continued use of the app after changes constitutes acceptance of the new terms.\n\n10. Contact\nFor questions about these terms, please contact us through the app\'s feedback form.';

  @override
  String get confirmOrder => 'Confirm order';

  @override
  String get confirmOrderMessage => 'Review the order below. Add it?';

  @override
  String get confirm => 'Confirm';

  @override
  String get connectionError => 'You are not connected (offline)';

  @override
  String unpaidOrderMessage(
    Object orderDate,
    Object totalAmount,
    Object totalUnpaid,
  ) {
    return 'Hello, you have $totalUnpaid remaining out of $totalAmount for the order dated $orderDate';
  }

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountWarningTitle => 'Delete account?';

  @override
  String get deleteAccountWarningMessage =>
      'This will permanently delete your account and all your data (profile, clients and orders). You will not be able to recover it. This action cannot be undone.';

  @override
  String get deleteAccountConfirm => 'Delete my account';

  @override
  String get deleteAccountSuccess => 'Account deleted successfully';

  @override
  String get deleteAccountRequireRecentLogin =>
      'For security, please sign out and sign in again, then try deleting your account.';

  @override
  String get deleteAccountEnterPassword =>
      'Enter your current password to confirm deletion.';

  @override
  String get deleteAccountPasswordRequired => 'Please enter your password.';

  @override
  String get adCouldNotLoad => 'Ad could not load. Try again in a moment.';
}
