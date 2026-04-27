import SwiftUI

struct NotificationsView: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if let errorMessage = viewModel.errorMessage {
                    EmptyStateView(title: "通知中心暂不可用", message: errorMessage)
                } else if viewModel.notifications.isEmpty {
                    EmptyStateView(title: "暂无通知", message: "有新的工单更新或系统通知时会显示在这里。")
                } else {
                    SurfaceCard {
                        SectionHeader(title: "通知中心", subtitle: "集中查看工单更新和系统消息")
                        Button("全部标为已读") {
                            Task { await viewModel.markAllAsRead() }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .frame(maxWidth: 220)
                    }

                    ForEach(viewModel.notifications) { notification in
                        SurfaceCard {
                            HStack(alignment: .top, spacing: 14) {
                                Circle()
                                    .fill((notification.readAt == nil ? AppPalette.primary : AppPalette.textSecondary).opacity(0.1))
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Image(systemName: notification.readAt == nil ? "bell.badge.fill" : "bell")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(notification.readAt == nil ? AppPalette.primary : AppPalette.textSecondary)
                                    )
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(notification.title)
                                        .font(.system(size: 18, weight: .semibold))
                                        .tracking(-0.25)
                                        .foregroundStyle(AppPalette.textPrimary)
                                    Text(notification.body)
                                        .font(.system(size: 15, weight: .regular))
                                        .foregroundStyle(AppPalette.textSecondary)
                                        .lineSpacing(2)
                                    HStack {
                                        Text(notification.readAt == nil ? "未读" : "已读")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundStyle(notification.readAt == nil ? AppPalette.primary : AppPalette.textSecondary)
                                        Spacer()
                                        Text(notification.createdAt)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundStyle(AppPalette.textSecondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(AppPalette.background.ignoresSafeArea())
        .navigationTitle("通知中心")
    }
}
