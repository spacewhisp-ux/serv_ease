import Foundation

actor FaqRepository {
    private let client = ApiClient.shared

    func fetchCategories() async throws -> [FaqCategory] {
        let response: FaqCategoryListResponse = try await client.get("faq-categories")
        return response.items ?? []
    }

    func fetchFaqs(categoryId: String?, keyword: String?) async throws -> (items: [FaqSummary], total: Int, totalPages: Int) {
        var queryItems: [URLQueryItem] = []
        if let categoryId {
            queryItems.append(URLQueryItem(name: "categoryId", value: categoryId))
        }
        if let keyword, !keyword.isEmpty {
            queryItems.append(URLQueryItem(name: "keyword", value: keyword))
        }

        let response: FaqListResponse = try await client.get("faqs", queryItems: queryItems.isEmpty ? nil : queryItems)
        return (
            items: response.items ?? [],
            total: response.pagination?.total ?? 0,
            totalPages: response.pagination?.totalPages ?? 1
        )
    }

    func fetchFaqDetail(id: String) async throws -> FaqDetail {
        try await client.get("faqs/\(id)")
    }
}
