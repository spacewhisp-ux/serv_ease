import Foundation

struct EnvironmentConfig {
    let apiBaseURL: URL

    static let current: EnvironmentConfig = {
        guard let url = Bundle.main.url(forResource: "Config", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              let apiBaseURL = dict["apiBaseURL"] as? String,
              let parsedURL = URL(string: apiBaseURL)
        else {
            fatalError("Config.plist 缺失或 apiBaseURL 格式错误，请在 Resources/Config.plist 中配置。")
        }
        return EnvironmentConfig(apiBaseURL: parsedURL)
    }()
}
