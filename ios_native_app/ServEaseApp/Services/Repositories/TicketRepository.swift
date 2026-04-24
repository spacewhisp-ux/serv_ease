import Foundation

actor TicketRepository {
    private let client = ApiClient.shared

    func fetchTickets(status: String?, page: Int = 1, pageSize: Int = 20) async throws -> (items: [TicketSummary], total: Int, page: Int, totalPages: Int) {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "pageSize", value: String(pageSize)),
        ]
        if let status, status != "ALL" {
            queryItems.append(URLQueryItem(name: "status", value: status))
        }

        let response: TicketListResponse = try await client.get("tickets", queryItems: queryItems)
        return (
            items: response.items ?? [],
            total: response.pagination?.total ?? 0,
            page: response.pagination?.page ?? page,
            totalPages: response.pagination?.totalPages ?? 1
        )
    }

    func fetchTicketDetail(id: String) async throws -> TicketDetail {
        try await client.get("tickets/\(id)")
    }

    func createTicket(subject: String, description: String, category: String, priority: String) async throws -> CreateTicketResponse {
        let body = CreateTicketRequest(subject: subject, description: description, category: category, priority: priority)
        return try await client.post("tickets", body: body)
    }

    func replyTicket(ticketId: String, body: String) async throws -> TicketReplyResult {
        let request = ReplyRequest(body: body)
        return try await client.post("tickets/\(ticketId)/messages", body: request)
    }

    func closeTicket(ticketId: String, reason: String?) async throws -> TicketCloseResult {
        let request = CloseTicketRequest(reason: reason)
        return try await client.patch("tickets/\(ticketId)/close", body: request)
    }
}
