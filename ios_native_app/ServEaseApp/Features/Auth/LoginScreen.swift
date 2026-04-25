import SwiftUI

struct LoginScreen: View {
    @StateObject private var vm = AuthViewModel()
    @EnvironmentObject var sessionVM: SessionViewModel

    @State private var account = ""
    @State private var password = ""
    @State private var displayName = ""

    var body: some View {
        GeometryReader { geometry in
            let horizontalPadding = DesignTokens.DeviceAdaptation.horizontalPadding(for: geometry.size.width)
            let contentWidth = DesignTokens.DeviceAdaptation.contentWidth(for: geometry.size.width, horizontalPadding: horizontalPadding)
            let topPadding = DesignTokens.DeviceAdaptation.topPadding(for: geometry.size.height)
            let isCompact = DesignTokens.DeviceAdaptation.isCompactHeight(geometry.size.height)

            ZStack {
                DesignTokens.cloudGray
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: isCompact ? DesignTokens.Spacing.xl : DesignTokens.Spacing.xxl) {
                        VStack(spacing: DesignTokens.Spacing.sm) {
                            Text("Serv Ease")
                                .font(.displaySmall)
                                .foregroundColor(DesignTokens.expoBlack)
                                .multilineTextAlignment(.center)

                            Text(vm.isRegistering ? "Create account" : "Sign in")
                                .font(.bodyLarge)
                                .foregroundColor(DesignTokens.slateGray)
                                .multilineTextAlignment(.center)
                        }

                        VStack(spacing: DesignTokens.Spacing.lg) {
                            TextField("Email or phone", text: $account)
                                .textContentType(vm.isRegistering ? .username : .emailAddress)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
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

                        if let error = vm.errorMessage {
                            Text(error)
                                .font(.bodyMedium)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }

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

                        Button(action: { vm.toggleMode() }) {
                            Text(vm.isRegistering
                                 ? "Already have an account? Sign in"
                                 : "Don't have an account? Create one")
                                .font(.bodyMedium)
                                .foregroundColor(DesignTokens.linkCobalt)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: contentWidth)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, topPadding)
                    .padding(.bottom, DesignTokens.Spacing.huge)
                }
            }
            .ignoresSafeArea(.keyboard)
        }
    }
}
