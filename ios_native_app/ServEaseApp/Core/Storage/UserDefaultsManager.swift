import Foundation

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let preferredLocaleCode = "preferred_locale_code"
        static let userJSON = "user_json"
    }

    var preferredLocaleCode: String? {
        get { defaults.string(forKey: Keys.preferredLocaleCode) }
        set { defaults.set(newValue, forKey: Keys.preferredLocaleCode) }
    }

    var savedUserJSON: Data? {
        get { defaults.data(forKey: Keys.userJSON) }
        set { defaults.set(newValue, forKey: Keys.userJSON) }
    }

    func saveUser(_ data: Data) {
        savedUserJSON = data
    }

    func clearAll() {
        defaults.removeObject(forKey: Keys.preferredLocaleCode)
        defaults.removeObject(forKey: Keys.userJSON)
    }
}
