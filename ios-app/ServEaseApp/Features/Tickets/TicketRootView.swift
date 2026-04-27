import SwiftUI

struct TicketRootView: View {
    @EnvironmentObject private var sessionViewModel: SessionViewModel
    private let appContext: AppContext

    init(appContext: AppContext) {
        self.appContext = appContext
    }

    var body: some View {
        Group {
            if sessionViewModel.isAuthenticated {
                TicketListView(repository: appContext.ticketRepository)
            } else {
                NavigationStack {
                    VStack {
                        EmptyStateView(
                            title: "登录后查看工单",
                            message: "首版支持登录后查看工单列表、创建工单、追踪处理进度。",
                            actionTitle: "登录 / 注册"
                        ) {
                            sessionViewModel.presentLogin(reason: .tickets)
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppPalette.background.ignoresSafeArea())
                    .navigationTitle("工单")
                }
            }
        }
    }
}
