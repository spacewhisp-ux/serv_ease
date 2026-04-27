import Foundation

struct EmptyRequest: Encodable {}

struct HealthStatus: Codable, Equatable {
    let status: String
    let timestamp: String
    let service: String
}

struct User: Codable, Equatable, Identifiable {
    let id: String
    let email: String?
    let phone: String?
    let displayName: String
    let avatarURL: String?
    let role: String
    let status: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case phone
        case displayName
        case avatarURL = "avatarUrl"
        case role
        case status
        case createdAt
    }
}

struct AuthTokens: Codable, Equatable {
    let accessToken: String
    let refreshToken: String
}

struct AuthResponse: Codable, Equatable {
    let user: User
    let accessToken: String
    let refreshToken: String
}

struct LoginRequest: Encodable {
    let account: String
    let password: String
    let deviceId: String?
    let deviceName: String?
}

struct RegisterRequest: Encodable {
    let phone: String
    let password: String
    let displayName: String
    let deviceId: String?
    let deviceName: String?
}

struct RefreshTokenRequest: Encodable {
    let refreshToken: String
}

struct LogoutResponse: Decodable {
    let loggedOut: Bool
}

struct FaqCategory: Codable, Equatable, Identifiable {
    let id: String
    let name: String
    let sortOrder: Int
}

struct FaqSummary: Codable, Equatable, Identifiable {
    let id: String
    let categoryId: String
    let question: String
    let answerPreview: String
    let viewCount: Int
}

struct FaqListResponse: Codable, Equatable {
    let items: [FaqSummary]
    let pagination: Pagination
}

struct FaqDetail: Codable, Equatable, Identifiable {
    let id: String
    let categoryId: String
    let question: String
    let answer: String
    let keywords: [String]
    let viewCount: Int
}

struct Pagination: Codable, Equatable {
    let page: Int
    let pageSize: Int
    let total: Int
    let totalPages: Int
}

enum TicketStatus: String, Codable, CaseIterable, Identifiable {
    case open = "OPEN"
    case pending = "PENDING"
    case inProgress = "IN_PROGRESS"
    case resolved = "RESOLVED"
    case closed = "CLOSED"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .open: return "待处理"
        case .pending: return "等待中"
        case .inProgress: return "处理中"
        case .resolved: return "已解决"
        case .closed: return "已关闭"
        }
    }
}

struct TicketSummary: Codable, Equatable, Identifiable {
    let id: String
    let ticketNo: String
    let subject: String
    let status: TicketStatus
    let priority: String
    let updatedAt: String
    let lastMessageAt: String
}

struct TicketListResponse: Codable, Equatable {
    let items: [TicketSummary]
    let pagination: Pagination
}

struct TicketAttachment: Codable, Equatable, Identifiable {
    let id: String
    let fileName: String
    let mimeType: String?
    let fileSize: Int?
    let createdAt: String
    let messageId: String?
}

struct TicketMessage: Codable, Equatable, Identifiable {
    let id: String
    let senderRole: String
    let type: String
    let body: String
    let createdAt: String
    let attachments: [TicketAttachment]
}

struct TicketDetail: Codable, Equatable, Identifiable {
    let id: String
    let ticketNo: String
    let subject: String
    let description: String
    let status: TicketStatus
    let priority: String
    let category: String
    let createdAt: String
    let updatedAt: String
    let messages: [TicketMessage]
    let attachments: [TicketAttachment]
}

struct CreateTicketRequest: Encodable {
    let subject: String
    let description: String
    let category: String
    let priority: String?
    let attachmentIds: [String]?
}

struct CreateTicketResponse: Decodable, Equatable {
    let id: String
    let ticketNo: String
    let status: TicketStatus
    let subject: String
    let createdAt: String
}

struct ReplyTicketRequest: Encodable {
    let body: String
    let attachmentIds: [String]?
}

struct TicketReplyResponse: Decodable, Equatable {
    let messageId: String
    let ticketId: String
    let body: String
    let attachmentIds: [String]
    let createdAt: String
}

struct CloseTicketRequest: Encodable {
    let reason: String?
}

struct CloseTicketResponse: Decodable, Equatable {
    let id: String
    let status: TicketStatus
    let closedAt: String
    let reason: String?
}

struct AppNotification: Codable, Equatable, Identifiable {
    let id: String
    let type: String
    let title: String
    let body: String
    let data: [String: String]?
    let readAt: String?
    let createdAt: String
}

struct NotificationListResponse: Codable, Equatable {
    let items: [AppNotification]
    let pagination: Pagination
}

struct UnreadCountResponse: Codable, Equatable {
    let unreadCount: Int
}

struct MarkAllReadResponse: Codable, Equatable {
    let updatedCount: Int
}

struct DeleteAccountRequest: Encodable {
    let reason: String?
}

struct DeleteAccountResponse: Codable, Equatable {
    let requested: Bool
    let reason: String?
}

struct AccountCheckResult: Equatable {
    let summary: String
    let riskLevel: String
}

// MARK: - Chat

struct ChatQuestion: Codable, Equatable, Identifiable {
    let id: String
    let text: String
    let reply: String
    let linkUrl: String?
    let linkLabel: String?
    let sortOrder: Int
}

struct ChatSubmitRequest: Encodable {
    let text: String
}

struct ChatSubmitResponse: Codable, Equatable {
    let matched: Bool
    let reply: String
    let keyword: String?
    let suggestTicket: Bool
}

enum ChatSender: Equatable {
    case user
    case system
}

struct ChatMessage: Equatable, Identifiable {
    let id = UUID()
    let sender: ChatSender
    let body: String
    let timestamp: Date
    var isQuickReply = false
    var linkUrl: String?
    var linkLabel: String?
    var suggestTicket = false
}
