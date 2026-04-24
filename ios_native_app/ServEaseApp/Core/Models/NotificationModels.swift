import Foundation

struct AppNotification: Codable, Identifiable {
    let id: String
    let type: String
    let title: String
    let body: String
    let data: [String: String]?
    let readAt: String?
    let createdAt: String

    var isRead: Bool { readAt != nil }
    var ticketId: String? { data?["ticketId"] }
}

struct NotificationListResponse: Codable {
    let items: [AppNotification]?
    let pagination: Pagination?
}

struct UnreadCountResponse: Codable {
    let unreadCount: Int
}

struct MarkReadResponse: Codable {
    let id: String?
    let readAt: String?
}

struct MarkAllReadResponse: Codable {
    let updatedCount: Int?
}

struct PushDeviceRequest: Codable {
    let platform: String
    let pushToken: String
    let deviceId: String?

    init(platform: String = "ios", pushToken: String, deviceId: String? = nil) {
        self.platform = platform
        self.pushToken = pushToken
        self.deviceId = deviceId
    }
}
