import Foundation

actor TicketRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchTickets(status: TicketStatus?) async throws -> TicketListResponse {
        var components = URLComponents()
        components.queryItems = [
            status.map { URLQueryItem(name: "status", value: $0.rawValue) }
        ].compactMap { $0 }
        let query = components.percentEncodedQuery.flatMap { $0.isEmpty ? nil : "?\($0)" } ?? ""
        return try await apiClient.get("tickets\(query)", requiresAuth: true)
    }

    func fetchTicketDetail(id: String) async throws -> TicketDetail {
        try await apiClient.get("tickets/\(id)", requiresAuth: true)
    }

    func createTicket(subject: String, description: String, category: String) async throws -> CreateTicketResponse {
        try await apiClient.post(
            "tickets",
            body: CreateTicketRequest(subject: subject, description: description, category: category, priority: nil, attachmentIds: nil),
            requiresAuth: true
        )
    }

    func reply(ticketId: String, body: String) async throws -> TicketReplyResponse {
        try await apiClient.post(
            "tickets/\(ticketId)/messages",
            body: ReplyTicketRequest(body: body, attachmentIds: nil),
            requiresAuth: true
        )
    }

    func close(ticketId: String, reason: String?) async throws -> CloseTicketResponse {
        try await apiClient.patch(
            "tickets/\(ticketId)/close",
            body: CloseTicketRequest(reason: reason),
            requiresAuth: true
        )
    }
}
