import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var sessionViewModel: SessionViewModel
    @StateObject private var viewModel: LoginViewModel

    private let destination: LoginDestination

    init(destination: LoginDestination, authRepository: AuthRepository) {
        self.destination = destination
        _viewModel = StateObject(wrappedValue: LoginViewModel(authRepository: authRepository))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SurfaceCard {
                        Text("欢迎使用 ServEase")
                            .font(.system(size: 28, weight: .bold))
                            .tracking(-0.4)
                            .foregroundStyle(AppPalette.textPrimary)

                        Text(destination.description)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(AppPalette.textSecondary)
                            .lineSpacing(2)

                        Picker("模式", selection: $viewModel.mode) {
                            ForEach(LoginViewModel.Mode.allCases) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)

                        if viewModel.mode == .register {
                            inputField(
                                title: "昵称",
                                text: $viewModel.displayName
                            )
                        }

                        phoneInputField

                        SecureField("密码", text: $viewModel.password)
                            .textFieldStyle(.roundedBorder)

                        if let successMessage = viewModel.successMessage {
                            feedbackCard(message: successMessage, color: AppPalette.success)
                        }

                        if let errorMessage = viewModel.errorMessage {
                            feedbackCard(message: errorMessage, color: AppPalette.primary)
                        }

                        Button(viewModel.isSubmitting ? "处理中…" : viewModel.mode.rawValue) {
                            Task {
                                if let user = await viewModel.submit() {
                                    sessionViewModel.completeLogin(with: user)
                                    dismiss()
                                }
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(viewModel.isSubmitting)
                    }
                }
                .padding(20)
            }
            .background(AppPalette.background.ignoresSafeArea())
            .navigationTitle("账号")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        sessionViewModel.dismissLogin()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color(.systemGray3))
                    }
                }
            }
        }
    }

    private var phoneInputField: some View {
        HStack(spacing: 8) {
            Text(viewModel.phonePrefix)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppPalette.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(AppPalette.background)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            TextField("手机号", text: $viewModel.phoneNumber)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.phonePad)
                .textInputAutocapitalization(.never)
        }
    }

    private func inputField(title: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        TextField(title, text: text)
            .textFieldStyle(.roundedBorder)
            .keyboardType(keyboardType)
            .textInputAutocapitalization(.never)
    }

    private func feedbackCard(message: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(color.opacity(0.12))
                .frame(width: 28, height: 28)
                .overlay(
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(color)
                )
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppPalette.textPrimary)
            Spacer()
        }
        .padding(12)
        .background(AppPalette.background)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private extension LoginDestination {
    var description: String {
        switch self {
        case .tickets:
            return "登录后可提交和管理工单。"
        case .notifications:
            return "登录后可查看通知消息。"
        case .profile:
            return "登录后可管理个人服务。"
        case .accountDeletion:
            return "登录后可进行账号操作。"
        }
    }
}
