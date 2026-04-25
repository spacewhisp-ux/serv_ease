import SwiftUI

struct TicketListScreen: View {
    @StateObject private var vm = TicketListViewModel()
    @State private var showCreateSheet = false

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let isCompact = DesignTokens.DeviceAdaptation.isCompactHeight(geometry.size.height)
                let sectionSpacing = DesignTokens.DeviceAdaptation.sectionSpacing(for: geometry.size.height)
                let cardSpacing = DesignTokens.DeviceAdaptation.cardSpacing(for: geometry.size.height)

                ScrollView {
                    VStack(spacing: sectionSpacing) {
                        VStack(spacing: DesignTokens.Spacing.sm) {
                            Text("Tickets")
                                .font(.displaySmall)
                                .foregroundColor(DesignTokens.expoBlack)

                            Text("Track your support requests")
                                .font(.bodyLarge)
                                .foregroundColor(DesignTokens.slateGray)
                        }
                        .padding(.top, DesignTokens.Spacing.sm)

                        PrimaryPillButton("New ticket") {
                            showCreateSheet = true
                        }
                        .padding(.horizontal, DesignTokens.Spacing.sm)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: DesignTokens.Spacing.sm) {
                                ForEach(TicketListViewModel.statusOptions, id: \.self) { status in
                                    StatusChip(status, isSelected: vm.selectedStatus == status) {
                                        Task { await vm.filterByStatus(status) }
                                    }
                                }
                            }
                            .padding(.horizontal, DesignTokens.Spacing.xs)
                        }

                        switch vm.status {
                        case .initial:
                            EmptyView()
                        case .loading:
                            ProgressView()
                                .padding(.top, DesignTokens.Spacing.xxl)
                        case .failure:
                            EmptyStateCard(
                                title: "Failed to load tickets",
                                description: LocalizedStringKey(vm.errorMessage ?? "Please try again")
                            )
                        case .success:
                            if vm.items.isEmpty {
                                EmptyStateCard(
                                    title: "No tickets",
                                    description: "Create a new ticket to get started"
                                )
                            } else {
                                LazyVStack(spacing: cardSpacing) {
                                    ForEach(vm.items) { ticket in
                                        NavigationLink(destination: TicketDetailScreen(ticketId: ticket.id)) {
                                            ticketCard(ticket)
                                        }
                                        .buttonStyle(.plain)
                                    }

                                    if vm.hasMore {
                                        Button("Load more") {
                                            Task { await vm.loadMore() }
                                        }
                                        .font(.bodyLarge)
                                        .foregroundColor(DesignTokens.linkCobalt)
                                        .padding(.vertical, DesignTokens.Spacing.md)
                                    }

                                    if vm.isLoadingMore {
                                        ProgressView()
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
                .sheet(isPresented: $showCreateSheet) {
                    CreateTicketSheet { _ in
                        showCreateSheet = false
                        Task { await vm.load() }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func ticketCard(_ ticket: TicketSummary) -> some View {
        SurfaceCard(padding: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(ticket.subject)
                        .font(.titleLarge)
                        .foregroundColor(DesignTokens.nearBlack)
                        .lineLimit(2)
                    Spacer()
                    TagBadge(
                        label: ticket.status,
                        backgroundColor: DesignTokens.statusColor(for: ticket.status).opacity(0.12),
                        textColor: DesignTokens.statusColor(for: ticket.status)
                    )
                }

                HStack(spacing: 12) {
                    Text(ticket.ticketNo)
                        .font(.captionSmall)
                        .foregroundColor(DesignTokens.slateGray)

                    TagBadge(
                        label: ticket.priority,
                        backgroundColor: DesignTokens.cloudGray,
                        textColor: DesignTokens.priorityColor(for: ticket.priority)
                    )

                    Spacer()

                    if let updated = ticket.updatedAt ?? ticket.lastMessageAt {
                        Text(formatDate(updated))
                            .font(.captionSmall)
                            .foregroundColor(DesignTokens.silver)
                    }
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
