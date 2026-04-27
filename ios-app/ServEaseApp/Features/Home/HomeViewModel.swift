import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var accountInput = ""
    @Published var accountCheckResult: AccountCheckResult?
    @Published var isCheckingAccount = false
    @Published var accountCheckError: String?
    @Published private(set) var healthStatus: HealthStatus?
    @Published private(set) var featuredFaqs: [FaqSummary] = []
    @Published private(set) var isLoading = false

    private let healthRepository: HealthRepository
    private let helpCenterRepository: HelpCenterRepository
    private let accountCheckRepository: AccountCheckRepository
    private var hasLoaded = false

    init(
        healthRepository: HealthRepository,
        helpCenterRepository: HelpCenterRepository,
        accountCheckRepository: AccountCheckRepository
    ) {
        self.healthRepository = healthRepository
        self.helpCenterRepository = helpCenterRepository
        self.accountCheckRepository = accountCheckRepository
    }

    func loadIfNeeded() async {
        guard !hasLoaded else { return }
        hasLoaded = true
        await refresh()
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        async let health = healthRepository.fetchHealth()
        async let faqs = helpCenterRepository.fetchFaqs(categoryId: nil, keyword: nil)

        do {
            healthStatus = try await health
        } catch {
            healthStatus = nil
        }

        do {
            let faqResponse = try await faqs
            featuredFaqs = Array(faqResponse.items.prefix(3))
        } catch {
            featuredFaqs = []
        }
    }

    func runAccountCheck() async {
        accountCheckError = nil
        isCheckingAccount = true
        defer { isCheckingAccount = false }

        do {
            accountCheckResult = try await accountCheckRepository.checkAccount(identifier: accountInput)
        } catch {
            accountCheckError = error.localizedDescription
            ToastManager.shared.show(.error, message: error.localizedDescription)
        }
    }
}
