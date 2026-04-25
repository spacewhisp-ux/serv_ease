import SwiftUI

struct NotificationsScreen: View {
    @StateObject private var vm = NotificationsViewModel()

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let sectionSpacing = DesignTokens.DeviceAdaptation.sectionSpacing(for: geometry.size.height)
                let cardSpacing = DesignTokens.DeviceAdaptation.cardSpacing(for: geometry.size.height)

                ScrollView {
                    VStack(spacing: sectionSpacing) {
                        VStack(spacing: DesignTokens.Spacing.sm) {
                            Text("Alerts")
                                .font(.displaySmall)
                                .foregroundColor(DesignTokens.expoBlack)

                            Text("\(vm.unreadCount) unread")
                                .font(.bodyLarge)
                                .foregroundColor(DesignTokens.slateGray)
                        }
                        .padding(.top, DesignTokens.Spacing.sm)

                        if vm.unreadCount > 0 {
                            Button("Mark all as read") {
                                Task { await vm.markAllAsRead() }
                            }
                            .font(.bodyMedium)
                            .foregroundColor(DesignTokens.linkCobalt)
                        }

                        switch vm.status {
                        case .initial:
                            EmptyView()
                        case .loading:
                            ProgressView()
                                .padding(.top, DesignTokens.Spacing.xxl)
                        case .failure:
                            EmptyStateCard(
                                title: "Failed to load",
                                description: LocalizedStringKey(vm.errorMessage ?? "Please try again")
                            )
                        case .success:
                            if vm.items.isEmpty {
                                EmptyStateCard(
                                    title: "No notifications",
                                    description: "You'll see updates here when something changes"
                                )
                            } else {
                                LazyVStack(spacing: cardSpacing) {
                                    ForEach(vm.items) { notif in
                                        notificationCard(notif)
                                    }
                                }
                            }
                        }
                    }
                    .padding(DesignTokens.Spacing.lg)
                }
                .background(DesignTokens.cloudGray)
                .refreshable {
                    await vm.load()
                }
                .task {
                    await vm.load()
                }
            }
        }
    }

    @ViewBuilder
    private func notificationCard(_ notif: AppNotification) -> some View {
        SurfaceCard(padding: 16) {
            HStack(alignment: .top, spacing: 12) {
                // Unread dot
                if !notif.isRead {
                    Circle()
                        .fill(DesignTokens.linkCobalt)
                        .frame(width: 8, height: 8)
                        .padding(.top, 6)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 8, height: 8)
                        .padding(.top, 6)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(notif.title)
                        .font(.titleLarge)
                        .foregroundColor(DesignTokens.nearBlack)

                    Text(notif.body)
                        .font(.bodyMedium)
                        .foregroundColor(DesignTokens.slateGray)
                        .lineLimit(3)

                    HStack {
                        TagBadge(label: notif.type)

                        Spacer()

                        Text(formatDate(notif.createdAt))
                            .font(.captionSmall)
                            .foregroundColor(DesignTokens.silver)
                    }
                }
            }
        }
        .onTapGesture {
            Task {
                if !notif.isRead {
                    await vm.markAsRead(id: notif.id)
                }
            }
        }
    }

    private func formatDate(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: iso) ?? ISO8601DateFormatter().date(from: iso) else {
            return iso
        }
        let relative = RelativeDateTimeFormatter()
        relative.unitsStyle = .abbreviated
        return relative.localizedString(for: date, relativeTo: Date())
    }
}
