import Foundation

actor HealthRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchHealth() async throws -> HealthStatus {
        try await apiClient.get("health")
    }
}
