import Foundation

struct FaqCategory: Codable, Identifiable {
    let id: String
    let name: String
}

struct FaqSummary: Codable, Identifiable {
    let id: String
    let categoryId: String
    let question: String
    let answerPreview: String
    let viewCount: Int
}

struct FaqDetail: Codable, Identifiable {
    let id: String
    let categoryId: String?
    let question: String
    let answer: String
    let keywords: [String]
    let viewCount: Int?

    init(id: String, question: String, answer: String, keywords: [String], categoryId: String? = nil, viewCount: Int? = nil) {
        self.id = id
        self.question = question
        self.answer = answer
        self.keywords = keywords
        self.categoryId = categoryId
        self.viewCount = viewCount
    }
}
