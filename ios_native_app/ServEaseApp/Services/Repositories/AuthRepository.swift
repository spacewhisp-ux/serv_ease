import Foundation

actor AuthRepository {
    private let client = ApiClient.shared

    // MARK: - Login

    func login(account: String, password: String) async throws -> AuthResponse {
        let body = LoginRequest(account: account, password: password)
        let response: AuthResponse = try await client.post("auth/login", body: body)

        // Persist tokens
        try KeychainManager.shared.saveAccessToken(response.accessToken)
        try KeychainManager.shared.saveRefreshToken(response.refreshToken)
        await client.setAccessToken(response.accessToken)

        // Persist user JSON for offline
        if let data = try? JSONEncoder().encode(response.user) {
            UserDefaultsManager.shared.saveUser(data)
        }

        return response
    }

    // MARK: - Register

    func register(email: String?, phone: String?, password: String, displayName: String) async throws -> AuthResponse {
        let body = RegisterRequest(email: email, phone: phone, password: password, displayName: displayName)
        let response: AuthResponse = try await client.post("auth/register", body: body)

        try KeychainManager.shared.saveAccessToken(response.accessToken)
        try KeychainManager.shared.saveRefreshToken(response.refreshToken)
        await client.setAccessToken(response.accessToken)

        if let data = try? JSONEncoder().encode(response.user) {
            UserDefaultsManager.shared.saveUser(data)
        }

        return response
    }

    // MARK: - Current user

    func fetchCurrentUser() async throws -> User {
        let user: User = try await client.get("users/me")
        if let data = try? JSONEncoder().encode(user) {
            UserDefaultsManager.shared.saveUser(data)
        }
        return user
    }

    // MARK: - Logout

    func logout() async throws {
        if let refreshToken = try KeychainManager.shared.readRefreshToken() {
            let body = LogoutRequest(refreshToken: refreshToken)
            let _: [String: String]? = try? await client.post("auth/logout", body: body)
        }
        await clearSession()
    }

    func clearSession() async {
        await client.clearSession()
        UserDefaultsManager.shared.clearAll()
    }
}
