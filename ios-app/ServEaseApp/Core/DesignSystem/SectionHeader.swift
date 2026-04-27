import SwiftUI

struct SectionHeader: View {
    let title: String
    let subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 22, weight: .semibold))
                .tracking(-0.3)
                .foregroundStyle(AppPalette.textPrimary)
            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(AppPalette.textSecondary)
                    .lineSpacing(2)
            }
        }
    }
}
