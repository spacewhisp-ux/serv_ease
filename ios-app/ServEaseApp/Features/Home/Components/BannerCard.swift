import SwiftUI

struct BannerCard: View {
    let title: String
    let subtitle: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(title)
                .font(.system(size: 34, weight: .bold))
                .tracking(-1.2)
                .foregroundStyle(AppPalette.textPrimary)
            Text(subtitle)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(AppPalette.textSecondary)
                .lineSpacing(3)
            Button(actionTitle, action: action)
                .buttonStyle(PrimaryButtonStyle())
                .frame(maxWidth: 220)
        }
        .padding(28)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppPalette.card)
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(AppPalette.primary.opacity(0.08))
                .frame(width: 140, height: 140)
                .offset(x: 36, y: -42)
        }
        .overlay(alignment: .bottomTrailing) {
            Capsule()
                .fill(AppPalette.accent.opacity(0.12))
                .frame(width: 120, height: 44)
                .rotationEffect(.degrees(-18))
                .offset(x: 24, y: 10)
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(AppPalette.divider, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 18, x: 0, y: 10)
    }
}
