import Foundation

actor NotificationRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchNotifications() async throws -> NotificationListResponse {
        try await apiClient.get("notifications", requiresAuth: true)
    }

    func fetchUnreadCount() async throws -> UnreadCountResponse {
        try await apiClient.get("notifications/unread-count", requiresAuth: true)
    }

    func markAllAsRead() async throws -> MarkAllReadResponse {
        try await apiClient.patch("notifications/read-all", body: EmptyRequest(), requiresAuth: true)
    }
}
