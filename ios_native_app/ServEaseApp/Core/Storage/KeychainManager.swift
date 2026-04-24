import Foundation
import Security

final class KeychainManager {
    static let shared = KeychainManager()

    private let service = "com.servease.app"
    private let accessTokenKey = "access_token"
    private let refreshTokenKey = "refresh_token"

    private init() {}

    // MARK: - Generic keychain operations

    func save(key: String, value: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.encodingFailed
        }

        try? delete(key: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status: status)
        }
    }

    func read(key: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecItemNotFound { return nil }

        guard status == errSecSuccess,
              let data = item as? Data,
              let value = String(data: data, encoding: .utf8) else {
            throw KeychainError.readFailed(status: status)
        }

        return value
    }

    func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]
        SecItemDelete(query as CFDictionary)
    }

    func deleteAll() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
        ]
        SecItemDelete(query as CFDictionary)
    }

    // MARK: - Token convenience

    func saveAccessToken(_ token: String) throws {
        try save(key: accessTokenKey, value: token)
    }

    func readAccessToken() throws -> String? {
        try read(key: accessTokenKey)
    }

    func saveRefreshToken(_ token: String) throws {
        try save(key: refreshTokenKey, value: token)
    }

    func readRefreshToken() throws -> String? {
        try read(key: refreshTokenKey)
    }

    func clearTokens() throws {
        try deleteAll()
    }
}

enum KeychainError: LocalizedError {
    case encodingFailed
    case saveFailed(status: OSStatus)
    case readFailed(status: OSStatus)

    var errorDescription: String? {
        switch self {
        case .encodingFailed:     return "Failed to encode data"
        case .saveFailed(let s):  return "Keychain save failed: \(s)"
        case .readFailed(let s):  return "Keychain read failed: \(s)"
        }
    }
}
