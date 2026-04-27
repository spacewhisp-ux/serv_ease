import Foundation

#if DEBUG
    @MainActor
    final class APIDebugViewModel: ObservableObject {
        enum EndpointCategory: String, CaseIterable, Identifiable {
            case health = "健康检查"
            case auth = "认证"
            case tickets = "工单"
            case helpCenter = "帮助中心"
            case notifications = "通知"

            var id: String { rawValue }
        }

        enum TestState: Equatable {
            case pending
            case running
            case success(String)
            case failure(String, String)
        }

        struct Endpoint: Identifiable {
            let id = UUID()
            let name: String
            let method: String
            let path: String
            let category: EndpointCategory
            let requiresAuth: Bool
            var state: TestState = .pending
            var duration: TimeInterval?
        }

        @Published var endpoints: [Endpoint] = []
        @Published var isRunningAll = false
        @Published var authPhone = "13800138000"
        @Published var authPassword = "test1234"
        @Published var authDisplayName = "测试用户"
        @Published var isLoggedIn = false
        @Published var testingSummary: String?

        private var ticketId: String?
        private let appContext: AppContext

        init(appContext: AppContext) {
            self.appContext = appContext
            buildEndpoints()
        }

        private func buildEndpoints() {
            endpoints = [
                Endpoint(name: "服务健康检查", method: "GET", path: "/health", category: .health, requiresAuth: false),
                Endpoint(name: "手机号登录", method: "POST", path: "/auth/login", category: .auth, requiresAuth: false),
                Endpoint(name: "手机号注册", method: "POST", path: "/auth/register", category: .auth, requiresAuth: false),
                Endpoint(name: "获取当前用户", method: "GET", path: "/users/me", category: .auth, requiresAuth: true),
                Endpoint(name: "退出登录", method: "POST", path: "/auth/logout", category: .auth, requiresAuth: true),
                Endpoint(name: "FAQ分类列表", method: "GET", path: "/faq-categories", category: .helpCenter, requiresAuth: false),
                Endpoint(name: "FAQ列表", method: "GET", path: "/faqs", category: .helpCenter, requiresAuth: false),
                Endpoint(name: "FAQ详情", method: "GET", path: "/faqs/{id}", category: .helpCenter, requiresAuth: false),
                Endpoint(name: "工单列表", method: "GET", path: "/tickets", category: .tickets, requiresAuth: true),
                Endpoint(name: "创建工单", method: "POST", path: "/tickets", category: .tickets, requiresAuth: true),
                Endpoint(name: "工单详情", method: "GET", path: "/tickets/{id}", category: .tickets, requiresAuth: true),
                Endpoint(name: "工单回复", method: "POST", path: "/tickets/{id}/messages", category: .tickets, requiresAuth: true),
                Endpoint(name: "关闭工单", method: "PATCH", path: "/tickets/{id}/close", category: .tickets, requiresAuth: true),
                Endpoint(name: "通知列表", method: "GET", path: "/notifications", category: .notifications, requiresAuth: true),
                Endpoint(name: "未读通知数", method: "GET", path: "/notifications/unread-count", category: .notifications, requiresAuth: true),
                Endpoint(name: "全部已读", method: "PATCH", path: "/notifications/read-all", category: .notifications, requiresAuth: true),
                Endpoint(name: "注销账号", method: "DELETE", path: "/account", category: .auth, requiresAuth: true),
            ]
        }

        func runAll() async {
            guard !isRunningAll else { return }
            isRunningAll = true
            testingSummary = nil

            var successCount = 0
            var failCount = 0

            for i in endpoints.indices {
                guard isRunningAll else { break }
                endpoints[i].state = .running
                await testEndpoint(at: i)
                if case .success = endpoints[i].state { successCount += 1 }
                else if case .failure = endpoints[i].state { failCount += 1 }
            }

            testingSummary = "\(successCount) 通过, \(failCount) 失败, 共 \(endpoints.count) 个接口"
            isRunningAll = false
        }

        func runSingle(index: Int) async {
            endpoints[index].state = .running
            await testEndpoint(at: index)
        }

        func stop() {
            isRunningAll = false
        }

        func login() async {
            guard let i = endpoints.firstIndex(where: { $0.path == "/auth/login" && $0.method == "POST" }) else { return }
            endpoints[i].state = .running
            await testEndpoint(at: i)
            isLoggedIn = appContext.tokenStore.accessToken() != nil
        }

        func resetAll() {
            for i in endpoints.indices {
                endpoints[i].state = .pending
                endpoints[i].duration = nil
            }
            isLoggedIn = false
            ticketId = nil
            testingSummary = nil
        }

        private func testEndpoint(at index: Int) async {
            let endpoint = endpoints[index]
            let start = Date()

            do {
                switch endpoint.path {
                case "/health":
                    _ = try await appContext.healthRepository.fetchHealth()
                case "/auth/login":
                    let user = try await appContext.authRepository.login(
                        account: "+86\(authPhone)",
                        password: authPassword,
                        deviceId: nil,
                        deviceName: "DebugTester"
                    )
                    isLoggedIn = true
                    let data = "用户: \(user.displayName), ID: \(user.id)"
                    endpoints[index] = updated(endpoint, state: .success(data), duration: Date().timeIntervalSince(start))
                    return
                case "/auth/register":
                    let user = try await appContext.authRepository.register(
                        phone: "+86\(authPhone)",
                        password: authPassword,
                        displayName: authDisplayName,
                        deviceId: nil,
                        deviceName: "DebugTester"
                    )
                    isLoggedIn = true
                    let data = "用户: \(user.displayName), ID: \(user.id)"
                    endpoints[index] = updated(endpoint, state: .success(data), duration: Date().timeIntervalSince(start))
                    return
                case "/users/me":
                    let user = try await appContext.authRepository.restoreCurrentUser()
                    let data = "用户: \(user.displayName), 角色: \(user.role)"
                    endpoints[index] = updated(endpoint, state: .success(data), duration: Date().timeIntervalSince(start))
                    return
                case "/auth/logout":
                    await appContext.authRepository.logout()
                    isLoggedIn = false
                    endpoints[index] = updated(endpoint, state: .success("已退出"), duration: Date().timeIntervalSince(start))
                    return
                case "/faq-categories":
                    let cats = try await appContext.helpCenterRepository.fetchCategories()
                    let data = "共 \(cats.count) 个分类"
                    endpoints[index] = updated(endpoint, state: .success(data), duration: Date().timeIntervalSince(start))
                    return
                case "/faqs":
                    let faqs = try await appContext.helpCenterRepository.fetchFaqs(categoryId: nil, keyword: nil)
                    let data = "共 \(faqs.items.count) 条FAQ"
                    endpoints[index] = updated(endpoint, state: .success(data), duration: Date().timeIntervalSince(start))
                    return
                case "/faqs/{id}":
                    let detail = try await appContext.helpCenterRepository.fetchFaqDetail(id: "local-login-reset")
                    let data = "问题: \(detail.question)"
                    endpoints[index] = updated(endpoint, state: .success(data), duration: Date().timeIntervalSince(start))
                    return
                case "/tickets":
                    if endpoint.method == "POST" {
                        let created = try await appContext.ticketRepository.createTicket(
                            subject: "联调测试工单",
                            description: "通过API调试自动创建的测试工单",
                            category: "问题反馈"
                        )
                        ticketId = created.id
                        let data = "工单: \(created.ticketNo)"
                        endpoints[index] = updated(endpoint, state: .success(data), duration: Date().timeIntervalSince(start))
                    } else {
                        let tickets = try await appContext.ticketRepository.fetchTickets(status: nil)
                        if let first = tickets.items.first { ticketId = first.id }
                        let data = "共 \(tickets.items.count) 个工单"
                        endpoints[index] = updated(endpoint, state: .success(data), duration: Date().timeIntervalSince(start))
                    }
                    return
                case "/tickets/{id}":
                    guard let tid = ticketId else {
                        endpoints[index] = updated(endpoint, state: .failure("无可用工单ID", "需先测试 /tickets"), duration: Date().timeIntervalSince(start))
                        return
                    }
                    let detail = try await appContext.ticketRepository.fetchTicketDetail(id: tid)
                    let data = "工单: \(detail.subject), 状态: \(detail.status.displayName)"
                    endpoints[index] = updated(endpoint, state: .success(data), duration: Date().timeIntervalSince(start))
                    return
                case "/tickets/{id}/messages":
                    guard let tid = ticketId else {
                        endpoints[index] = updated(endpoint, state: .failure("无可用工单ID", "需先测试 /tickets"), duration: Date().timeIntervalSince(start))
                        return
                    }
                    let reply = try await appContext.ticketRepository.reply(ticketId: tid, body: "[Debug] 自动测试回复")
                    let data = "消息ID: \(reply.messageId)"
                    endpoints[index] = updated(endpoint, state: .success(data), duration: Date().timeIntervalSince(start))
                    return
                case "/tickets/{id}/close":
                    guard let tid = ticketId else {
                        endpoints[index] = updated(endpoint, state: .failure("无可用工单ID", "需先测试 /tickets"), duration: Date().timeIntervalSince(start))
                        return
                    }
                    let closed = try await appContext.ticketRepository.close(ticketId: tid, reason: "[Debug] 自动测试关闭")
                    let data = "状态: \(closed.status.displayName)"
                    endpoints[index] = updated(endpoint, state: .success(data), duration: Date().timeIntervalSince(start))
                    return
                case "/notifications":
                    let notifs = try await appContext.notificationRepository.fetchNotifications()
                    let data = "共 \(notifs.items.count) 条通知"
                    endpoints[index] = updated(endpoint, state: .success(data), duration: Date().timeIntervalSince(start))
                    return
                case "/notifications/unread-count":
                    let unread = try await appContext.notificationRepository.fetchUnreadCount()
                    let data = "\(unread.unreadCount) 条未读"
                    endpoints[index] = updated(endpoint, state: .success(data), duration: Date().timeIntervalSince(start))
                    return
                case "/notifications/read-all":
                    let result = try await appContext.notificationRepository.markAllAsRead()
                    let data = "已标记 \(result.updatedCount) 条为已读"
                    endpoints[index] = updated(endpoint, state: .success(data), duration: Date().timeIntervalSince(start))
                    return
                case "/account":
                    await appContext.authRepository.logout()
                    isLoggedIn = false
                    endpoints[index] = updated(endpoint, state: .success("账号已注销"), duration: Date().timeIntervalSince(start))
                    return
                default:
                    endpoints[index] = updated(endpoint, state: .failure("未知端点", endpoint.path), duration: Date().timeIntervalSince(start))
                    return
                }
            } catch {
                endpoints[index] = updated(endpoint, state: .failure("错误", error.localizedDescription), duration: Date().timeIntervalSince(start))
            }
        }

        private func updated(_ endpoint: Endpoint, state: TestState, duration: TimeInterval) -> Endpoint {
            var copy = endpoint
            copy.state = state
            copy.duration = duration
            return copy
        }
    }
#endif
