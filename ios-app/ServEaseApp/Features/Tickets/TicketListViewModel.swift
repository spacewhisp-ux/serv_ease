import Foundation

@MainActor
final class TicketListViewModel: ObservableObject {
    @Published private(set) var tickets: [TicketSummary] = []
    @Published var selectedStatus: TicketStatus?
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let repository: TicketRepository

    init(repository: TicketRepository) {
        self.repository = repository
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            tickets = try await repository.fetchTickets(status: selectedStatus).items
        } catch {
            errorMessage = error.localizedDescription
            tickets = []
        }
    }

    func select(status: TicketStatus?) {
        selectedStatus = status
        Task { await load() }
    }
}
