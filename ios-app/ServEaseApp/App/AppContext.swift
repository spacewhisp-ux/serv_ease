import Foundation

struct AppContext {
    let config: EnvironmentConfig
    let tokenStore: TokenStore
    let sessionStore: SessionStore
    let apiClient: APIClient
    let healthRepository: HealthRepository
    let authRepository: AuthRepository
    let helpCenterRepository: HelpCenterRepository
    let ticketRepository: TicketRepository
    let notificationRepository: NotificationRepository
    let chatRepository: ChatRepository

    static func bootstrap() -> AppContext {
        let config = EnvironmentConfig.current
        let tokenStore = TokenStore()
        let sessionStore = SessionStore()
        let apiClient = APIClient(config: config, tokenStore: tokenStore)

        return AppContext(
            config: config,
            tokenStore: tokenStore,
            sessionStore: sessionStore,
            apiClient: apiClient,
            healthRepository: HealthRepository(apiClient: apiClient),
            authRepository: AuthRepository(apiClient: apiClient, tokenStore: tokenStore, sessionStore: sessionStore),
            helpCenterRepository: HelpCenterRepository(apiClient: apiClient),
            ticketRepository: TicketRepository(apiClient: apiClient),
            notificationRepository: NotificationRepository(apiClient: apiClient),
            chatRepository: ChatRepository(apiClient: apiClient)
        )
    }
}
