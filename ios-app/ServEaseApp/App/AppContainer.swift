import SwiftUI

struct AppContainer: View {
    @EnvironmentObject private var sessionViewModel: SessionViewModel
    private let appContext: AppContext

    init(appContext: AppContext) {
        self.appContext = appContext
    }

    var body: some View {
        Group {
            switch sessionViewModel.state {
            case .loading:
                ProgressView("正在准备服务入口…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppPalette.background.ignoresSafeArea())
            case .guest, .authenticated:
                MainTabView(appContext: appContext)
                    .fullScreenCover(item: $sessionViewModel.loginSheet) { destination in
                        LoginView(destination: destination, authRepository: appContext.authRepository)
                    }
                    .alert("提示", isPresented: Binding(
                        get: { sessionViewModel.deletionMessage != nil },
                        set: { if !$0 { sessionViewModel.deletionMessage = nil } }
                    )) {
                        Button("知道了", role: .cancel) {}
                    } message: {
                        Text(sessionViewModel.deletionMessage ?? "")
                    }
            }
        }
        .task {
            await sessionViewModel.bootstrap()
        }
        .toast()
    }
}
