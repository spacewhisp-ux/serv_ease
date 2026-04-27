import Foundation

@MainActor
final class FaqDetailViewModel: ObservableObject {
    @Published private(set) var faq: FaqDetail?
    @Published var errorMessage: String?
    @Published var feedbackMessage: String?

    private let faqID: String
    private let repository: HelpCenterRepository

    init(faqID: String, repository: HelpCenterRepository) {
        self.faqID = faqID
        self.repository = repository
    }

    func load() async {
        do {
            faq = try await repository.fetchFaqDetail(id: faqID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func recordFeedback(isHelpful: Bool) {
        feedbackMessage = isHelpful ? "已记录：这个 FAQ 解决了你的问题。" : "已记录：你可以继续提交工单获取支持。"
    }
}
