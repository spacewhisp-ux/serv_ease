import SwiftUI

struct LoginScreen: View {
    @StateObject private var vm = AuthViewModel()
    @EnvironmentObject var sessionVM: SessionViewModel

    @State private var account = ""
    @State private var password = ""
    @State private var displayName = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Serv Ease")
                            .font(.displaySmall)
                            .foregroundColor(DesignTokens.expoBlack)

                        Text(vm.isRegistering ? "Create account" : "Sign in")
                            .font(.bodyLarge)
                            .foregroundColor(DesignTokens.slateGray)
                    }
                    .padding(.top, 48)

                    // Form
                    VStack(spacing: 16) {
                        TextField("Email or phone", text: $account)
                            .textContentType(vm.isRegistering ? .username : .emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding(16)
                            .background(DesignTokens.pureWhite)
                            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.inputRadius))
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignTokens.inputRadius)
                                    .stroke(DesignTokens.inputBorder, lineWidth: 1)
                            )

                        SecureField("Password (min 8 chars)", text: $password)
                            .textContentType(vm.isRegistering ? .newPassword : .password)
                            .padding(16)
                            .background(DesignTokens.pureWhite)
                            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.inputRadius))
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignTokens.inputRadius)
                                    .stroke(DesignTokens.inputBorder, lineWidth: 1)
                            )

                        if vm.isRegistering {
                            TextField("Display name (min 2 chars)", text: $displayName)
                                .textContentType(.name)
                                .padding(16)
                                .background(DesignTokens.pureWhite)
                                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.inputRadius))
                                .overlay(
                                    RoundedRectangle(cornerRadius: DesignTokens.inputRadius)
                                        .stroke(DesignTokens.inputBorder, lineWidth: 1)
                                )
                        }
                    }

                    // Error
                    if let error = vm.errorMessage {
                        Text(error)
                            .font(.bodyMedium)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }

                    // Submit
                    PrimaryPillButton(
                        vm.isRegistering ? "Create account" : "Sign in",
                        isLoading: vm.status == .submitting
                    ) {
                        Task {
                            await vm.submit(account: account, password: password, displayName: displayName)
                            if case .success = vm.status {
                                if (try? KeychainManager.shared.readAccessToken()) != nil {
                                    if let data = UserDefaultsManager.shared.savedUserJSON,
                                       let user = try? JSONDecoder().decode(User.self, from: data) {
                                        sessionVM.setAuthenticated(user: user)
                                    }
                                }
                            }
                        }
                    }

                    // Toggle mode
                    Button(action: { vm.toggleMode() }) {
                        Text(vm.isRegistering
                             ? "Already have an account? Sign in"
                             : "Don't have an account? Create one")
                            .font(.bodyMedium)
                            .foregroundColor(DesignTokens.linkCobalt)
                    }
                }
                .padding(24)
            }
            .background(DesignTokens.cloudGray)
        }
    }
}
