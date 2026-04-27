import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(title: String, message: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 14) {
                Circle()
                    .fill(AppPalette.primary.opacity(0.08))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "sparkles")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(AppPalette.primary)
                    )

                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                    .tracking(-0.25)
                    .foregroundStyle(AppPalette.textPrimary)

                Text(message)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(AppPalette.textSecondary)
                    .lineSpacing(2)

                if let actionTitle, let action {
                    Button(actionTitle, action: action)
                        .buttonStyle(PrimaryButtonStyle())
                        .frame(maxWidth: 220)
                }
            }
        }
    }
}
