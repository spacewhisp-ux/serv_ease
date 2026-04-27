import SwiftUI

@main
struct ServEaseApp: App {
    @StateObject private var appSettings = AppSettings()
    @StateObject private var router = AppRouter()
    @StateObject private var sessionViewModel: SessionViewModel
    private let appContext: AppContext

    init() {
        let context = AppContext.bootstrap()
        self.appContext = context
        _sessionViewModel = StateObject(wrappedValue: SessionViewModel(authRepository: context.authRepository))
    }

    var body: some Scene {
        WindowGroup {
            AppContainer(appContext: appContext)
                .environmentObject(appSettings)
                .environmentObject(router)
                .environmentObject(sessionViewModel)
                .environment(\.locale, appSettings.locale)
        }
    }
}
