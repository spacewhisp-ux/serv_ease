import Foundation
import MMKV

final class KVStore {
    static let shared = KVStore()

    private let mmkv: MMKV

    private init(mmapID: String = "servease_general") {
        MMKV.initialize(rootDir: nil, logLevel: MMKVLogLevel.none)
        self.mmkv = MMKV(mmapID: mmapID)!
    }

    func set(_ value: String?, forKey key: String) {
        guard let value else {
            mmkv.removeValue(forKey: key)
            return
        }
        mmkv.set(value, forKey: key)
    }

    func string(forKey key: String) -> String? {
        mmkv.string(forKey: key)
    }

    func set(_ value: Int, forKey key: String) {
        mmkv.set(Int64(value), forKey: key)
    }

    func integer(forKey key: String) -> Int {
        Int(mmkv.int64(forKey: key))
    }

    func set(_ value: Double, forKey key: String) {
        mmkv.set(value, forKey: key)
    }

    func double(forKey key: String) -> Double {
        mmkv.double(forKey: key)
    }

    func set(_ value: Bool, forKey key: String) {
        mmkv.set(value, forKey: key)
    }

    func bool(forKey key: String) -> Bool {
        mmkv.bool(forKey: key)
    }

    func set(_ value: Data?, forKey key: String) {
        guard let value else {
            mmkv.removeValue(forKey: key)
            return
        }
        mmkv.set(value, forKey: key)
    }

    func data(forKey key: String) -> Data? {
        mmkv.data(forKey: key)
    }

    func removeObject(forKey key: String) {
        mmkv.removeValue(forKey: key)
    }

    func removeAll() {
        mmkv.clearAll()
    }

    func contains(key: String) -> Bool {
        mmkv.contains(key: key)
    }
}

extension KVStore {
    enum Keys {
        static let languageCode = "app.settings.languageCode"
        static let lastLoginAccount = "app.auth.lastLoginAccount"
        static let hasSeenOnboarding = "app.onboarding.hasSeen"
        static let notificationBadgeCount = "app.notification.badgeCount"
    }
}
