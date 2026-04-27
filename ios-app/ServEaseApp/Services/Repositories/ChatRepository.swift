import Foundation

actor ChatRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchQuestions() async throws -> [ChatQuestion] {
        let questions: [ChatQuestion] = try await apiClient.get("chat/questions")
        return questions.sorted { $0.sortOrder < $1.sortOrder }
    }

    func submitText(_ text: String) async throws -> ChatSubmitResponse {
        try await apiClient.post("chat/submit", body: ChatSubmitRequest(text: text))
    }
}
