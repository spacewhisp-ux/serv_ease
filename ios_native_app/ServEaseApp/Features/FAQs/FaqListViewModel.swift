import Foundation

@MainActor
final class FaqListViewModel: ObservableObject {
    enum Status {
        case initial, loading, success, failure
    }

    @Published var status: Status = .initial
    @Published var categories: [FaqCategory] = []
    @Published var items: [FaqSummary] = []
    @Published var selectedCategoryId: String? = nil
    @Published var keyword: String = ""
    @Published var errorMessage: String?

    private let faqRepo = FaqRepository()

    var filteredCategories: [FaqCategory] {
        var all = [FaqCategory(id: "__all__", name: NSLocalizedString("All", comment: ""))]
        all.append(contentsOf: categories)
        return all
    }

    func load() async {
        status = .loading
        errorMessage = nil

        do {
            async let cats = faqRepo.fetchCategories()
            async let faqs = faqRepo.fetchFaqs(categoryId: nil, keyword: nil)

            let (loadedCategories, loadedFaqs) = try await (cats, faqs)
            categories = loadedCategories
            items = loadedFaqs.items
            status = .success
        } catch {
            status = .failure
            errorMessage = error.localizedDescription
        }
    }

    func search(keyword: String) async {
        self.keyword = keyword
        status = .loading
        errorMessage = nil

        do {
            let categoryId = selectedCategoryId == "__all__" ? nil : selectedCategoryId
            let result = try await faqRepo.fetchFaqs(
                categoryId: categoryId,
                keyword: keyword.isEmpty ? nil : keyword
            )
            items = result.items
            status = .success
        } catch {
            status = .failure
            errorMessage = error.localizedDescription
        }
    }

    func filterByCategory(categoryId: String?) async {
        let effectiveId = categoryId == "__all__" ? nil : categoryId
        selectedCategoryId = effectiveId
        status = .loading
        errorMessage = nil

        do {
            let result = try await faqRepo.fetchFaqs(
                categoryId: effectiveId,
                keyword: keyword.isEmpty ? nil : keyword
            )
            items = result.items
            status = .success
        } catch {
            status = .failure
            errorMessage = error.localizedDescription
        }
    }
}
