import SwiftUI

struct TicketDetailScreen: View {
    let ticketId: String
    @StateObject private var vm = TicketDetailViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                switch vm.status {
                case .initial, .loading:
                    ProgressView()
                        .padding(.top, 60)
                case .failure:
                    EmptyStateCard(
                        title: "Failed to load",
                        description: LocalizedStringKey(vm.errorMessage ?? "Please try again")
                    )
                case .success:
                    if let ticket = vm.ticket {
                        ticketHeader(ticket)
                        conversationSection(ticket)
                        replySection(ticket)
                    }
                }
            }
            .padding(16)
        }
        .background(DesignTokens.cloudGray)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await vm.load(ticketId: ticketId)
        }
        .confirmationDialog("Close ticket", isPresented: $vm.showCloseDialog) {
            Button("Close ticket", role: .destructive) {
                Task { await vm.closeTicket(ticketId: ticketId) }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to close this ticket?")
        }
    }

    @ViewBuilder
    private func ticketHeader(_ ticket: TicketDetail) -> some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(ticket.subject)
                        .font(.headlineMedium)
                        .foregroundColor(DesignTokens.expoBlack)
                    Spacer()
                    TagBadge(
                        label: ticket.status,
                        backgroundColor: DesignTokens.statusColor(for: ticket.status).opacity(0.12),
                        textColor: DesignTokens.statusColor(for: ticket.status)
                    )
                }

                HStack(spacing: 12) {
                    TagBadge(label: ticket.priority, backgroundColor: DesignTokens.cloudGray, textColor: DesignTokens.priorityColor(for: ticket.priority))
                    if let no = ticket.ticketNo {
                        TagBadge(label: no)
                    }
                }

                Text(ticket.description)
                    .font(.bodyLarge)
                    .foregroundColor(DesignTokens.nearBlack)
                    .padding(.top, 4)

                // Attachments not linked to messages
                if let attachments = ticket.attachments, !attachments.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Attachments")
                            .font(.bodyMedium)
                            .foregroundColor(DesignTokens.slateGray)
                        ForEach(attachments) { att in
                            HStack {
                                Image(systemName: "paperclip")
                                Text(att.fileName)
                                    .font(.bodyMedium)
                                Spacer()
                                Text(formatFileSize(att.fileSize))
                                    .font(.captionSmall)
                                    .foregroundColor(DesignTokens.silver)
                            }
                            .padding(8)
                            .background(DesignTokens.cloudGray)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }

                // Close button
                if ticket.status != "CLOSED" {
                    Button(role: .destructive) {
                        vm.showCloseDialog = true
                    } label: {
                        Label("Close ticket", systemImage: "xmark.circle")
                            .font(.bodyMedium)
                    }
                    .padding(.top, 8)
                }
            }
        }
    }

    @ViewBuilder
    private func conversationSection(_ ticket: TicketDetail) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Conversation")
                .font(.titleLarge)
                .foregroundColor(DesignTokens.nearBlack)
                .padding(.vertical, 4)

            if let messages = ticket.messages, !messages.isEmpty {
                ForEach(messages) { msg in
                    messageBubble(msg)
                }
            }
        }
    }

    @ViewBuilder
    private func messageBubble(_ msg: TicketMessage) -> some View {
        let isUser = msg.senderRole == "USER"

        VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
            HStack {
                if isUser { Spacer() }

                VStack(alignment: isUser ? .trailing : .leading, spacing: 6) {
                    Text(msg.senderRole)
                        .font(.captionSmall)
                        .foregroundColor(DesignTokens.slateGray)

                    Text(msg.body)
                        .font(.bodyLarge)
                        .foregroundColor(isUser ? DesignTokens.pureWhite : DesignTokens.nearBlack)
                        .padding(12)
                        .background(isUser ? DesignTokens.expoBlack : DesignTokens.pureWhite)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(DesignTokens.borderLavender, lineWidth: isUser ? 0 : 1)
                        )

                    if let attachments = msg.attachments, !attachments.isEmpty {
                        ForEach(attachments) { att in
                            HStack {
                                Image(systemName: "paperclip")
                                Text(att.fileName)
                                Spacer()
                                Text(formatFileSize(att.fileSize))
                            }
                            .font(.bodyMedium)
                            .foregroundColor(DesignTokens.linkCobalt)
                            .padding(8)
                            .background(DesignTokens.cloudGray)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }

                    Text(formatTime(msg.createdAt))
                        .font(.captionSmall)
                        .foregroundColor(DesignTokens.silver)
                }

                if !isUser { Spacer() }
            }
        }
    }

    @ViewBuilder
    private func replySection(_ ticket: TicketDetail) -> some View {
        if vm.canReply {
            VStack(spacing: 12) {
                TextEditor(text: $vm.replyDraft)
                    .font(.bodyLarge)
                    .frame(minHeight: 100, maxHeight: 150)
                    .padding(12)
                    .background(DesignTokens.pureWhite)
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.inputRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.inputRadius)
                            .stroke(DesignTokens.inputBorder, lineWidth: 1)
                    )

                PrimaryPillButton("Send reply", isLoading: vm.isSubmittingReply) {
                    Task { await vm.submitReply(ticketId: ticketId) }
                }
            }
            .padding(.top, 8)
        }

        if let error = vm.errorMessage {
            Text(error)
                .font(.bodyMedium)
                .foregroundColor(.red)
        }
    }

    private func formatTime(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = formatter.date(from: iso) ?? ISO8601DateFormatter().date(from: iso) ?? Date()
        let timeFmt = DateFormatter()
        timeFmt.dateFormat = "HH:mm"
        return timeFmt.string(from: date)
    }

    private func formatFileSize(_ bytes: Int) -> String {
        let kb = Double(bytes) / 1024.0
        if kb > 1024 { return String(format: "%.1f MB", kb / 1024.0) }
        return String(format: "%.0f KB", kb)
    }
}
