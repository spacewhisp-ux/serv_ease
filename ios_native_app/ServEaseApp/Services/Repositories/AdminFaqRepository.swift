import Foundation

actor AdminFaqRepository {
    private let client = ApiClient.shared

    // MARK: - Categories

    func fetchCategories(isActive: Bool? = nil) async throws -> [AdminFaqCategory] {
        var queryItems: [URLQueryItem]?
        if let isActive {
            queryItems = [URLQueryItem(name: "isActive", value: String(isActive))]
        }
        let response: AdminFaqCategoryListResponse = try await client.get("admin/faq-categories", queryItems: queryItems)
        return response.items ?? []
    }

    func createCategory(name: String, sortOrder: Int = 0, isActive: Bool = true) async throws -> AdminFaqCategory {
        let body = CreateCategoryRequest(name: name, sortOrder: sortOrder, isActive: isActive)
        return try await client.post("admin/faq-categories", body: body)
    }

    func updateCategory(id: String, name: String? = nil, sortOrder: Int? = nil, isActive: Bool? = nil) async throws -> AdminFaqCategory {
        let body = UpdateCategoryRequest(name: name, sortOrder: sortOrder, isActive: isActive)
        return try await client.patch("admin/faq-categories/\(id)", body: body)
    }

    func deactivateCategory(id: String) async throws {
        let _: [String: String]? = try await client.delete("admin/faq-categories/\(id)")
    }

    // MARK: - FAQs

    func fetchFaqs(categoryId: String? = nil, keyword: String? = nil, isActive: Bool? = nil, page: Int = 1, pageSize: Int = 20) async throws -> (items: [AdminFaqItem], total: Int, totalPages: Int) {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "pageSize", value: String(pageSize)),
        ]
        if let categoryId {
            queryItems.append(URLQueryItem(name: "categoryId", value: categoryId))
        }
        if let keyword, !keyword.isEmpty {
            queryItems.append(URLQueryItem(name: "keyword", value: keyword))
        }
        if let isActive {
            queryItems.append(URLQueryItem(name: "isActive", value: String(isActive)))
        }

        let response: AdminFaqListResponse = try await client.get("admin/faqs", queryItems: queryItems)
        return (
            items: response.items ?? [],
            total: response.pagination?.total ?? 0,
            totalPages: response.pagination?.totalPages ?? 1
        )
    }

    func fetchFaq(id: String) async throws -> AdminFaqItem {
        try await client.get("admin/faqs/\(id)")
    }

    func createFaq(categoryId: String, question: String, answer: String, keywords: [String] = [], sortOrder: Int = 0, isActive: Bool = true) async throws -> AdminFaqItem {
        let body = CreateFaqRequest(categoryId: categoryId, question: question, answer: answer, keywords: keywords, sortOrder: sortOrder, isActive: isActive)
        return try await client.post("admin/faqs", body: body)
    }

    func updateFaq(id: String, categoryId: String? = nil, question: String? = nil, answer: String? = nil, keywords: [String]? = nil, sortOrder: Int? = nil, isActive: Bool? = nil) async throws -> AdminFaqItem {
        let body = UpdateFaqRequest(categoryId: categoryId, question: question, answer: answer, keywords: keywords, sortOrder: sortOrder, isActive: isActive)
        return try await client.patch("admin/faqs/\(id)", body: body)
    }

    func deactivateFaq(id: String) async throws {
        let _: [String: String]? = try await client.delete("admin/faqs/\(id)")
    }
}

private struct AdminFaqCategoryListResponse: Codable {
    let items: [AdminFaqCategory]?
}
