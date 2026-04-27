import Foundation

@MainActor
final class TicketDetailViewModel: ObservableObject {
    @Published private(set) var ticket: TicketDetail?
    @Published var replyBody = ""
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var isSubmitting = false

    private let ticketID: String
    private let repository: TicketRepository

    init(ticketID: String, repository: TicketRepository) {
        self.ticketID = ticketID
        self.repository = repository
    }

    func load() async {
        do {
            ticket = try await repository.fetchTicketDetail(id: ticketID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func sendReply() async {
        let body = replyBody.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !body.isEmpty else {
            errorMessage = "请输入回复内容后再发送。"
            return
        }

        errorMessage = nil
        successMessage = nil
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            _ = try await repository.reply(ticketId: ticketID, body: body)
            replyBody = ""
            successMessage = "回复已发送。"
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func closeTicket() async {
        errorMessage = nil
        successMessage = nil
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            _ = try await repository.close(ticketId: ticketID, reason: "用户在 iOS 客户端关闭工单")
            successMessage = "工单已关闭。"
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
