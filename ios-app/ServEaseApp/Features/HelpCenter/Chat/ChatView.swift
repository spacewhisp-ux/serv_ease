import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @Namespace private var scrollBottom
    @FocusState private var isInputFocused: Bool

    init(repository: ChatRepository) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(repository: repository))
    }

    var body: some View {
        VStack(spacing: 0) {
            messageList
            chatInputBar
        }
        .background(AppPalette.background)
        .navigationTitle("在线问答")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel.messages.isEmpty {
                await viewModel.loadQuestions()
            }
        }
    }

    // MARK: - Message List

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    if viewModel.isLoadingQuestions {
                        chatLoadingView
                    } else {
                        chatMessagesList
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .onChange(of: viewModel.messages.count) { _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: viewModel.messages.last?.body) { _ in
                scrollToBottom(proxy: proxy)
            }
            .onTapGesture {
                isInputFocused = false
            }
        }
    }

    private var chatLoadingView: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 80)
            LoadingStateView(title: "正在连接智能助手…", message: "加载中")
            Spacer()
        }
    }

    private var chatMessagesList: some View {
        ForEach(Array(viewModel.messages.enumerated()), id: \.element.id) { idx, message in
            if message.isQuickReply {
                quickReplyGrid
                    .id("quick-reply-\(idx)")
            } else {
                ChatBubbleView(message: message)
                    .id("msg-\(idx)")
            }
        }
    }

    private var quickReplyGrid: some View {
        VStack(spacing: 8) {
            ForEach(viewModel.quickReplyQuestions) { question in
                Button {
                    Task { await viewModel.tapQuestion(question) }
                } label: {
                    HStack {
                        Text(question.text)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppPalette.primary)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppPalette.primary.opacity(0.5))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .background(AppPalette.primary.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(AppPalette.primary.opacity(0.12), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Scroll Helper

    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let last = viewModel.messages.last else { return }
        let id = last.isQuickReply ? "quick-reply-\(viewModel.messages.count - 1)"
                                   : "msg-\(viewModel.messages.count - 1)"
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            proxy.scrollTo(id, anchor: .bottom)
        }
    }

    // MARK: - Input Bar

    private var chatInputBar: some View {
        HStack(spacing: 10) {
            TextField("请输入您的问题…", text: $viewModel.inputText, axis: .vertical)
                .font(.system(size: 15))
                .focused($isInputFocused)
                .lineLimit(1 ... 4)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(AppPalette.card)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(AppPalette.divider, lineWidth: 1)
                )
                .onSubmit {
                    Task { await viewModel.sendText() }
                }

            Button {
                Task { await viewModel.sendText() }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(
                        viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? AppPalette.textSecondary.opacity(0.4)
                            : AppPalette.primary
                    )
            }
            .disabled(viewModel.isSubmitting)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(AppPalette.card)
        .overlay(alignment: .top) {
            Divider()
        }
    }
}

// MARK: - Chat Bubble Component

private struct ChatBubbleView: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.sender == .system {
                avatarView
                bubbleContent
                Spacer(minLength: 40)
            } else {
                Spacer(minLength: 40)
                bubbleContent
                avatarView
            }
        }
        .padding(.vertical, 4)
    }

    private var avatarView: some View {
        Circle()
            .fill(message.sender == .system
                ? AppPalette.primary.opacity(0.1)
                : AppPalette.primary)
            .frame(width: 32, height: 32)
            .overlay(
                Image(systemName: message.sender == .system
                    ? "bubble.left.fill"
                    : "person.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(message.sender == .system
                        ? AppPalette.primary
                        : .white)
            )
    }

    private var bubbleContent: some View {
        VStack(alignment: message.sender == .user ? .trailing : .leading, spacing: 6) {
            Text(message.body)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(
                    message.sender == .user
                        ? .white
                        : AppPalette.textPrimary
                )
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            if let linkUrl = message.linkUrl {
                Link(destination: URL(string: linkUrl)!) {
                    HStack(spacing: 4) {
                        Image(systemName: "link")
                            .font(.system(size: 12))
                        Text(message.linkLabel ?? "查看详情")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(
                        message.sender == .user
                            ? .white.opacity(0.9)
                            : AppPalette.primary
                    )
                    .padding(.top, 2)
                }
            }

            if message.suggestTicket {
                VStack(spacing: 8) {
                    Divider()
                        .opacity(message.sender == .user ? 0.3 : 1)
                    HStack(spacing: 6) {
                        Image(systemName: "ticket")
                            .font(.system(size: 13))
                        Text("需要人工帮助？提交工单")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(
                        message.sender == .user
                            ? .white
                            : AppPalette.primary
                    )
                }
                .padding(.top, 4)
            }

            Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(
                    message.sender == .user
                        ? .white.opacity(0.7)
                        : AppPalette.textSecondary
                )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            message.sender == .user
                ? AppPalette.primary
                : AppPalette.card
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    message.sender == .user
                        ? Color.clear
                        : AppPalette.divider,
                    lineWidth: 1
                )
        )
    }
}
