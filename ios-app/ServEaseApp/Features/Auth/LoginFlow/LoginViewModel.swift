import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    enum Mode: String, CaseIterable, Identifiable {
        case login = "手机号登录"
        case register = "手机号注册"

        var id: String { rawValue }
    }

    @Published var mode: Mode = .login
    @Published var phonePrefix = "+86"
    @Published var phoneNumber = ""
    @Published var password = ""
    @Published var displayName = ""
    @Published var isSubmitting = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    var fullPhoneNumber: String {
        phonePrefix + phoneNumber
    }

    func submit() async -> User? {
        errorMessage = nil
        successMessage = nil
        isSubmitting = true
        defer { isSubmitting = false }

        guard validateInput() else {
            return nil
        }

        do {
            let deviceName = "iPhone"
            switch mode {
            case .login:
                let user = try await authRepository.login(
                    account: fullPhoneNumber,
                    password: password,
                    deviceId: nil,
                    deviceName: deviceName
                )
                successMessage = "登录成功，正在进入服务中心。"
                return user
            case .register:
                let user = try await authRepository.register(
                    phone: fullPhoneNumber,
                    password: password,
                    displayName: displayName.trimmingCharacters(in: .whitespacesAndNewlines),
                    deviceId: nil,
                    deviceName: deviceName
                )
                successMessage = "注册成功，正在进入服务中心。"
                return user
            }
        } catch {
            errorMessage = error.localizedDescription
            ToastManager.shared.show(.error, message: error.localizedDescription)
            return nil
        }
    }

    private func validateInput() -> Bool {
        let trimmedPhone = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedPhone.isEmpty {
            errorMessage = "请输入手机号。"
            return false
        }
        if !trimmedPhone.allSatisfy(\.isNumber) {
            errorMessage = "手机号只能包含数字。"
            return false
        }
        if trimmedPhone.count < 11 {
            errorMessage = "请输入有效的手机号。"
            return false
        }
        if password.count < 8 {
            errorMessage = "密码至少需要 8 位。"
            return false
        }
        if mode == .register {
            if displayName.trimmingCharacters(in: .whitespacesAndNewlines).count < 2 {
                errorMessage = "昵称至少需要 2 个字符。"
                return false
            }
        }
        return true
    }
}
