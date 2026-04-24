import Foundation

@MainActor
final class TicketDetailViewModel: ObservableObject {
    enum Status {
        case initial, loading, success, failure
    }

    @Published var status: Status = .initial
    @Published var ticket: TicketDetail?
    @Published var errorMessage: String?
    @Published var replyDraft = ""
    @Published var isSubmittingReply = false
    @Published var isClosingTicket = false
    @Published var closeReason = ""
    @Published var showCloseDialog = false

    private let ticketRepo = TicketRepository()

    var canReply: Bool { ticket?.status != "CLOSED" && ticket?.status != "RESOLVED" }

    func load(ticketId: String) async {
        status = .loading
        errorMessage = nil

        do {
            ticket = try await ticketRepo.fetchTicketDetail(id: ticketId)
            status = .success
        } catch {
            status = .failure
            errorMessage = error.localizedDescription
        }
    }

    func submitReply(ticketId: String) async -> Bool {
        guard !replyDraft.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        isSubmittingReply = true

        do {
            let _ = try await ticketRepo.replyTicket(ticketId: ticketId, body: replyDraft)
            replyDraft = ""
            isSubmittingReply = false
            await load(ticketId: ticketId)
            return true
        } catch {
            errorMessage = error.localizedDescription
            isSubmittingReply = false
            return false
        }
    }

    func closeTicket(ticketId: String) async -> Bool {
        isClosingTicket = true

        do {
            let reason = closeReason.trimmingCharacters(in: .whitespaces)
            let _ = try await ticketRepo.closeTicket(
                ticketId: ticketId,
                reason: reason.isEmpty ? nil : reason
            )
            closeReason = ""
            showCloseDialog = false
            isClosingTicket = false
            await load(ticketId: ticketId)
            return true
        } catch {
            errorMessage = error.localizedDescription
            isClosingTicket = false
            return false
        }
    }
}
