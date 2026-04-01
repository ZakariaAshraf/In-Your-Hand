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
    Locale('en'),
  ];

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Your financial management is now in your hands'**
  String get welcomeMessage;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @pleaseWriteEmail.
  ///
  /// In en, this message translates to:
  /// **'Please write your Email Address'**
  String get pleaseWriteEmail;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgetPassword.
  ///
  /// In en, this message translates to:
  /// **'Forget Password ?'**
  String get forgetPassword;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account'**
  String get dontHaveAccount;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create!'**
  String get create;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account'**
  String get alreadyHaveAccount;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your email or password'**
  String get loginFailed;

  /// No description provided for @registerFailed.
  ///
  /// In en, this message translates to:
  /// **'Register failed. Please check all fields'**
  String get registerFailed;

  /// No description provided for @continuee.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continuee;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @recommendFeature.
  ///
  /// In en, this message translates to:
  /// **'Recommend a Feature'**
  String get recommendFeature;

  /// Error message with error details
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error(Object error);

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @letsStart.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Start ->'**
  String get letsStart;

  /// No description provided for @chooseYourCharacter.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Character'**
  String get chooseYourCharacter;

  /// No description provided for @chooseCharacterDescription.
  ///
  /// In en, this message translates to:
  /// **'Select the profile that best describes you to personalize your journey.'**
  String get chooseCharacterDescription;

  /// No description provided for @businessMan.
  ///
  /// In en, this message translates to:
  /// **'Business Man'**
  String get businessMan;

  /// No description provided for @businessWoman.
  ///
  /// In en, this message translates to:
  /// **'Business Woman'**
  String get businessWoman;

  /// No description provided for @inYourHand.
  ///
  /// In en, this message translates to:
  /// **'In Your Hand.'**
  String get inYourHand;

  /// No description provided for @allInYourHand.
  ///
  /// In en, this message translates to:
  /// **'All in your hand'**
  String get allInYourHand;

  /// No description provided for @signInMessage.
  ///
  /// In en, this message translates to:
  /// **'Sign in to show what you miss with your business'**
  String get signInMessage;

  /// No description provided for @registerMessage.
  ///
  /// In en, this message translates to:
  /// **'Register now and track your business'**
  String get registerMessage;

  /// No description provided for @pleaseSelectCharacter.
  ///
  /// In en, this message translates to:
  /// **'Please select a character first'**
  String get pleaseSelectCharacter;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as a Guest'**
  String get continueAsGuest;

  /// No description provided for @joinApplication.
  ///
  /// In en, this message translates to:
  /// **'Join Application'**
  String get joinApplication;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email (e.g. name@gmail.com or name@hotmail.com)'**
  String get invalidEmail;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'Password must have:'**
  String get passwordRequirements;

  /// No description provided for @passwordRequirementLength.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get passwordRequirementLength;

  /// No description provided for @passwordRequirementUppercase.
  ///
  /// In en, this message translates to:
  /// **'One uppercase letter (A-Z)'**
  String get passwordRequirementUppercase;

  /// No description provided for @passwordRequirementLowercase.
  ///
  /// In en, this message translates to:
  /// **'One lowercase letter (a-z)'**
  String get passwordRequirementLowercase;

  /// No description provided for @passwordRequirementDigit.
  ///
  /// In en, this message translates to:
  /// **'One number (0-9)'**
  String get passwordRequirementDigit;

  /// No description provided for @passwordTooWeak.
  ///
  /// In en, this message translates to:
  /// **'Please make the password stronger (see requirements below)'**
  String get passwordTooWeak;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get pleaseFillAllFields;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get orContinueWith;

  /// No description provided for @selectAvatar.
  ///
  /// In en, this message translates to:
  /// **'Select Avatar'**
  String get selectAvatar;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get preferences;

  /// No description provided for @supportAndAccount.
  ///
  /// In en, this message translates to:
  /// **'SUPPORT & ACCOUNT'**
  String get supportAndAccount;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @helpAddClient.
  ///
  /// In en, this message translates to:
  /// **'Add a client from the Clients tab or the + button on Home'**
  String get helpAddClient;

  /// No description provided for @helpAddOrder.
  ///
  /// In en, this message translates to:
  /// **'Add an order manually or by voice from the Orders tab'**
  String get helpAddOrder;

  /// No description provided for @helpAddPayment.
  ///
  /// In en, this message translates to:
  /// **'Open any order to record a partial or full payment'**
  String get helpAddPayment;

  /// No description provided for @helpGeneratePdf.
  ///
  /// In en, this message translates to:
  /// **'Open a client or order to generate and share a PDF report'**
  String get helpGeneratePdf;

  /// No description provided for @helpVoiceOrder.
  ///
  /// In en, this message translates to:
  /// **'Tap the mic on Add Order and speak in Arabic or English'**
  String get helpVoiceOrder;

  /// No description provided for @helpContactMessage.
  ///
  /// In en, this message translates to:
  /// **'Have a question or found a bug? We would love to hear from you.'**
  String get helpContactMessage;

  /// No description provided for @helpSendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get helpSendFeedback;

  /// No description provided for @cairoEgypt.
  ///
  /// In en, this message translates to:
  /// **'Cairo, Egypt'**
  String get cairoEgypt;

  /// No description provided for @egypt.
  ///
  /// In en, this message translates to:
  /// **'Egypt'**
  String get egypt;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profile;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'NOT AVAILABLE'**
  String get notAvailable;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get addNote;

  /// No description provided for @egp.
  ///
  /// In en, this message translates to:
  /// **'EGP'**
  String get egp;

  /// No description provided for @clientReport.
  ///
  /// In en, this message translates to:
  /// **'Client Report'**
  String get clientReport;

  /// No description provided for @addYourNote.
  ///
  /// In en, this message translates to:
  /// **'Add your note'**
  String get addYourNote;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @clients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get clients;

  /// No description provided for @totalOrders.
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get totalOrders;

  /// No description provided for @unpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get unpaid;

  /// No description provided for @addOrder.
  ///
  /// In en, this message translates to:
  /// **'+ Add Order'**
  String get addOrder;

  /// No description provided for @addOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Order'**
  String get addOrderTitle;

  /// No description provided for @addClient.
  ///
  /// In en, this message translates to:
  /// **'+ Add Client'**
  String get addClient;

  /// No description provided for @addClientTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Client'**
  String get addClientTitle;

  /// No description provided for @noOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders'**
  String get noOrders;

  /// No description provided for @noOrdersForThisStatus.
  ///
  /// In en, this message translates to:
  /// **'No orders for this status'**
  String get noOrdersForThisStatus;

  /// No description provided for @youDontHaveAnyOrders.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any orders'**
  String get youDontHaveAnyOrders;

  /// No description provided for @client.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get client;

  /// No description provided for @selectClient.
  ///
  /// In en, this message translates to:
  /// **'Select a client'**
  String get selectClient;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @totalAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmountLabel;

  /// No description provided for @whatIsOrderFor.
  ///
  /// In en, this message translates to:
  /// **'What is the order for?'**
  String get whatIsOrderFor;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount (\$) *'**
  String get totalAmount;

  /// No description provided for @paidAmount.
  ///
  /// In en, this message translates to:
  /// **'Paid Amount (\$)'**
  String get paidAmount;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @saveOrder.
  ///
  /// In en, this message translates to:
  /// **'✓ Save Order'**
  String get saveOrder;

  /// No description provided for @paidAmountCannotExceedTotal.
  ///
  /// In en, this message translates to:
  /// **'Paid amount cannot exceed total amount'**
  String get paidAmountCannotExceedTotal;

  /// No description provided for @noClientsFound.
  ///
  /// In en, this message translates to:
  /// **'No clients found'**
  String get noClientsFound;

  /// No description provided for @searchClient.
  ///
  /// In en, this message translates to:
  /// **'Search client...'**
  String get searchClient;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @deletedClient.
  ///
  /// In en, this message translates to:
  /// **'Deleted Client'**
  String get deletedClient;

  /// No description provided for @unknownClient.
  ///
  /// In en, this message translates to:
  /// **'Unknown Client'**
  String get unknownClient;

  /// No description provided for @totalUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Total Unpaid'**
  String get totalUnpaid;

  /// No description provided for @addPayment.
  ///
  /// In en, this message translates to:
  /// **'Add Payment'**
  String get addPayment;

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

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @deleteOrder.
  ///
  /// In en, this message translates to:
  /// **'Delete Order'**
  String get deleteOrder;

  /// No description provided for @deleteOrderConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this order?'**
  String get deleteOrderConfirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @clientName.
  ///
  /// In en, this message translates to:
  /// **'Client Name'**
  String get clientName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @notesAboutClient.
  ///
  /// In en, this message translates to:
  /// **'Notes about this client'**
  String get notesAboutClient;

  /// No description provided for @saveClient.
  ///
  /// In en, this message translates to:
  /// **'✓ Save Client'**
  String get saveClient;

  /// No description provided for @printReport.
  ///
  /// In en, this message translates to:
  /// **'Print Report'**
  String get printReport;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'total: '**
  String get total;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'paid: '**
  String get paid;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @noClientsMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No clients match your search'**
  String get noClientsMatchSearch;

  /// No description provided for @emptyList.
  ///
  /// In en, this message translates to:
  /// **'Empty List'**
  String get emptyList;

  /// No description provided for @youDontHaveAnyClients.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any clients'**
  String get youDontHaveAnyClients;

  /// No description provided for @editClient.
  ///
  /// In en, this message translates to:
  /// **'Edit Client'**
  String get editClient;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @whatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsApp;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @deleteClient.
  ///
  /// In en, this message translates to:
  /// **'Delete Client'**
  String get deleteClient;

  /// No description provided for @deleteClientConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this client?'**
  String get deleteClientConfirm;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @orderFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get orderFilterAll;

  /// No description provided for @orderFilterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orderFilterPending;

  /// No description provided for @orderFilterPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get orderFilterPartial;

  /// No description provided for @orderFilterPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get orderFilterPaid;

  /// No description provided for @orderStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orderStatusPending;

  /// No description provided for @orderStatusPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get orderStatusPartial;

  /// No description provided for @orderStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get orderStatusPaid;

  /// No description provided for @errorLoadingClients.
  ///
  /// In en, this message translates to:
  /// **'Error loading clients'**
  String get errorLoadingClients;

  /// No description provided for @whatsappDefaultMessage.
  ///
  /// In en, this message translates to:
  /// **'Hello, from In Your Hand app'**
  String get whatsappDefaultMessage;

  /// No description provided for @checkAllData.
  ///
  /// In en, this message translates to:
  /// **'Check all data'**
  String get checkAllData;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @totalClientsWithDebt.
  ///
  /// In en, this message translates to:
  /// **'Total clients with debt'**
  String get totalClientsWithDebt;

  /// No description provided for @clientsWithDebtTitle.
  ///
  /// In en, this message translates to:
  /// **'Clients with debt'**
  String get clientsWithDebtTitle;

  /// No description provided for @checkThem.
  ///
  /// In en, this message translates to:
  /// **'Check them'**
  String get checkThem;

  /// No description provided for @totalPaid.
  ///
  /// In en, this message translates to:
  /// **'Total Paid'**
  String get totalPaid;

  /// No description provided for @sendReminder.
  ///
  /// In en, this message translates to:
  /// **'Send Reminder'**
  String get sendReminder;

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get paymentHistory;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @totalPaidMustNotExceedTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total paid must not exceed total amount'**
  String get totalPaidMustNotExceedTotalAmount;

  /// No description provided for @showReport.
  ///
  /// In en, this message translates to:
  /// **'Show Report'**
  String get showReport;

  /// No description provided for @pdfPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'PDF Preview'**
  String get pdfPreviewTitle;

  /// No description provided for @addOrderByVoice.
  ///
  /// In en, this message translates to:
  /// **'Add order by voice'**
  String get addOrderByVoice;

  /// No description provided for @tapToSpeak.
  ///
  /// In en, this message translates to:
  /// **'Tap the mic and speak your order'**
  String get tapToSpeak;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listening;

  /// No description provided for @voicePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone access is required for voice orders'**
  String get voicePermissionDenied;

  /// No description provided for @allowMicrophone.
  ///
  /// In en, this message translates to:
  /// **'Please allow microphone in app settings'**
  String get allowMicrophone;

  /// No description provided for @transcript.
  ///
  /// In en, this message translates to:
  /// **'What you said'**
  String get transcript;

  /// No description provided for @addOrderFromVoice.
  ///
  /// In en, this message translates to:
  /// **'Add this order'**
  String get addOrderFromVoice;

  /// No description provided for @orderAddedByVoice.
  ///
  /// In en, this message translates to:
  /// **'Order added from voice'**
  String get orderAddedByVoice;

  /// No description provided for @geminiQuotaExceeded.
  ///
  /// In en, this message translates to:
  /// **'Service is temporarily busy. Please try again in a few minutes.'**
  String get geminiQuotaExceeded;

  /// No description provided for @voiceLimitReachedTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly voice limit reached'**
  String get voiceLimitReachedTitle;

  /// No description provided for @voiceLimitReachedBody.
  ///
  /// In en, this message translates to:
  /// **'You have 1 free voice order per month. You\'ve already used yours for this month. Unlimited voice orders are coming soon for premium users.'**
  String get voiceLimitReachedBody;

  /// No description provided for @recommendFeatureHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us what you\'d like to see in the app...'**
  String get recommendFeatureHint;

  /// No description provided for @feedbackSent.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your feedback!'**
  String get feedbackSent;

  /// No description provided for @feedbackFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send. Please try again.'**
  String get feedbackFailed;

  /// No description provided for @howToUseTheApp.
  ///
  /// In en, this message translates to:
  /// **'How to use the app'**
  String get howToUseTheApp;

  /// No description provided for @geminiNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Add your Gemini API key in app_keys.dart to use voice orders'**
  String get geminiNotConfigured;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @addNumberWithoutFirst0.
  ///
  /// In en, this message translates to:
  /// **'Add Number Without First 0'**
  String get addNumberWithoutFirst0;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @aboutUsContent.
  ///
  /// In en, this message translates to:
  /// **'In Your Hand is a business management app built for small business owners in Egypt who sell on credit and need a simple way to track what clients owe them.\n\nInstead of writing debts in a notebook or trying to remember who paid and who didn\'t, In Your Hand keeps everything in one place — clients, orders, payments, and reports — accessible from your phone at any time.\n\nKey features:\n• Add and manage clients with their contact details\n• Create orders and track how much has been paid and how much is still owed\n• Record partial payments over time\n• Send WhatsApp payment reminders directly from the app\n• Add orders by voice using AI — speak in Arabic or English\n• Generate and print professional PDF reports per order or per client\n• Full Arabic and English support with RTL layout\n• Dark mode and light mode\n\nIn Your Hand was designed to be simple, fast, and focused. No unnecessary features — just the tools a business owner actually needs every day.\n\nThank you for using In Your Hand.'**
  String get aboutUsContent;

  /// No description provided for @privacyPolicyContent.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy — In Your Hand\n\nLast updated: 2026\n\n1. Information We Collect\nIn Your Hand collects only the information you provide directly:\n• Your name and email address when you register\n• Client names, phone numbers, and notes you add\n• Order details and payment records you create\n• Optional profile photo\n\nWe do not collect location data, device identifiers, or any information beyond what you enter into the app.\n\n2. How We Use Your Information\nYour data is used solely to provide the app\'s functionality:\n• Displaying your clients and orders\n• Calculating payment summaries and reports\n• Sending WhatsApp reminders (only when you tap the button)\n• Generating PDF reports\n\nWe do not sell, share, or rent your personal information to any third party.\n\n3. Data Storage\nAll data is stored securely in Google Firebase (Firestore and Firebase Auth). Firebase is a Google service that complies with international data protection standards. Your data is associated with your account and is not accessible to other users.\n\n4. Voice Feature\nIf you use the voice order feature, your spoken audio is processed by Google\'s speech recognition service and then analyzed by Google Gemini AI to extract order details. Audio is not stored by the app.\n\n5. Data Deletion\nYou can delete your account and all associated data directly from Settings → Edit Profile → Delete Account.\n\n6. Security\nWe take reasonable steps to protect your data. Access to your account is protected by Firebase Authentication. We recommend using a strong password.\n\n7. Changes to This Policy\nWe may update this policy from time to time. Continued use of the app after changes means you accept the updated policy.\n\n8. Contact\nFor any privacy-related questions, please contact us through the app\'s feedback form.'**
  String get privacyPolicyContent;

  /// No description provided for @termsAndConditionsContent.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions — In Your Hand\n\nLast updated: 2026\n\nBy using In Your Hand, you agree to the following terms. Please read them carefully.\n\n1. Use of the App\nIn Your Hand is provided for personal and small business use. You agree to use the app only for lawful purposes and in a way that does not infringe the rights of others.\n\n2. Your Account\nYou are responsible for maintaining the confidentiality of your account credentials. You are responsible for all activity that occurs under your account. Notify us immediately if you suspect unauthorized access.\n\n3. Your Data\nYou own the data you enter into the app (clients, orders, payments). By using the app, you grant us permission to store and process this data solely to provide the app\'s services.\n\n4. Accuracy of Information\nIn Your Hand is a tool to help you track your business data. The accuracy of reports, totals, and summaries depends entirely on the data you enter. We are not responsible for financial decisions made based on information in the app.\n\n5. WhatsApp Integration\nThe WhatsApp reminder feature opens WhatsApp with a pre-filled message. Sending the message is your action. We are not responsible for the content of messages you send or any consequences thereof.\n\n6. Voice and AI Features\nThe voice order feature uses speech recognition and AI to suggest order details. You are responsible for reviewing and confirming the suggested data before saving. We are not responsible for errors in AI-generated suggestions.\n\n7. Service Availability\nWe aim to keep the app available at all times but do not guarantee uninterrupted service. We may update, modify, or discontinue features at any time.\n\n8. Limitation of Liability\nIn Your Hand is provided as-is. We are not liable for any loss of data, financial loss, or other damages arising from the use or inability to use the app.\n\n9. Changes to Terms\nWe may update these terms from time to time. Continued use of the app after changes constitutes acceptance of the new terms.\n\n10. Contact\nFor questions about these terms, please contact us through the app\'s feedback form.'**
  String get termsAndConditionsContent;

  /// No description provided for @confirmOrder.
  ///
  /// In en, this message translates to:
  /// **'Confirm order'**
  String get confirmOrder;

  /// No description provided for @confirmOrderMessage.
  ///
  /// In en, this message translates to:
  /// **'Review the order below. Add it?'**
  String get confirmOrderMessage;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountWarningTitle;

  /// No description provided for @deleteAccountWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your account and all your data (profile, clients and orders). You will not be able to recover it. This action cannot be undone.'**
  String get deleteAccountWarningMessage;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteAccountSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get deleteAccountSuccess;

  /// No description provided for @deleteAccountRequireRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'For security, please sign out and sign in again, then try deleting your account.'**
  String get deleteAccountRequireRecentLogin;

  /// No description provided for @deleteAccountEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password to confirm deletion.'**
  String get deleteAccountEnterPassword;

  /// No description provided for @deleteAccountPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password.'**
  String get deleteAccountPasswordRequired;
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
    'that was used.',
  );
}
