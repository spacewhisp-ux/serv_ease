import Foundation

actor HelpCenterRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchCategories() async throws -> [FaqCategory] {
        let categories: [FaqCategory] = try await apiClient.get("faq-categories")
        return categories.isEmpty ? Self.fallbackCategories : categories
    }

    func fetchFaqs(categoryId: String?, keyword: String?) async throws -> FaqListResponse {
        var components = URLComponents()
        components.queryItems = [
            categoryId.flatMap { URLQueryItem(name: "categoryId", value: $0) },
            keyword.flatMap { $0.isEmpty ? nil : URLQueryItem(name: "keyword", value: $0) }
        ].compactMap { $0 }

        let query = components.percentEncodedQuery.flatMap { $0.isEmpty ? nil : "?\($0)" } ?? ""
        let response: FaqListResponse = try await apiClient.get("faqs\(query)")
        guard response.items.isEmpty else { return response }

        let fallbackItems = Self.filteredFallbackFaqs(categoryId: categoryId, keyword: keyword)
        return FaqListResponse(
            items: fallbackItems,
            pagination: Pagination(
                page: 1,
                pageSize: max(fallbackItems.count, 1),
                total: fallbackItems.count,
                totalPages: fallbackItems.isEmpty ? 0 : 1
            )
        )
    }

    func fetchFaqDetail(id: String) async throws -> FaqDetail {
        if let fallback = Self.fallbackDetails[id] {
            return fallback
        }
        return try await apiClient.get("faqs/\(id)")
    }
}

private extension HelpCenterRepository {
    static let fallbackCategories: [FaqCategory] = [
        FaqCategory(id: "local-account", name: "账号与登录", sortOrder: 1),
        FaqCategory(id: "local-ticket", name: "工单与反馈", sortOrder: 2),
        FaqCategory(id: "local-service", name: "服务状态", sortOrder: 3)
    ]

    static let fallbackDetails: [String: FaqDetail] = [
        "local-login-reset": FaqDetail(
            id: "local-login-reset",
            categoryId: "local-account",
            question: "登录失败或收不到验证码怎么办？",
            answer: "先确认你使用的是注册时填写的邮箱或手机号，并检查网络连接是否正常。如果仍然无法登录，可以改用另一种账号方式重试，或者直接提交工单并附上失败时间和账号信息，方便客服进一步排查。",
            keywords: ["登录", "验证码", "账号"],
            viewCount: 128
        ),
        "local-ticket-progress": FaqDetail(
            id: "local-ticket-progress",
            categoryId: "local-ticket",
            question: "提交工单后多久会收到回复？",
            answer: "常规问题会在工作时间内尽快回复，复杂问题会先进入排队并在工单详情中同步处理进度。你可以在通知中心查看状态变化，也可以在工单详情里继续追加说明和截图。",
            keywords: ["工单", "回复", "进度"],
            viewCount: 94
        ),
        "local-service-health": FaqDetail(
            id: "local-service-health",
            categoryId: "local-service",
            question: "为什么首页显示服务状态待连接？",
            answer: "首页会读取后端健康检查接口来展示当前服务状态。如果网络暂时不可用或环境尚未配置完成，就会显示待连接。你可以稍后重试，或者进入帮助中心和工单页面继续其他操作。",
            keywords: ["首页", "服务状态", "健康检查"],
            viewCount: 67
        )
    ]

    static func filteredFallbackFaqs(categoryId: String?, keyword: String?) -> [FaqSummary] {
        let normalizedKeyword = keyword?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        return fallbackDetails.values
            .sorted { $0.question < $1.question }
            .filter { faq in
                guard let categoryId else { return true }
                return faq.categoryId == categoryId
            }
            .filter { faq in
                guard let normalizedKeyword, !normalizedKeyword.isEmpty else { return true }
                let haystack = [faq.question, faq.answer, faq.keywords.joined(separator: " ")]
                    .joined(separator: " ")
                    .lowercased()
                return haystack.contains(normalizedKeyword)
            }
            .map {
                FaqSummary(
                    id: $0.id,
                    categoryId: $0.categoryId,
                    question: $0.question,
                    answerPreview: String($0.answer.prefix(48)) + ($0.answer.count > 48 ? "…" : ""),
                    viewCount: $0.viewCount
                )
            }
    }
}
