import Foundation

@MainActor
final class LocaleManager: ObservableObject {
    @Published var selectedLocale: Locale? = nil

    private let defaults = UserDefaultsManager.shared

    func setEnglish() {
        selectedLocale = Locale(identifier: "en")
        defaults.preferredLocaleCode = "en"
    }

    func setChinese() {
        selectedLocale = Locale(identifier: "zh-Hans")
        defaults.preferredLocaleCode = "zh"
    }

    func setSystem() {
        selectedLocale = nil
        defaults.preferredLocaleCode = nil
    }

    func restore() {
        guard let code = defaults.preferredLocaleCode else { return }
        selectedLocale = Locale(identifier: code)
    }
}
