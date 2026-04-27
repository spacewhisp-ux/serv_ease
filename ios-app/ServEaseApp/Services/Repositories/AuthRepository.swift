import Foundation

actor AuthRepository {
    private let apiClient: APIClient
    private let tokenStore: TokenStore
    private let sessionStore: SessionStore

    init(apiClient: APIClient, tokenStore: TokenStore, sessionStore: SessionStore) {
        self.apiClient = apiClient
        self.tokenStore = tokenStore
        self.sessionStore = sessionStore
    }

    func restoreCurrentUser() async throws -> User {
        try await apiClient.get("users/me", requiresAuth: true)
    }

    func login(account: String, password: String, deviceId: String?, deviceName: String?) async throws -> User {
        let response: AuthResponse = try await apiClient.post(
            "auth/login",
            body: LoginRequest(account: account, password: password, deviceId: deviceId, deviceName: deviceName)
        )
        try tokenStore.save(tokens: AuthTokens(accessToken: response.accessToken, refreshToken: response.refreshToken))
        sessionStore.saveCurrentUser(response.user)
        return response.user
    }

    func register(
        phone: String,
        password: String,
        displayName: String,
        deviceId: String?,
        deviceName: String?
    ) async throws -> User {
        let response: AuthResponse = try await apiClient.post(
            "auth/register",
            body: RegisterRequest(
                phone: phone,
                password: password,
                displayName: displayName,
                deviceId: deviceId,
                deviceName: deviceName
            )
        )
        try tokenStore.save(tokens: AuthTokens(accessToken: response.accessToken, refreshToken: response.refreshToken))
        sessionStore.saveCurrentUser(response.user)
        return response.user
    }

    func logout() async {
        if let refreshToken = tokenStore.refreshToken() {
            _ = try? await apiClient.post("auth/logout", body: RefreshTokenRequest(refreshToken: refreshToken)) as LogoutResponse
        }
        tokenStore.clear()
        sessionStore.clear()
    }

    func deleteAccount(reason: String?) async throws -> DeleteAccountResponse {
        let response: DeleteAccountResponse = try await apiClient.delete(
            "account",
            body: DeleteAccountRequest(reason: reason),
            requiresAuth: true
        )
        tokenStore.clear()
        sessionStore.clear()
        return response
    }

    func cachedUser() -> User? {
        sessionStore.currentUser()
    }

    func hasRefreshToken() -> Bool {
        tokenStore.refreshToken() != nil
    }
}
