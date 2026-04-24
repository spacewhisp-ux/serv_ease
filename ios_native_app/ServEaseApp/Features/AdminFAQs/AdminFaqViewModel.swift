import Foundation

@MainActor
final class AdminFaqViewModel: ObservableObject {
    enum Status {
        case initial, loading, success, failure
    }

    @Published var status: Status = .initial
    @Published var categories: [AdminFaqCategory] = []
    @Published var items: [AdminFaqItem] = []
    @Published var selectedCategoryId: String? = nil
    @Published var keyword: String = ""
    @Published var activeFilter: Bool? = nil
    @Published var errorMessage: String?
    @Published var isMutating = false

    // Form state
    @Published var editingCategory: AdminFaqCategory?
    @Published var editingFaq: AdminFaqItem?
    @Published var showCategoryForm = false
    @Published var showFaqForm = false

    private let adminRepo = AdminFaqRepository()

    var filteredCategories: [AdminFaqCategory] {
        var all = [AdminFaqCategory(id: "__all__", name: NSLocalizedString("All", comment: ""), sortOrder: 0, isActive: true, createdAt: nil, updatedAt: nil)]
        all.append(contentsOf: categories)
        return all
    }

    func loadAll() async {
        status = .loading
        errorMessage = nil

        do {
            async let cats = adminRepo.fetchCategories()
            async let faqs = adminRepo.fetchFaqs(categoryId: nil, keyword: nil, isActive: activeFilter)

            let (loadedCats, loadedFaqs) = try await (cats, faqs)
            categories = loadedCats
            items = loadedFaqs.items
            status = .success
        } catch {
            status = .failure
            errorMessage = error.localizedDescription
        }
    }

    func search() async {
        status = .loading
        errorMessage = nil

        do {
            let result = try await adminRepo.fetchFaqs(
                categoryId: selectedCategoryId == "__all__" ? nil : selectedCategoryId,
                keyword: keyword.isEmpty ? nil : keyword,
                isActive: activeFilter
            )
            items = result.items
            status = .success
        } catch {
            status = .failure
            errorMessage = error.localizedDescription
        }
    }

    func filterByActive(_ isActive: Bool?) async {
        activeFilter = isActive
        await search()
    }

    func filterByCategory(_ categoryId: String?) async {
        selectedCategoryId = categoryId == "__all__" ? nil : categoryId
        await search()
    }

    // MARK: - Category mutations

    func createCategory(name: String, sortOrder: Int = 0, isActive: Bool = true) async {
        isMutating = true
        do {
            let _ = try await adminRepo.createCategory(name: name, sortOrder: sortOrder, isActive: isActive)
            showCategoryForm = false
            await loadAll()
        } catch {
            errorMessage = error.localizedDescription
        }
        isMutating = false
    }

    func updateCategory(id: String, name: String? = nil, sortOrder: Int? = nil, isActive: Bool? = nil) async {
        isMutating = true
        do {
            let _ = try await adminRepo.updateCategory(id: id, name: name, sortOrder: sortOrder, isActive: isActive)
            showCategoryForm = false
            editingCategory = nil
            await loadAll()
        } catch {
            errorMessage = error.localizedDescription
        }
        isMutating = false
    }

    func deactivateCategory(id: String) async {
        isMutating = true
        do {
            try await adminRepo.deactivateCategory(id: id)
            await loadAll()
        } catch {
            errorMessage = error.localizedDescription
        }
        isMutating = false
    }

    // MARK: - FAQ mutations

    func createFaq(categoryId: String, question: String, answer: String, keywords: [String] = [], sortOrder: Int = 0, isActive: Bool = true) async {
        isMutating = true
        do {
            let _ = try await adminRepo.createFaq(categoryId: categoryId, question: question, answer: answer, keywords: keywords, sortOrder: sortOrder, isActive: isActive)
            showFaqForm = false
            await loadAll()
        } catch {
            errorMessage = error.localizedDescription
        }
        isMutating = false
    }

    func updateFaq(id: String, categoryId: String? = nil, question: String? = nil, answer: String? = nil, keywords: [String]? = nil, sortOrder: Int? = nil, isActive: Bool? = nil) async {
        isMutating = true
        do {
            let _ = try await adminRepo.updateFaq(id: id, categoryId: categoryId, question: question, answer: answer, keywords: keywords, sortOrder: sortOrder, isActive: isActive)
            showFaqForm = false
            editingFaq = nil
            await loadAll()
        } catch {
            errorMessage = error.localizedDescription
        }
        isMutating = false
    }

    func deactivateFaq(id: String) async {
        isMutating = true
        do {
            try await adminRepo.deactivateFaq(id: id)
            await loadAll()
        } catch {
            errorMessage = error.localizedDescription
        }
        isMutating = false
    }
}
