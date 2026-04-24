import SwiftUI

struct PrimaryPillButton: View {
    let label: LocalizedStringKey
    let isLoading: Bool
    let action: () -> Void

    init(_ label: LocalizedStringKey, isLoading: Bool = false, action: @escaping () -> Void) {
        self.label = label
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(DesignTokens.pureWhite)
                }
                Text(label)
                    .font(.labelLarge)
                    .foregroundColor(DesignTokens.pureWhite)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(DesignTokens.expoBlack)
            .clipShape(Capsule())
        }
        .disabled(isLoading)
    }
}
