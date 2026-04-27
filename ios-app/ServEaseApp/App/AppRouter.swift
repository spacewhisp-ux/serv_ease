import Foundation

@MainActor
final class AppRouter: ObservableObject {
    enum Tab: Hashable {
        case home
        case helpCenter
        case tickets
        case profile
    }

    @Published var selectedTab: Tab = .home
}
