import Foundation

@MainActor
final class CreateTicketViewModel: ObservableObject {
    @Published var subject = ""
    @Published var category = ""
    @Published var detail = ""
    @Published var errorMessage: String?
    @Published var isSubmitting = false
    @Published var didCreateTicket = false

    private let repository: TicketRepository

    init(repository: TicketRepository) {
        self.repository = repository
    }

    func submit() async {
        errorMessage = nil
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            _ = try await repository.createTicket(
                subject: subject.trimmingCharacters(in: .whitespacesAndNewlines),
                description: detail.trimmingCharacters(in: .whitespacesAndNewlines),
                category: category.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            didCreateTicket = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
