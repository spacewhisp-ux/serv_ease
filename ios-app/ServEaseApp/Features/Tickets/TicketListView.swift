import SwiftUI

struct TicketListView: View {
    @StateObject private var viewModel: TicketListViewModel
    @State private var isPresentingCreateTicket = false
    private let repository: TicketRepository

    init(repository: TicketRepository) {
        self.repository = repository
        _viewModel = StateObject(wrappedValue: TicketListViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SurfaceCard {
                        SectionHeader(title: "服务工单", subtitle: "当帮助中心无法解决问题时，可以提交工单并持续追踪处理进度")
                        Button("新建工单") {
                            isPresentingCreateTicket = true
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .frame(maxWidth: 200)
                    }
                    .staggeredAppear(index: 0)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            statusChip(title: "全部", isSelected: viewModel.selectedStatus == nil) {
                                viewModel.select(status: nil)
                            }
                            ForEach(TicketStatus.allCases) { status in
                                statusChip(title: status.displayName, isSelected: viewModel.selectedStatus == status) {
                                    viewModel.select(status: status)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.horizontal, -20)
                    .staggeredAppear(index: 1)

                    if let errorMessage = viewModel.errorMessage {
                        EmptyStateView(title: "工单加载失败", message: errorMessage)
                            .staggeredAppear(index: 2)
                    } else if viewModel.isLoading, viewModel.tickets.isEmpty {
                        TicketListSkeletonView(count: 3)
                    } else if viewModel.tickets.isEmpty {
                        EmptyStateView(title: "暂无工单", message: "FAQ 没解决时，可以从这里创建新的服务工单。")
                            .staggeredAppear(index: 2)
                    } else {
                        ForEach(Array(viewModel.tickets.enumerated()), id: \.element.id) { idx, ticket in
                            NavigationLink {
                                TicketDetailView(ticketID: ticket.id, repository: repository)
                            } label: {
                                SurfaceCard {
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack(alignment: .top) {
                                            VStack(alignment: .leading, spacing: 6) {
                                                Text(ticket.subject)
                                                    .font(.system(size: 18, weight: .semibold))
                                                    .tracking(-0.25)
                                                    .foregroundStyle(AppPalette.textPrimary)
                                                Text(ticket.ticketNo)
                                                    .font(.system(size: 13, weight: .medium))
                                                    .foregroundStyle(AppPalette.textSecondary)
                                            }
                                            Spacer()
                                            statusBadge(ticket.status)
                                        }

                                        HStack {
                                            Label(ticket.priority, systemImage: "flag")
                                            Spacer()
                                            Label(ticket.lastMessageAt, systemImage: "clock")
                                        }
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(AppPalette.textSecondary)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .staggeredAppear(index: idx + 2, delayBase: 0.05)
                        }
                    }
                }
                .padding(20)
            }
            .appBackground()
            .navigationTitle("工单")
            .sheet(isPresented: $isPresentingCreateTicket) {
                CreateTicketView(repository: repository) {
                    Task { await viewModel.load() }
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }

    private func statusChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            PillTag(title: title, isSelected: isSelected)
        }
        .buttonStyle(.plain)
    }

    private func statusBadge(_ status: TicketStatus) -> some View {
        Text(status.displayName)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(AppPalette.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AppPalette.primary.opacity(0.08))
            .clipShape(Capsule())
    }
}
