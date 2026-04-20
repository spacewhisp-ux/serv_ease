import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

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
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Serv Ease'**
  String get appTitle;

  /// No description provided for @navFaqs.
  ///
  /// In en, this message translates to:
  /// **'FAQs'**
  String get navFaqs;

  /// No description provided for @navTickets.
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get navTickets;

  /// No description provided for @navAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get navAlerts;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @menuSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get menuSignOut;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose how the app language is selected.'**
  String get settingsLanguageDescription;

  /// No description provided for @settingsLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get settingsLanguageLabel;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get languageChinese;

  /// No description provided for @loginHeadline.
  ///
  /// In en, this message translates to:
  /// **'Customer care, simplified.'**
  String get loginHeadline;

  /// No description provided for @loginRegisterDescription.
  ///
  /// In en, this message translates to:
  /// **'Create your account to search answers, submit tickets, and track support updates.'**
  String get loginRegisterDescription;

  /// No description provided for @loginSignInDescription.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access FAQs, tickets, and notifications from your support workspace.'**
  String get loginSignInDescription;

  /// No description provided for @loginDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get loginDisplayName;

  /// No description provided for @loginAccount.
  ///
  /// In en, this message translates to:
  /// **'Email or phone'**
  String get loginAccount;

  /// No description provided for @loginAccountHint.
  ///
  /// In en, this message translates to:
  /// **'name@example.com or +8613812345678'**
  String get loginAccountHint;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get loginCreateAccount;

  /// No description provided for @loginSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginSignIn;

  /// No description provided for @loginAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get loginAlreadyHaveAccount;

  /// No description provided for @loginNeedAccount.
  ///
  /// In en, this message translates to:
  /// **'Need an account? Create one'**
  String get loginNeedAccount;

  /// No description provided for @loginValidationAccount.
  ///
  /// In en, this message translates to:
  /// **'Enter your email or phone number.'**
  String get loginValidationAccount;

  /// No description provided for @loginValidationPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get loginValidationPassword;

  /// No description provided for @loginValidationDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display name must be at least 2 characters.'**
  String get loginValidationDisplayName;

  /// No description provided for @loginValidationAccountFormat.
  ///
  /// In en, this message translates to:
  /// **'Use a valid email or phone number in international format.'**
  String get loginValidationAccountFormat;

  /// No description provided for @faqHeadline.
  ///
  /// In en, this message translates to:
  /// **'Find answers fast.'**
  String get faqHeadline;

  /// No description provided for @faqDescription.
  ///
  /// In en, this message translates to:
  /// **'Search common support topics before opening a ticket.'**
  String get faqDescription;

  /// No description provided for @faqSearch.
  ///
  /// In en, this message translates to:
  /// **'Search FAQs'**
  String get faqSearch;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @faqLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load FAQs'**
  String get faqLoadFailed;

  /// No description provided for @commonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please try again.'**
  String get commonTryAgain;

  /// No description provided for @faqEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No answers yet'**
  String get faqEmptyTitle;

  /// No description provided for @faqEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Try a different keyword or category.'**
  String get faqEmptyDescription;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faqTitle;

  /// No description provided for @faqDetailLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load FAQ'**
  String get faqDetailLoadFailed;

  /// No description provided for @faqNotFound.
  ///
  /// In en, this message translates to:
  /// **'FAQ not found'**
  String get faqNotFound;

  /// No description provided for @commonReturnToList.
  ///
  /// In en, this message translates to:
  /// **'Please return to the list and try again.'**
  String get commonReturnToList;

  /// No description provided for @ticketHeadline.
  ///
  /// In en, this message translates to:
  /// **'Track every support request.'**
  String get ticketHeadline;

  /// No description provided for @ticketDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a ticket, follow replies, and close the case when it is resolved.'**
  String get ticketDescription;

  /// No description provided for @ticketNew.
  ///
  /// In en, this message translates to:
  /// **'New ticket'**
  String get ticketNew;

  /// No description provided for @ticketLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load tickets'**
  String get ticketLoadFailed;

  /// No description provided for @ticketEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No tickets yet'**
  String get ticketEmptyTitle;

  /// No description provided for @ticketEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Create your first support ticket to get help.'**
  String get ticketEmptyDescription;

  /// No description provided for @ticketUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String ticketUpdatedAt(Object time);

  /// No description provided for @ticketCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create ticket'**
  String get ticketCreateTitle;

  /// No description provided for @ticketCreateHeadline.
  ///
  /// In en, this message translates to:
  /// **'Describe the issue clearly.'**
  String get ticketCreateHeadline;

  /// No description provided for @ticketSubject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get ticketSubject;

  /// No description provided for @ticketCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get ticketCategory;

  /// No description provided for @ticketPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get ticketPriority;

  /// No description provided for @ticketDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get ticketDescriptionLabel;

  /// No description provided for @ticketSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit ticket'**
  String get ticketSubmit;

  /// No description provided for @ticketDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Ticket details'**
  String get ticketDetailTitle;

  /// No description provided for @ticketDetailLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load ticket'**
  String get ticketDetailLoadFailed;

  /// No description provided for @ticketNotFound.
  ///
  /// In en, this message translates to:
  /// **'Ticket not found'**
  String get ticketNotFound;

  /// No description provided for @ticketNotFoundDescription.
  ///
  /// In en, this message translates to:
  /// **'Please return to the ticket list and try again.'**
  String get ticketNotFoundDescription;

  /// No description provided for @ticketOpenedAt.
  ///
  /// In en, this message translates to:
  /// **'Opened {time}'**
  String ticketOpenedAt(Object time);

  /// No description provided for @ticketClose.
  ///
  /// In en, this message translates to:
  /// **'Close ticket'**
  String get ticketClose;

  /// No description provided for @ticketConversation.
  ///
  /// In en, this message translates to:
  /// **'Conversation'**
  String get ticketConversation;

  /// No description provided for @ticketAttachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get ticketAttachments;

  /// No description provided for @ticketSendReply.
  ///
  /// In en, this message translates to:
  /// **'Send a reply'**
  String get ticketSendReply;

  /// No description provided for @ticketClosedState.
  ///
  /// In en, this message translates to:
  /// **'This ticket is closed'**
  String get ticketClosedState;

  /// No description provided for @ticketReplyHint.
  ///
  /// In en, this message translates to:
  /// **'Add more details'**
  String get ticketReplyHint;

  /// No description provided for @ticketReplyAction.
  ///
  /// In en, this message translates to:
  /// **'Send reply'**
  String get ticketReplyAction;

  /// No description provided for @ticketMessageYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get ticketMessageYou;

  /// No description provided for @notificationsHeadline.
  ///
  /// In en, this message translates to:
  /// **'Stay in the loop.'**
  String get notificationsHeadline;

  /// No description provided for @notificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Review support updates and mark messages as read.'**
  String get notificationsDescription;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load notifications'**
  String get notificationsLoadFailed;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Ticket updates will appear here.'**
  String get notificationsEmptyDescription;

  /// No description provided for @notificationsUnreadCount.
  ///
  /// In en, this message translates to:
  /// **'{count} unread'**
  String notificationsUnreadCount(int count);

  /// No description provided for @ticketStatusAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get ticketStatusAll;

  /// No description provided for @ticketStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get ticketStatusOpen;

  /// No description provided for @ticketStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get ticketStatusPending;

  /// No description provided for @ticketStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get ticketStatusInProgress;

  /// No description provided for @ticketStatusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get ticketStatusResolved;

  /// No description provided for @ticketStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get ticketStatusClosed;

  /// No description provided for @ticketPriorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get ticketPriorityLow;

  /// No description provided for @ticketPriorityNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get ticketPriorityNormal;

  /// No description provided for @ticketPriorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get ticketPriorityHigh;

  /// No description provided for @ticketPriorityUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get ticketPriorityUrgent;

  /// No description provided for @ticketCategoryAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get ticketCategoryAccount;

  /// No description provided for @ticketCategoryBilling.
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get ticketCategoryBilling;

  /// No description provided for @ticketCategoryBugReport.
  ///
  /// In en, this message translates to:
  /// **'Bug report'**
  String get ticketCategoryBugReport;

  /// No description provided for @ticketCategoryOrderIssue.
  ///
  /// In en, this message translates to:
  /// **'Order issue'**
  String get ticketCategoryOrderIssue;

  /// No description provided for @ticketCategoryGeneralSupport.
  ///
  /// In en, this message translates to:
  /// **'General support'**
  String get ticketCategoryGeneralSupport;

  /// No description provided for @messageSenderSupportAgent.
  ///
  /// In en, this message translates to:
  /// **'Support agent'**
  String get messageSenderSupportAgent;

  /// No description provided for @messageSenderSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get messageSenderSystem;

  /// No description provided for @messageSenderUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get messageSenderUser;

  /// No description provided for @notificationTypeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get notificationTypeSystem;

  /// No description provided for @notificationTypeTicketReply.
  ///
  /// In en, this message translates to:
  /// **'Ticket reply'**
  String get notificationTypeTicketReply;

  /// No description provided for @notificationTypeTicketStatus.
  ///
  /// In en, this message translates to:
  /// **'Ticket status'**
  String get notificationTypeTicketStatus;

  /// No description provided for @notificationTypeAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Announcement'**
  String get notificationTypeAnnouncement;
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
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
