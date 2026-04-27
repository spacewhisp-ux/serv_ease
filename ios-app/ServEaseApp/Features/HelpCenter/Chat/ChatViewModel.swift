import Foundation

@MainActor
final class ChatViewModel: ObservableObject {
    @Published private(set) var messages: [ChatMessage] = []
    @Published var inputText = ""
    @Published private(set) var isLoadingQuestions = false
    @Published private(set) var isSubmitting = false
    @Published var errorMessage: String?

    private let repository: ChatRepository
    private var questions: [ChatQuestion] = []

    init(repository: ChatRepository) {
        self.repository = repository
    }

    func loadQuestions() async {
        isLoadingQuestions = true
        defer { isLoadingQuestions = false }

        do {
            questions = try await repository.fetchQuestions()

            messages = [
                ChatMessage(
                    sender: .system,
                    body: "您好，我是 ServEase 智能助手 👋\n请选择以下常见问题，或直接输入您想问的内容：",
                    timestamp: Date()
                )
            ]

            if !questions.isEmpty {
                messages.append(ChatMessage(
                    sender: .system,
                    body: "",
                    timestamp: Date(),
                    isQuickReply: true
                ))
            }
        } catch {
            errorMessage = error.localizedDescription
            ToastManager.shared.show(.error, message: error.localizedDescription)
            messages = [
                ChatMessage(
                    sender: .system,
                    body: "您好，我是 ServEase 智能助手 👋\n暂时无法加载常见问题，您可以直接输入想问的内容。",
                    timestamp: Date()
                )
            ]
        }
    }

    func tapQuestion(_ question: ChatQuestion) async {
        let userMsg = ChatMessage(
            sender: .user,
            body: question.text,
            timestamp: Date()
        )
        messages.append(userMsg)

        var systemMsg = ChatMessage(
            sender: .system,
            body: question.reply,
            timestamp: Date()
        )

        if let linkUrl = question.linkUrl, let linkLabel = question.linkLabel {
            systemMsg.linkUrl = linkUrl
            systemMsg.linkLabel = linkLabel
        } else if let linkUrl = question.linkUrl {
            systemMsg.linkUrl = linkUrl
            systemMsg.linkLabel = "查看详情"
        }

        messages.append(systemMsg)
    }

    func sendText() async {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isSubmitting else { return }

        let userText = trimmed
        inputText = ""
        isSubmitting = true

        let userMsg = ChatMessage(
            sender: .user,
            body: userText,
            timestamp: Date()
        )
        messages.append(userMsg)

        do {
            let response = try await repository.submitText(userText)
            var systemMsg = ChatMessage(
                sender: .system,
                body: response.reply,
                timestamp: Date(),
                suggestTicket: response.suggestTicket
            )
            messages.append(systemMsg)
        } catch {
            messages.append(ChatMessage(
                sender: .system,
                body: "抱歉，网络出现问题。请稍后再试。",
                timestamp: Date()
            ))
            ToastManager.shared.show(.error, message: error.localizedDescription)
        }

        isSubmitting = false
    }

    var quickReplyQuestions: [ChatQuestion] {
        questions
    }
}
