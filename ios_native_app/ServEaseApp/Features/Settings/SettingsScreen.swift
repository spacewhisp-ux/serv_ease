import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject var localeManager: LocaleManager

    @State private var selectedLanguage: String = "system"

    var body: some View {
        Form {
            Section("Language") {
                Picker("Language", selection: $selectedLanguage) {
                    Text("Follow system").tag("system")
                    Text("English").tag("en")
                    Text("中文").tag("zh")
                }
                .onChange(of: selectedLanguage) { _, newValue in
                    switch newValue {
                    case "en": localeManager.setEnglish()
                    case "zh": localeManager.setChinese()
                    default: localeManager.setSystem()
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            switch localeManager.selectedLocale?.identifier {
            case "en": selectedLanguage = "en"
            case "zh-Hans": selectedLanguage = "zh"
            default: selectedLanguage = "system"
            }
        }
    }
}
