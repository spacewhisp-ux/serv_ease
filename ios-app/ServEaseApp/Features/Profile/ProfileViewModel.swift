import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var notifications: [AppNotification] = []
    @Published private(set) var unreadCount = 0
    @Published var errorMessage: String?

    private let notificationRepository: NotificationRepository

    init(notificationRepository: NotificationRepository) {
        self.notificationRepository = notificationRepository
    }

    func loadNotifications() async {
        do {
            async let unreadTask = notificationRepository.fetchUnreadCount()
            async let listTask = notificationRepository.fetchNotifications()
            let unreadResponse = try await unreadTask
            let listResponse = try await listTask
            unreadCount = unreadResponse.unreadCount
            notifications = listResponse.items
        } catch {
            errorMessage = error.localizedDescription
            ToastManager.shared.show(.error, message: error.localizedDescription)
        }
    }

    func markAllAsRead() async {
        do {
            _ = try await notificationRepository.markAllAsRead()
            await loadNotifications()
        } catch {
            errorMessage = error.localizedDescription
            ToastManager.shared.show(.error, message: error.localizedDescription)
        }
    }
}
