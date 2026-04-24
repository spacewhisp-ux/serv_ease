import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    enum Status {
        case idle, submitting, success, failure
    }

    @Published var status: Status = .idle
    @Published var isRegistering = false
    @Published var errorMessage: String?

    private let authRepo = AuthRepository()

    func toggleMode() {
        isRegistering.toggle()
        errorMessage = nil
        status = .idle
    }

    func submit(account: String, password: String, displayName: String? = nil) async {
        status = .submitting
        errorMessage = nil

        do {
            let isEmail = account.contains("@")
            let response: AuthResponse

            if isRegistering {
                let name = (displayName?.isEmpty == false) ? displayName! : "Serv Ease User"
                response = try await authRepo.register(
                    email: isEmail ? account : nil,
                    phone: isEmail ? nil : account,
                    password: password,
                    displayName: name
                )
            } else {
                response = try await authRepo.login(account: account, password: password)
            }

            status = .success
            // SessionViewModel.setAuthenticated is called by LoginScreen observing this
        } catch {
            status = .failure
            errorMessage = error.localizedDescription
        }
    }

    func clearError() {
        errorMessage = nil
        if status == .failure { status = .idle }
    }
}
