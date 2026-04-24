import Foundation

struct LoginRequest: Codable {
    let account: String
    let password: String
    let deviceName: String

    init(account: String, password: String, deviceName: String = "ios-app") {
        self.account = account
        self.password = password
        self.deviceName = deviceName
    }
}

struct RegisterRequest: Codable {
    let email: String?
    let phone: String?
    let password: String
    let displayName: String
    let deviceName: String

    init(email: String?, phone: String?, password: String, displayName: String, deviceName: String = "ios-app") {
        self.email = email
        self.phone = phone
        self.password = password
        self.displayName = displayName
        self.deviceName = deviceName
    }
}

struct AuthResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let user: User
}

struct User: Codable, Identifiable {
    let id: String
    let email: String?
    let phone: String?
    let displayName: String
    let role: String
    let status: String?
    let avatarUrl: String?
    let createdAt: String?
}

struct RefreshRequest: Codable {
    let refreshToken: String
}

struct LogoutRequest: Codable {
    let refreshToken: String
}
