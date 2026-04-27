import Foundation

@MainActor
final class HelpCenterViewModel: ObservableObject {
    @Published private(set) var categories: [FaqCategory] = []
    @Published private(set) var faqs: [FaqSummary] = []
    @Published var selectedCategoryID: String?
    @Published var keyword = ""
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let repository: HelpCenterRepository
    private var hasLoaded = false

    init(repository: HelpCenterRepository) {
        self.repository = repository
    }

    func loadIfNeeded() async {
        guard !hasLoaded else { return }
        hasLoaded = true
        await reload()
    }

    func reload() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            async let categoryTask = repository.fetchCategories()
            async let faqTask = repository.fetchFaqs(categoryId: selectedCategoryID, keyword: keyword)
            categories = try await categoryTask
            let faqResponse = try await faqTask
            faqs = faqResponse.items
        } catch {
            errorMessage = error.localizedDescription
            faqs = []
        }
    }

    func selectCategory(_ categoryID: String?) {
        selectedCategoryID = categoryID
        Task { await reload() }
    }
}
