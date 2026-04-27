import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var sessionViewModel: SessionViewModel
    @StateObject private var viewModel: HomeViewModel
    private let helpCenterRepository: HelpCenterRepository

    init(appContext: AppContext) {
        self.helpCenterRepository = appContext.helpCenterRepository
        _viewModel = StateObject(
            wrappedValue: HomeViewModel(
                healthRepository: appContext.healthRepository,
                helpCenterRepository: appContext.helpCenterRepository,
                accountCheckRepository: AccountCheckRepository()
            )
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.isLoading && viewModel.featuredFaqs.isEmpty {
                    HomeSkeletonView()
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        BannerCard(
                            title: "ServEase 服务中心",
                            subtitle: "首页优先、游客可访问，把帮助中心和工单服务串成完整闭环。",
                            actionTitle: "查看帮助中心"
                        ) {
                            router.selectedTab = .helpCenter
                        }
                        .staggeredAppear(index: 0)

                        SecurityMaintenanceCard()
                            .staggeredAppear(index: 1)

                        AccountCheckCard(
                            input: $viewModel.accountInput,
                            isLoading: viewModel.isCheckingAccount,
                            result: viewModel.accountCheckResult,
                            errorMessage: viewModel.accountCheckError
                        ) {
                            Task { await viewModel.runAccountCheck() }
                        }
                        .staggeredAppear(index: 2)

                        SurfaceCard {
                            SectionHeader(title: "快捷服务", subtitle: nil)
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                quickAction(title: "帮助中心", systemImage: "questionmark.circle", index: 0) {
                                    router.selectedTab = .helpCenter
                                }
                                quickAction(title: "提交工单", systemImage: "ticket", index: 1) {
                                    if sessionViewModel.isAuthenticated {
                                        router.selectedTab = .tickets
                                    } else {
                                        sessionViewModel.presentLogin(reason: .tickets)
                                    }
                                }
                                quickAction(title: "通知中心", systemImage: "bell.badge", index: 2) {
                                    if sessionViewModel.isAuthenticated {
                                        router.selectedTab = .profile
                                    } else {
                                        sessionViewModel.presentLogin(reason: .notifications)
                                    }
                                }
                                quickAction(title: sessionViewModel.isAuthenticated ? "我的服务" : "登录 / 注册", systemImage: "person.crop.circle", index: 3) {
                                    if sessionViewModel.isAuthenticated {
                                        router.selectedTab = .profile
                                    } else {
                                        sessionViewModel.presentLogin(reason: .profile)
                                    }
                                }
                            }
                        }
                        .staggeredAppear(index: 3)

                        SurfaceCard {
                            SectionHeader(title: "热门 FAQ", subtitle: "从帮助中心抽取高频问题，降低跳转成本")
                            if viewModel.featuredFaqs.isEmpty {
                                Text("FAQ 内容接入后会展示在这里。")
                                    .font(.subheadline)
                                    .foregroundStyle(AppPalette.textSecondary)
                            } else {
                                ForEach(Array(viewModel.featuredFaqs.enumerated()), id: \.element.id) { idx, faq in
                                    NavigationLink {
                                        FaqDetailView(faqID: faq.id, repository: helpCenterRepository)
                                    } label: {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(faq.question)
                                                .font(.headline)
                                                .foregroundStyle(AppPalette.textPrimary)
                                            Text(faq.answerPreview)
                                                .font(.subheadline)
                                                .foregroundStyle(AppPalette.textSecondary)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .buttonStyle(.plain)
                                    .staggeredAppear(index: idx)
                                    if faq.id != viewModel.featuredFaqs.last?.id {
                                        Divider()
                                    }
                                }
                            }
                        }
                        .staggeredAppear(index: 4)

                        SurfaceCard {
                            SectionHeader(title: "服务状态", subtitle: "首版先对接健康检查和公告占位")
                            Text(viewModel.healthStatus?.service ?? "服务状态待连接")
                                .font(.headline)
                                .foregroundStyle(AppPalette.textPrimary)
                            Text(viewModel.healthStatus?.status == "ok" ? "服务正常，可继续接入 FAQ 与工单接口。" : "当前未拿到服务状态。")
                                .font(.subheadline)
                                .foregroundStyle(AppPalette.textSecondary)
                        }
                        .staggeredAppear(index: 5)
                    }
                    .padding(20)
                }
            }
            .appBackground()
            .navigationTitle("首页")
        }
        .task {
            await viewModel.loadIfNeeded()
        }
    }

    private func quickAction(title: String, systemImage: String, index: Int, action: (() -> Void)? = nil) -> some View {
        Button {
            withAnimation(.appSnappy) { action?() }
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppPalette.primary)
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .multilineTextAlignment(.leading)
            }
            .foregroundStyle(AppPalette.textPrimary)
            .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
            .padding(16)
            .background(AppPalette.card)
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(AppPalette.divider, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(.plain)
        .staggeredAppear(index: index, delayBase: 0.04)
    }
}
