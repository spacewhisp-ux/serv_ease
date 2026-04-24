import Foundation

@MainActor
final class TicketListViewModel: ObservableObject {
    enum Status {
        case initial, loading, success, failure
    }

    @Published var status: Status = .initial
    @Published var items: [TicketSummary] = []
    @Published var selectedStatus: String = "ALL"
    @Published var page = 1
    @Published var totalPages = 1
    @Published var total = 0
    @Published var isLoadingMore = false
    @Published var errorMessage: String?

    private let ticketRepo = TicketRepository()

    var hasMore: Bool { page < totalPages }

    static let statusOptions = ["ALL", "OPEN", "PENDING", "IN_PROGRESS", "RESOLVED", "CLOSED"]

    func load() async {
        status = .loading
        errorMessage = nil
        page = 1

        do {
            let result = try await ticketRepo.fetchTickets(
                status: selectedStatus == "ALL" ? nil : selectedStatus
            )
            items = result.items
            total = result.total
            page = result.page
            totalPages = result.totalPages
            status = .success
        } catch {
            status = .failure
            errorMessage = error.localizedDescription
        }
    }

    func loadMore() async {
        guard !isLoadingMore, hasMore else { return }
        isLoadingMore = true

        do {
            let result = try await ticketRepo.fetchTickets(
                status: selectedStatus == "ALL" ? nil : selectedStatus,
                page: page + 1
            )
            items.append(contentsOf: result.items)
            page = result.page
            total = result.total
            totalPages = result.totalPages
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoadingMore = false
    }

    func filterByStatus(_ status: String) async {
        selectedStatus = status
        await load()
    }
}
