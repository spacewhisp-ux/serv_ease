import Foundation

@MainActor
final class SessionViewModel: ObservableObject {
    enum State: Equatable {
        case loading
        case guest
        case authenticated(User)
    }

    @Published private(set) var state: State = .loading
    @Published var loginSheet: LoginDestination?
    @Published var deletionMessage: String?

    let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    var currentUser: User? {
        if case let .authenticated(user) = state {
            return user
        }
        return nil
    }

    var isAuthenticated: Bool {
        currentUser != nil
    }

    func bootstrap() async {
        if let cachedUser = await authRepository.cachedUser() {
            state = .authenticated(cachedUser)
        }

        guard await authRepository.hasRefreshToken() else {
            if currentUser == nil {
                state = .guest
            }
            return
        }

        do {
            let user = try await authRepository.restoreCurrentUser()
            state = .authenticated(user)
        } catch {
            state = .guest
        }
    }

    func presentLogin(reason: LoginDestination) {
        loginSheet = reason
    }

    func dismissLogin() {
        loginSheet = nil
    }

    func completeLogin(with user: User) {
        state = .authenticated(user)
        loginSheet = nil
    }

    func signOut() async {
        await authRepository.logout()
        state = .guest
    }

    func deleteAccount(reason: String?) async {
        do {
            _ = try await authRepository.deleteAccount(reason: reason)
            deletionMessage = "账号已提交注销。"
            state = .guest
        } catch {
            deletionMessage = error.localizedDescription
            ToastManager.shared.show(.error, message: error.localizedDescription)
        }
    }
}

enum LoginDestination: String, Identifiable {
    case tickets = "工单"
    case notifications = "通知中心"
    case profile = "我的服务"
    case accountDeletion = "账号操作"

    var id: String { rawValue }
}
