import Foundation
import SwiftUI

@MainActor
final class AppSettings: ObservableObject {
    @Published var languageCode: String {
        didSet {
            KVStore.shared.set(languageCode, forKey: KVStore.Keys.languageCode)
        }
    }

    var locale: Locale {
        Locale(identifier: languageCode)
    }

    init() {
        self.languageCode = KVStore.shared.string(forKey: KVStore.Keys.languageCode) ?? Locale.preferredLanguages.first ?? "zh-Hans"
    }

    func updateLanguage(_ code: String) {
        languageCode = code
    }
}
