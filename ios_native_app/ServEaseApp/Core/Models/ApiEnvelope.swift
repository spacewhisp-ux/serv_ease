import Foundation

struct ApiEnvelope<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let error: ApiErrorBody?
    let message: String?
}

struct ApiErrorBody: Codable {
    let code: String?
    let message: String?
}

struct Pagination: Codable {
    let total: Int?
    let page: Int?
    let pageSize: Int?
    let totalPages: Int?
}

struct FaqCategoryListResponse: Codable {
    let items: [FaqCategory]?
}

struct FaqListResponse: Codable {
    let items: [FaqSummary]?
    let pagination: Pagination?
}
