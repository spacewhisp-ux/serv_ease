import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var router: AppRouter
    private let appContext: AppContext

    init(appContext: AppContext) {
        self.appContext = appContext
    }

    var body: some View {
        TabView(selection: $router.selectedTab) {
            HomeView(appContext: appContext)
                .tabItem {
                    Label("首页", systemImage: "house")
                }
                .tag(AppRouter.Tab.home)

            HelpCenterView(appContext: appContext)
                .tabItem {
                    Label("帮助中心", systemImage: "questionmark.circle")
                }
                .tag(AppRouter.Tab.helpCenter)

            TicketRootView(appContext: appContext)
                .tabItem {
                    Label("工单", systemImage: "ticket")
                }
                .tag(AppRouter.Tab.tickets)

            ProfileView(appContext: appContext)
                .tabItem {
                    Label("我的", systemImage: "person.crop.circle")
                }
                .tag(AppRouter.Tab.profile)
        }
        .tint(AppPalette.primary)
        .background(AppPalette.background)
    }
}
