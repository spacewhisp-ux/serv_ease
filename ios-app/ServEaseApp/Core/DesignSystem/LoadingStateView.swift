import SwiftUI

struct LoadingStateView: View {
    let title: String
    let message: String

    var body: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 14) {
                ProgressView()
                    .tint(AppPalette.primary)
                    .pulse()
                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                    .tracking(-0.25)
                    .foregroundStyle(AppPalette.textPrimary)
                Text(message)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(AppPalette.textSecondary)
                    .lineSpacing(2)
            }
        }
    }
}
