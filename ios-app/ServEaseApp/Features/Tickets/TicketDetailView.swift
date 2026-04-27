import SwiftUI

struct TicketDetailView: View {
    @StateObject private var viewModel: TicketDetailViewModel

    init(ticketID: String, repository: TicketRepository) {
        _viewModel = StateObject(wrappedValue: TicketDetailViewModel(ticketID: ticketID, repository: repository))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if let ticket = viewModel.ticket {
                    SurfaceCard {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(ticket.subject)
                                    .font(.system(size: 24, weight: .semibold))
                                    .tracking(-0.4)
                                Text(ticket.ticketNo)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(AppPalette.textSecondary)
                            }
                            Spacer()
                            Text(ticket.status.displayName)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(AppPalette.primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(AppPalette.primary.opacity(0.08))
                                .clipShape(Capsule())
                        }
                        HStack {
                            Label(ticket.category, systemImage: "folder")
                            Spacer()
                            Label(ticket.priority, systemImage: "flag")
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(AppPalette.textSecondary)
                        Text(ticket.description)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(AppPalette.textSecondary)
                            .lineSpacing(2)
                    }

                    SurfaceCard {
                        SectionHeader(title: "沟通记录", subtitle: nil)
                        if ticket.messages.isEmpty {
                            Text("暂无消息记录")
                                .foregroundStyle(AppPalette.textSecondary)
                        } else {
                            ForEach(ticket.messages) { message in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(message.senderRole)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(AppPalette.primary)
                                    Text(message.body)
                                        .font(.system(size: 15, weight: .regular))
                                        .foregroundStyle(AppPalette.textPrimary)
                                        .lineSpacing(2)
                                    Text(message.createdAt)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(AppPalette.textSecondary)
                                }
                                .padding(14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(AppPalette.background)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                if message.id != ticket.messages.last?.id {
                                    Divider()
                                }
                            }
                        }
                    }

                    SurfaceCard {
                        SectionHeader(title: "追加说明", subtitle: nil)
                        TextEditor(text: $viewModel.replyBody)
                            .frame(minHeight: 120)
                            .padding(10)
                            .background(AppPalette.background)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                        if let successMessage = viewModel.successMessage {
                            feedbackRow(message: successMessage, color: AppPalette.success)
                        }

                        if let errorMessage = viewModel.errorMessage {
                            feedbackRow(message: errorMessage, color: AppPalette.primary)
                        }

                        Button(viewModel.isSubmitting ? "提交中…" : "发送回复") {
                            Task { await viewModel.sendReply() }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(viewModel.isSubmitting)

                        if ticket.status != .closed {
                            Button("关闭工单", role: .destructive) {
                                Task { await viewModel.closeTicket() }
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .disabled(viewModel.isSubmitting)
                        }
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    EmptyStateView(title: "工单详情加载失败", message: errorMessage)
                } else {
                    LoadingStateView(title: "正在加载工单详情", message: "工单内容和沟通记录准备好后会显示在这里。")
                }
            }
            .padding(20)
        }
        .background(AppPalette.background.ignoresSafeArea())
        .navigationTitle("工单详情")
        .task {
            await viewModel.load()
        }
    }

    private func feedbackRow(message: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(color.opacity(0.12))
                .frame(width: 28, height: 28)
                .overlay(
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(color)
                )
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppPalette.textPrimary)
            Spacer()
        }
        .padding(12)
        .background(AppPalette.background)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
