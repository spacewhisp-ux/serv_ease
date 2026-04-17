import '../../../core/network/api_client.dart';

class TicketRepository {
  TicketRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<TicketListResult> fetchTickets({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get(
      '/tickets',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        'page': page,
        'pageSize': pageSize,
      },
    );
    final items = response['items'] as List<dynamic>? ?? [];
    final pagination = response['pagination'] as Map<String, dynamic>? ?? {};
    return TicketListResult(
      items: items
          .map((item) => TicketSummary.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: pagination['total'] as int? ?? items.length,
      page: pagination['page'] as int? ?? page,
      totalPages: pagination['totalPages'] as int? ?? 1,
    );
  }

  Future<TicketDetail> fetchTicketDetail(String id) async {
    final response = await _apiClient.get('/tickets/$id');
    return TicketDetail.fromJson(response);
  }

  Future<TicketSummary> createTicket({
    required String subject,
    required String description,
    required String category,
    String priority = 'NORMAL',
  }) async {
    final response = await _apiClient.post(
      '/tickets',
      data: {
        'subject': subject,
        'description': description,
        'category': category,
        'priority': priority,
      },
    );
    return TicketSummary.fromCreateJson(response);
  }

  Future<TicketReplyResult> replyTicket({
    required String ticketId,
    required String body,
  }) async {
    final response = await _apiClient.post(
      '/tickets/$ticketId/messages',
      data: {'body': body},
    );
    return TicketReplyResult.fromJson(response);
  }

  Future<TicketCloseResult> closeTicket({
    required String ticketId,
    String? reason,
  }) async {
    final response = await _apiClient.patch(
      '/tickets/$ticketId/close',
      data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
    );
    return TicketCloseResult.fromJson(response);
  }
}

class TicketSummary {
  const TicketSummary({
    required this.id,
    required this.ticketNo,
    required this.subject,
    required this.status,
    required this.priority,
    required this.updatedAt,
    required this.lastMessageAt,
    this.createdAt,
  });

  factory TicketSummary.fromJson(Map<String, dynamic> json) {
    return TicketSummary(
      id: json['id'] as String,
      ticketNo: json['ticketNo'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      status: json['status'] as String? ?? 'OPEN',
      priority: json['priority'] as String? ?? 'NORMAL',
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      lastMessageAt:
          DateTime.tryParse(json['lastMessageAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'] as String),
    );
  }

  factory TicketSummary.fromCreateJson(Map<String, dynamic> json) {
    final createdAt =
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now();
    return TicketSummary(
      id: json['id'] as String,
      ticketNo: json['ticketNo'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      status: json['status'] as String? ?? 'OPEN',
      priority: 'NORMAL',
      updatedAt: createdAt,
      lastMessageAt: createdAt,
      createdAt: createdAt,
    );
  }

  final String id;
  final String ticketNo;
  final String subject;
  final String status;
  final String priority;
  final DateTime updatedAt;
  final DateTime lastMessageAt;
  final DateTime? createdAt;
}

class TicketDetail {
  const TicketDetail({
    required this.id,
    required this.ticketNo,
    required this.subject,
    required this.description,
    required this.status,
    required this.priority,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
    required this.attachments,
  });

  factory TicketDetail.fromJson(Map<String, dynamic> json) {
    return TicketDetail(
      id: json['id'] as String,
      ticketNo: json['ticketNo'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'OPEN',
      priority: json['priority'] as String? ?? 'NORMAL',
      category: json['category'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      messages: ((json['messages'] as List<dynamic>?) ?? const [])
          .map((item) => TicketMessage.fromJson(item as Map<String, dynamic>))
          .toList(),
      attachments: ((json['attachments'] as List<dynamic>?) ?? const [])
          .map(
            (item) => TicketAttachment.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final String id;
  final String ticketNo;
  final String subject;
  final String description;
  final String status;
  final String priority;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TicketMessage> messages;
  final List<TicketAttachment> attachments;
}

class TicketMessage {
  const TicketMessage({
    required this.id,
    required this.senderRole,
    required this.type,
    required this.body,
    required this.createdAt,
  });

  factory TicketMessage.fromJson(Map<String, dynamic> json) {
    return TicketMessage(
      id: json['id'] as String,
      senderRole: json['senderRole'] as String? ?? 'USER',
      type: json['type'] as String? ?? 'TEXT',
      body: json['body'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final String id;
  final String senderRole;
  final String type;
  final String body;
  final DateTime createdAt;
}

class TicketAttachment {
  const TicketAttachment({
    required this.id,
    required this.fileName,
    required this.mimeType,
    required this.fileSize,
    required this.createdAt,
  });

  factory TicketAttachment.fromJson(Map<String, dynamic> json) {
    return TicketAttachment(
      id: json['id'] as String,
      fileName: json['fileName'] as String? ?? '',
      mimeType: json['mimeType'] as String? ?? '',
      fileSize: json['fileSize'] as int? ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final String id;
  final String fileName;
  final String mimeType;
  final int fileSize;
  final DateTime createdAt;
}

class TicketListResult {
  const TicketListResult({
    required this.items,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  final List<TicketSummary> items;
  final int total;
  final int page;
  final int totalPages;
}

class TicketReplyResult {
  const TicketReplyResult({
    required this.messageId,
    required this.ticketId,
    required this.body,
    required this.createdAt,
  });

  factory TicketReplyResult.fromJson(Map<String, dynamic> json) {
    return TicketReplyResult(
      messageId: json['messageId'] as String,
      ticketId: json['ticketId'] as String,
      body: json['body'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final String messageId;
  final String ticketId;
  final String body;
  final DateTime createdAt;
}

class TicketCloseResult {
  const TicketCloseResult({
    required this.id,
    required this.status,
    this.reason,
    this.closedAt,
  });

  factory TicketCloseResult.fromJson(Map<String, dynamic> json) {
    return TicketCloseResult(
      id: json['id'] as String,
      status: json['status'] as String? ?? 'CLOSED',
      reason: json['reason'] as String?,
      closedAt: json['closedAt'] == null
          ? null
          : DateTime.tryParse(json['closedAt'] as String),
    );
  }

  final String id;
  final String status;
  final String? reason;
  final DateTime? closedAt;
}
