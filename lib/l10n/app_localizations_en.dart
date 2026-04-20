// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Serv Ease';

  @override
  String get navFaqs => 'FAQs';

  @override
  String get navTickets => 'Tickets';

  @override
  String get navAlerts => 'Alerts';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuSignOut => 'Sign out';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsLanguageDescription =>
      'Choose how the app language is selected.';

  @override
  String get settingsLanguageLabel => 'App language';

  @override
  String get languageSystem => 'Follow system';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => 'Chinese';

  @override
  String get loginHeadline => 'Customer care, simplified.';

  @override
  String get loginRegisterDescription =>
      'Create your account to search answers, submit tickets, and track support updates.';

  @override
  String get loginSignInDescription =>
      'Sign in to access FAQs, tickets, and notifications from your support workspace.';

  @override
  String get loginDisplayName => 'Display name';

  @override
  String get loginAccount => 'Email or phone';

  @override
  String get loginAccountHint => 'name@example.com or +8613812345678';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginCreateAccount => 'Create account';

  @override
  String get loginSignIn => 'Sign in';

  @override
  String get loginAlreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get loginNeedAccount => 'Need an account? Create one';

  @override
  String get loginValidationAccount => 'Enter your email or phone number.';

  @override
  String get loginValidationPassword =>
      'Password must be at least 8 characters.';

  @override
  String get loginValidationDisplayName =>
      'Display name must be at least 2 characters.';

  @override
  String get loginValidationAccountFormat =>
      'Use a valid email or phone number in international format.';

  @override
  String get faqHeadline => 'Find answers fast.';

  @override
  String get faqDescription =>
      'Search common support topics before opening a ticket.';

  @override
  String get faqSearch => 'Search FAQs';

  @override
  String get filterAll => 'All';

  @override
  String get faqLoadFailed => 'Could not load FAQs';

  @override
  String get commonTryAgain => 'Please try again.';

  @override
  String get faqEmptyTitle => 'No answers yet';

  @override
  String get faqEmptyDescription => 'Try a different keyword or category.';

  @override
  String get faqTitle => 'FAQ';

  @override
  String get faqDetailLoadFailed => 'Could not load FAQ';

  @override
  String get faqNotFound => 'FAQ not found';

  @override
  String get commonReturnToList => 'Please return to the list and try again.';

  @override
  String get ticketHeadline => 'Track every support request.';

  @override
  String get ticketDescription =>
      'Create a ticket, follow replies, and close the case when it is resolved.';

  @override
  String get ticketNew => 'New ticket';

  @override
  String get ticketLoadFailed => 'Could not load tickets';

  @override
  String get ticketEmptyTitle => 'No tickets yet';

  @override
  String get ticketEmptyDescription =>
      'Create your first support ticket to get help.';

  @override
  String ticketUpdatedAt(Object time) {
    return 'Updated $time';
  }

  @override
  String get ticketCreateTitle => 'Create ticket';

  @override
  String get ticketCreateHeadline => 'Describe the issue clearly.';

  @override
  String get ticketSubject => 'Subject';

  @override
  String get ticketCategory => 'Category';

  @override
  String get ticketPriority => 'Priority';

  @override
  String get ticketDescriptionLabel => 'What happened?';

  @override
  String get ticketSubmit => 'Submit ticket';

  @override
  String get ticketDetailTitle => 'Ticket details';

  @override
  String get ticketDetailLoadFailed => 'Could not load ticket';

  @override
  String get ticketNotFound => 'Ticket not found';

  @override
  String get ticketNotFoundDescription =>
      'Please return to the ticket list and try again.';

  @override
  String ticketOpenedAt(Object time) {
    return 'Opened $time';
  }

  @override
  String get ticketClose => 'Close ticket';

  @override
  String get ticketConversation => 'Conversation';

  @override
  String get ticketAttachments => 'Attachments';

  @override
  String get ticketSendReply => 'Send a reply';

  @override
  String get ticketClosedState => 'This ticket is closed';

  @override
  String get ticketReplyHint => 'Add more details';

  @override
  String get ticketReplyAction => 'Send reply';

  @override
  String get ticketMessageYou => 'You';

  @override
  String get notificationsHeadline => 'Stay in the loop.';

  @override
  String get notificationsDescription =>
      'Review support updates and mark messages as read.';

  @override
  String get notificationsMarkAllRead => 'Mark all as read';

  @override
  String get notificationsLoadFailed => 'Could not load notifications';

  @override
  String get notificationsEmptyTitle => 'No notifications';

  @override
  String get notificationsEmptyDescription =>
      'Ticket updates will appear here.';

  @override
  String notificationsUnreadCount(int count) {
    return '$count unread';
  }

  @override
  String get ticketStatusAll => 'All';

  @override
  String get ticketStatusOpen => 'Open';

  @override
  String get ticketStatusPending => 'Pending';

  @override
  String get ticketStatusInProgress => 'In progress';

  @override
  String get ticketStatusResolved => 'Resolved';

  @override
  String get ticketStatusClosed => 'Closed';

  @override
  String get ticketPriorityLow => 'Low';

  @override
  String get ticketPriorityNormal => 'Normal';

  @override
  String get ticketPriorityHigh => 'High';

  @override
  String get ticketPriorityUrgent => 'Urgent';

  @override
  String get ticketCategoryAccount => 'Account';

  @override
  String get ticketCategoryBilling => 'Billing';

  @override
  String get ticketCategoryBugReport => 'Bug report';

  @override
  String get ticketCategoryOrderIssue => 'Order issue';

  @override
  String get ticketCategoryGeneralSupport => 'General support';

  @override
  String get messageSenderSupportAgent => 'Support agent';

  @override
  String get messageSenderSystem => 'System';

  @override
  String get messageSenderUser => 'User';

  @override
  String get notificationTypeSystem => 'System';

  @override
  String get notificationTypeTicketReply => 'Ticket reply';

  @override
  String get notificationTypeTicketStatus => 'Ticket status';

  @override
  String get notificationTypeAnnouncement => 'Announcement';
}
