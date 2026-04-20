// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Serv Ease';

  @override
  String get navFaqs => '常见问题';

  @override
  String get navTickets => '工单';

  @override
  String get navAlerts => '提醒';

  @override
  String get menuSettings => '设置';

  @override
  String get menuSignOut => '退出登录';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsLanguageTitle => '语言';

  @override
  String get settingsLanguageDescription => '选择应用显示语言。';

  @override
  String get settingsLanguageLabel => '应用语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '中文';

  @override
  String get loginHeadline => '客户服务，更简单。';

  @override
  String get loginRegisterDescription => '创建账号后即可搜索答案、提交工单并跟踪支持进度。';

  @override
  String get loginSignInDescription => '登录后访问支持工作区中的常见问题、工单和通知。';

  @override
  String get loginDisplayName => '显示名称';

  @override
  String get loginAccount => '邮箱或手机号';

  @override
  String get loginAccountHint => 'name@example.com 或 +8613812345678';

  @override
  String get loginPassword => '密码';

  @override
  String get loginCreateAccount => '创建账号';

  @override
  String get loginSignIn => '登录';

  @override
  String get loginAlreadyHaveAccount => '已有账号？登录';

  @override
  String get loginNeedAccount => '需要账号？立即创建';

  @override
  String get loginValidationAccount => '请输入邮箱或手机号。';

  @override
  String get loginValidationPassword => '密码至少需要 8 个字符。';

  @override
  String get loginValidationDisplayName => '显示名称至少需要 2 个字符。';

  @override
  String get loginValidationAccountFormat => '请输入有效的邮箱或国际格式手机号。';

  @override
  String get faqHeadline => '快速找到答案。';

  @override
  String get faqDescription => '提交工单前，先搜索常见支持问题。';

  @override
  String get faqSearch => '搜索常见问题';

  @override
  String get filterAll => '全部';

  @override
  String get faqLoadFailed => '无法加载常见问题';

  @override
  String get commonTryAgain => '请重试。';

  @override
  String get faqEmptyTitle => '暂无答案';

  @override
  String get faqEmptyDescription => '请尝试其他关键词或分类。';

  @override
  String get faqTitle => '常见问题';

  @override
  String get faqDetailLoadFailed => '无法加载常见问题';

  @override
  String get faqNotFound => '未找到常见问题';

  @override
  String get commonReturnToList => '请返回列表后重试。';

  @override
  String get ticketHeadline => '跟踪每一个支持请求。';

  @override
  String get ticketDescription => '创建工单、查看回复，并在问题解决后关闭工单。';

  @override
  String get ticketNew => '新建工单';

  @override
  String get ticketLoadFailed => '无法加载工单';

  @override
  String get ticketEmptyTitle => '暂无工单';

  @override
  String get ticketEmptyDescription => '创建第一个支持工单来获取帮助。';

  @override
  String ticketUpdatedAt(Object time) {
    return '更新于 $time';
  }

  @override
  String get ticketCreateTitle => '创建工单';

  @override
  String get ticketCreateHeadline => '请清楚描述问题。';

  @override
  String get ticketSubject => '主题';

  @override
  String get ticketCategory => '分类';

  @override
  String get ticketPriority => '优先级';

  @override
  String get ticketDescriptionLabel => '发生了什么？';

  @override
  String get ticketSubmit => '提交工单';

  @override
  String get ticketDetailTitle => '工单详情';

  @override
  String get ticketDetailLoadFailed => '无法加载工单';

  @override
  String get ticketNotFound => '未找到工单';

  @override
  String get ticketNotFoundDescription => '请返回工单列表后重试。';

  @override
  String ticketOpenedAt(Object time) {
    return '创建于 $time';
  }

  @override
  String get ticketClose => '关闭工单';

  @override
  String get ticketConversation => '对话';

  @override
  String get ticketAttachments => '附件';

  @override
  String get ticketSendReply => '发送回复';

  @override
  String get ticketClosedState => '此工单已关闭';

  @override
  String get ticketReplyHint => '补充更多细节';

  @override
  String get ticketReplyAction => '发送回复';

  @override
  String get ticketMessageYou => '你';

  @override
  String get notificationsHeadline => '不错过任何更新。';

  @override
  String get notificationsDescription => '查看支持更新，并将消息标记为已读。';

  @override
  String get notificationsMarkAllRead => '全部标为已读';

  @override
  String get notificationsLoadFailed => '无法加载通知';

  @override
  String get notificationsEmptyTitle => '暂无通知';

  @override
  String get notificationsEmptyDescription => '工单更新会显示在这里。';

  @override
  String notificationsUnreadCount(int count) {
    return '$count 条未读';
  }

  @override
  String get ticketStatusAll => '全部';

  @override
  String get ticketStatusOpen => '待处理';

  @override
  String get ticketStatusPending => '等待中';

  @override
  String get ticketStatusInProgress => '处理中';

  @override
  String get ticketStatusResolved => '已解决';

  @override
  String get ticketStatusClosed => '已关闭';

  @override
  String get ticketPriorityLow => '低';

  @override
  String get ticketPriorityNormal => '普通';

  @override
  String get ticketPriorityHigh => '高';

  @override
  String get ticketPriorityUrgent => '紧急';

  @override
  String get ticketCategoryAccount => '账号';

  @override
  String get ticketCategoryBilling => '账单';

  @override
  String get ticketCategoryBugReport => '问题反馈';

  @override
  String get ticketCategoryOrderIssue => '订单问题';

  @override
  String get ticketCategoryGeneralSupport => '通用支持';

  @override
  String get messageSenderSupportAgent => '客服专员';

  @override
  String get messageSenderSystem => '系统';

  @override
  String get messageSenderUser => '用户';

  @override
  String get notificationTypeSystem => '系统';

  @override
  String get notificationTypeTicketReply => '工单回复';

  @override
  String get notificationTypeTicketStatus => '工单状态';

  @override
  String get notificationTypeAnnouncement => '公告';
}
