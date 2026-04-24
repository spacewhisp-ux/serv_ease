import Foundation

@MainActor
final class SessionViewModel: ObservableObject {
    enum SessionStatus {
        case loading, unauthenticated, authenticated
    }

    @Published var status: SessionStatus = .loading
    @Published var user: User?

    private let authRepo = AuthRepository()
    private let ticketRepo = TicketRepository()
    private let notificationRepo = NotificationRepository()

    var role: String? { user?.role }
    var canManageFaqs: Bool {
        guard let role else { return false }
        return role == "AGENT" || role == "ADMIN"
    }

    func restoreSession() async {
        status = .loading
        do {
            if let data = UserDefaultsManager.shared.savedUserJSON,
               let savedUser = try? JSONDecoder().decode(User.self, from: data) {
                user = savedUser
            }

            guard (try? KeychainManager.shared.readRefreshToken()) != nil else {
                status = .unauthenticated
                return
            }

            let currentUser = try await authRepo.fetchCurrentUser()
            user = currentUser
            status = .authenticated
        } catch {
            status = .unauthenticated
        }
    }

    func setAuthenticated(user: User) {
        self.user = user
        status = .authenticated
    }

    func logout() async {
        try? await authRepo.logout()
        user = nil
        status = .unauthenticated
    }
}
