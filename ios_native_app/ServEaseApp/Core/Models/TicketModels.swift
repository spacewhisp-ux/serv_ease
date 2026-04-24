import Foundation

struct TicketSummary: Codable, Identifiable {
    let id: String
    let ticketNo: String
    let subject: String
    let status: String
    let priority: String
    let updatedAt: String?
    let lastMessageAt: String?
    let createdAt: String?
}

struct TicketDetail: Codable, Identifiable {
    let id: String
    let ticketNo: String?
    let subject: String
    let description: String
    let status: String
    let priority: String
    let category: String
    let createdAt: String?
    let updatedAt: String?
    let resolvedAt: String?
    let closedAt: String?
    let lastMessageAt: String?
    let messages: [TicketMessage]?
    let attachments: [TicketAttachment]?
}

struct TicketMessage: Codable, Identifiable {
    let id: String
    let senderRole: String
    let type: String
    let body: String
    let isInternal: Bool?
    let createdAt: String
    let attachments: [TicketAttachment]?
}

struct TicketAttachment: Codable, Identifiable {
    let id: String
    let fileName: String
    let mimeType: String
    let fileSize: Int
    let createdAt: String?
    let messageId: String?
}

struct CreateTicketRequest: Codable {
    let subject: String
    let description: String
    let category: String
    let priority: String
    let attachmentIds: [String]?

    init(subject: String, description: String, category: String, priority: String = "NORMAL") {
        self.subject = subject
        self.description = description
        self.category = category
        self.priority = priority
        self.attachmentIds = nil
    }
}

struct ReplyRequest: Codable {
    let body: String
    let attachmentIds: [String]?

    init(body: String) {
        self.body = body
        self.attachmentIds = nil
    }
}

struct CloseTicketRequest: Codable {
    let reason: String?
}

struct TicketReplyResult: Codable {
    let messageId: String
    let ticketId: String?
    let body: String?
    let createdAt: String?
}

struct TicketCloseResult: Codable {
    let id: String
    let status: String
    let reason: String?
    let closedAt: String?
}

struct TicketListResponse: Codable {
    let items: [TicketSummary]?
    let pagination: Pagination?
}

struct CreateTicketResponse: Codable {
    let id: String
    let ticketNo: String?
    let status: String?
    let subject: String?
    let createdAt: String?
}
