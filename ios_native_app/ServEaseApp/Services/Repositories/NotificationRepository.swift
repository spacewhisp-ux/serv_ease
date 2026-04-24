import Foundation

actor NotificationRepository {
    private let client = ApiClient.shared

    func fetchNotifications(page: Int = 1, pageSize: Int = 20) async throws -> (items: [AppNotification], total: Int) {
        let queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "pageSize", value: String(pageSize)),
        ]
        let response: NotificationListResponse = try await client.get("notifications", queryItems: queryItems)
        return (items: response.items ?? [], total: response.pagination?.total ?? 0)
    }

    func fetchUnreadCount() async throws -> Int {
        let response: UnreadCountResponse = try await client.get("notifications/unread-count")
        return response.unreadCount
    }

    func markAsRead(id: String) async throws {
        let _: MarkReadResponse = try await client.patch("notifications/\(id)/read", body: Optional<Empty>.none)
    }

    func markAllAsRead() async throws {
        let _: MarkAllReadResponse = try await client.patch("notifications/read-all", body: Optional<Empty>.none)
    }
}

private struct Empty: Codable {}
