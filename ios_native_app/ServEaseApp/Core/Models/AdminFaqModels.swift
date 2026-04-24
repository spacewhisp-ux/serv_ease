import Foundation

struct AdminFaqCategory: Codable, Identifiable {
    let id: String
    let name: String
    let sortOrder: Int
    let isActive: Bool
    let createdAt: String?
    let updatedAt: String?
}

struct AdminFaqItem: Codable, Identifiable {
    let id: String
    let categoryId: String
    let question: String
    let answer: String
    let keywords: [String]
    let viewCount: Int
    let sortOrder: Int
    let isActive: Bool
    let category: AdminFaqCategory?
    let createdAt: String?
    let updatedAt: String?
}

struct AdminFaqListResponse: Codable {
    let items: [AdminFaqItem]?
    let pagination: Pagination?
}

struct CreateCategoryRequest: Codable {
    let name: String
    let sortOrder: Int
    let isActive: Bool

    init(name: String, sortOrder: Int = 0, isActive: Bool = true) {
        self.name = name
        self.sortOrder = sortOrder
        self.isActive = isActive
    }
}

struct UpdateCategoryRequest: Codable {
    let name: String?
    let sortOrder: Int?
    let isActive: Bool?
}

struct CreateFaqRequest: Codable {
    let categoryId: String
    let question: String
    let answer: String
    let keywords: [String]
    let sortOrder: Int
    let isActive: Bool

    init(categoryId: String, question: String, answer: String, keywords: [String] = [], sortOrder: Int = 0, isActive: Bool = true) {
        self.categoryId = categoryId
        self.question = question
        self.answer = answer
        self.keywords = keywords
        self.sortOrder = sortOrder
        self.isActive = isActive
    }
}

struct UpdateFaqRequest: Codable {
    let categoryId: String?
    let question: String?
    let answer: String?
    let keywords: [String]?
    let sortOrder: Int?
    let isActive: Bool?
}
