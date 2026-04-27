import Foundation

final class SessionStore {
    private let defaults: UserDefaults
    private let userKey = "session.currentUser"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func saveCurrentUser(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            defaults.set(data, forKey: userKey)
        }
    }

    func currentUser() -> User? {
        guard let data = defaults.data(forKey: userKey) else {
            return nil
        }
        return try? JSONDecoder().decode(User.self, from: data)
    }

    func clear() {
        defaults.removeObject(forKey: userKey)
    }
}
