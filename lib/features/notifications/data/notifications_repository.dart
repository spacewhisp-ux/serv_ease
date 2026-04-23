import '../../../core/network/api_client.dart';

class NotificationsRepository {
  NotificationsRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<NotificationsResult> fetchNotifications({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get(
      '/notifications',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    final items = response['items'] as List<dynamic>? ?? [];
    final pagination = response['pagination'] as Map<String, dynamic>? ?? {};
    return NotificationsResult(
      items: items
          .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: pagination['total'] as int? ?? items.length,
    );
  }

  Future<int> fetchUnreadCount() async {
    final response = await _apiClient.get('/notifications/unread-count');
    return response['unreadCount'] as int? ?? 0;
  }

  Future<void> markAsRead(String id) async {
    await _apiClient.patch('/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _apiClient.patch('/notifications/read-all');
  }
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.readAt,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'SYSTEM',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      data: (json['data'] as Map<String, dynamic>?) ?? const {},
      readAt: json['readAt'] == null
          ? null
          : DateTime.tryParse(json['readAt'] as String),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime createdAt;

  String? get ticketId => data['ticketId'] as String?;
  bool get isRead => readAt != null;
}

class NotificationsResult {
  const NotificationsResult({required this.items, required this.total});

  final List<AppNotification> items;
  final int total;
}
