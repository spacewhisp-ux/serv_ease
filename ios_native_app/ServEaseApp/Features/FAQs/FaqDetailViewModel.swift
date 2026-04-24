import Foundation

@MainActor
final class FaqDetailViewModel: ObservableObject {
    @Published var faq: FaqDetail?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let faqRepo = FaqRepository()

    func load(faqId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            faq = try await faqRepo.fetchFaqDetail(id: faqId)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
