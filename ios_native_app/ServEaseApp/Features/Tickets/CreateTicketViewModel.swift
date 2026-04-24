import Foundation

@MainActor
final class CreateTicketViewModel: ObservableObject {
    enum Status {
        case idle, submitting, success, failure
    }

    @Published var status: Status = .idle
    @Published var errorMessage: String?

    @Published var subject = ""
    @Published var description = ""
    @Published var category = "General support"
    @Published var priority = "NORMAL"

    private let ticketRepo = TicketRepository()

    static let categories = ["Account", "Billing", "Bug report", "Order issue", "General support"]
    static let priorities = ["LOW", "NORMAL", "HIGH", "URGENT"]

    var isValid: Bool {
        subject.trimmingCharacters(in: .whitespaces).count >= 5 &&
        description.trimmingCharacters(in: .whitespaces).count >= 10
    }

    func submit() async -> Bool {
        guard isValid else { return false }
        status = .submitting
        errorMessage = nil

        do {
            let _ = try await ticketRepo.createTicket(
                subject: subject,
                description: description,
                category: category,
                priority: priority
            )
            status = .success
            return true
        } catch {
            status = .failure
            errorMessage = error.localizedDescription
            return false
        }
    }

    func reset() {
        status = .idle
        errorMessage = nil
        subject = ""
        description = ""
        category = "General support"
        priority = "NORMAL"
    }
}
