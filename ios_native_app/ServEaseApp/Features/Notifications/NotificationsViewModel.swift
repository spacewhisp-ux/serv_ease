import Foundation

@MainActor
final class NotificationsViewModel: ObservableObject {
    enum Status {
        case initial, loading, success, failure
    }

    @Published var status: Status = .initial
    @Published var items: [AppNotification] = []
    @Published var unreadCount = 0
    @Published var errorMessage: String?

    private let notificationRepo = NotificationRepository()

    func load() async {
        status = .loading
        errorMessage = nil

        do {
            async let notifs = notificationRepo.fetchNotifications()
            async let count = notificationRepo.fetchUnreadCount()

            let (loadedNotifs, loadedCount) = try await (notifs, count)
            items = loadedNotifs.items
            unreadCount = loadedCount
            status = .success
        } catch {
            status = .failure
            errorMessage = error.localizedDescription
        }
    }

    func markAsRead(id: String) async {
        do {
            try await notificationRepo.markAsRead(id: id)
            if let index = items.firstIndex(where: { $0.id == id }) {
                // Create a mutable copy with readAt set or rebuild
            }
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func markAllAsRead() async {
        do {
            try await notificationRepo.markAllAsRead()
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
