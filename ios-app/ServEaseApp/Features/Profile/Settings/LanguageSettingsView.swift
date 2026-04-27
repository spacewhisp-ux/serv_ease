import SwiftUI

struct LanguageSettingsView: View {
    let currentLanguageCode: String
    let onSelect: (String) -> Void

    private let options = [
        ("zh-Hans", "简体中文"),
        ("en", "English")
    ]

    var body: some View {
        List(options, id: \.0) { option in
            Button {
                onSelect(option.0)
            } label: {
                HStack {
                    Text(option.1)
                    Spacer()
                    if currentLanguageCode == option.0 {
                        Image(systemName: "checkmark")
                            .foregroundStyle(AppPalette.primary)
                    }
                }
            }
        }
        .navigationTitle("语言设置")
    }
}
