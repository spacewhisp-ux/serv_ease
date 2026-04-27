import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var sessionViewModel: SessionViewModel
    @StateObject private var viewModel: ProfileViewModel
    private let appContext: AppContext

    init(appContext: AppContext) {
        self.appContext = appContext
        _viewModel = StateObject(wrappedValue: ProfileViewModel(notificationRepository: appContext.notificationRepository))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if let user = sessionViewModel.currentUser {
                        SurfaceCard {
                            HStack(alignment: .center, spacing: 16) {
                                Circle()
                                    .fill(AppPalette.primary.opacity(0.1))
                                    .frame(width: 54, height: 54)
                                    .overlay(
                                        Text(String(user.displayName.prefix(1)))
                                            .font(.system(size: 22, weight: .bold))
                                            .foregroundStyle(AppPalette.primary)
                                    )
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(user.displayName)
                                        .font(.system(size: 24, weight: .semibold))
                                        .tracking(-0.4)
                                    Text(user.email ?? user.phone ?? "已登录用户")
                                        .font(.system(size: 15, weight: .regular))
                                        .foregroundStyle(AppPalette.textSecondary)
                                }
                            }
                        }
                        .staggeredAppear(index: 0)

                        NavigationLink {
                            NotificationsView(viewModel: viewModel)
                        } label: {
                            menuRow(title: "通知中心", subtitle: "未读 \(viewModel.unreadCount)")
                        }
                        .buttonStyle(.plain)
                        .staggeredAppear(index: 1)

                        Button {
                            router.selectedTab = .tickets
                        } label: {
                            menuRow(title: "我的工单", subtitle: "查看服务进度与回复记录")
                        }
                        .buttonStyle(.plain)
                        .staggeredAppear(index: 2)

                        NavigationLink {
                            LanguageSettingsView(currentLanguageCode: appSettings.languageCode) { appSettings.updateLanguage($0) }
                        } label: {
                            menuRow(title: "语言设置", subtitle: appSettings.languageCode)
                        }
                        .buttonStyle(.plain)
                        .staggeredAppear(index: 3)

                        NavigationLink {
                            PrivacyPolicyView()
                        } label: {
                            menuRow(title: "隐私政策", subtitle: "查看平台隐私说明")
                        }
                        .buttonStyle(.plain)
                        .staggeredAppear(index: 4)

                        NavigationLink {
                            UserAgreementView()
                        } label: {
                            menuRow(title: "用户协议", subtitle: "查看服务使用条款")
                        }
                        .buttonStyle(.plain)
                        .staggeredAppear(index: 5)

#if DEBUG
                        NavigationLink {
                            APIDebugView(appContext: appContext)
                        } label: {
                            menuRow(title: "API 调试", subtitle: "测试全部接口连通性")
                        }
                        .buttonStyle(.plain)
                        .staggeredAppear(index: 6)
#endif

                        Button("退出登录", role: .destructive) {
                            Task { await sessionViewModel.signOut() }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .staggeredAppear(index: 7)

                        Button("注销账号", role: .destructive) {
                            Task { await sessionViewModel.deleteAccount(reason: "用户在 iOS 客户端发起注销") }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .staggeredAppear(index: 8)
                    } else {
                        EmptyStateView(
                            title: "登录后解锁更多服务",
                            message: "你可以查看通知、管理工单、执行退出和注销等私有操作。",
                            actionTitle: "登录 / 注册"
                        ) {
                            sessionViewModel.presentLogin(reason: .profile)
                        }
                        .staggeredAppear(index: 0)

                        NavigationLink {
                            LanguageSettingsView(currentLanguageCode: appSettings.languageCode) { appSettings.updateLanguage($0) }
                        } label: {
                            menuRow(title: "语言设置", subtitle: appSettings.languageCode)
                        }
                        .buttonStyle(.plain)
                        .staggeredAppear(index: 1)

                        NavigationLink {
                            PrivacyPolicyView()
                        } label: {
                            menuRow(title: "隐私政策", subtitle: "查看平台隐私说明")
                        }
                        .buttonStyle(.plain)
                        .staggeredAppear(index: 2)

                        NavigationLink {
                            UserAgreementView()
                        } label: {
                            menuRow(title: "用户协议", subtitle: "查看服务使用条款")
                        }
                        .buttonStyle(.plain)
                        .staggeredAppear(index: 3)
                    }
                }
                .padding(20)
            }
            .appBackground()
            .navigationTitle("我的")
        }
        .task(id: sessionViewModel.isAuthenticated) {
            guard sessionViewModel.isAuthenticated else { return }
            await viewModel.loadNotifications()
        }
    }

    private func menuRow(title: String, subtitle: String) -> some View {
        SurfaceCard {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .tracking(-0.25)
                        .foregroundStyle(AppPalette.textPrimary)
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(AppPalette.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppPalette.primary)
            }
        }
    }
}
