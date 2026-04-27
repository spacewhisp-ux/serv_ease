import Foundation
import KeychainAccess

final class TokenStore {
    private let keychain: Keychain

    init(service: String = "com.alanyu.servease.tokens") {
        self.keychain = Keychain(service: service)
    }

    func save(tokens: AuthTokens) throws {
        try keychain.set(tokens.accessToken, key: "access-token")
        try keychain.set(tokens.refreshToken, key: "refresh-token")
    }

    func accessToken() -> String? {
        keychain["access-token"]
    }

    func refreshToken() -> String? {
        keychain["refresh-token"]
    }

    func clear() {
        try? keychain.remove("access-token")
        try? keychain.remove("refresh-token")
    }
}
