import SwiftUI

@main
struct ServEaseApp: App {
    @StateObject private var sessionVM = SessionViewModel()
    @StateObject private var localeManager = LocaleManager()

    var body: some Scene {
        WindowGroup {
            Group {
                switch sessionVM.status {
                case .loading:
                    ProgressView()
                        .background(DesignTokens.cloudGray)
                case .authenticated:
                    MainTabView()
                case .unauthenticated:
                    LoginScreen()
                }
            }
            .environmentObject(sessionVM)
            .environmentObject(localeManager)
            .environment(\.locale, localeManager.selectedLocale.flatMap { $0 } ?? .current)
            .task {
                await sessionVM.restoreSession()
                localeManager.restore()
            }
        }
    }
}
