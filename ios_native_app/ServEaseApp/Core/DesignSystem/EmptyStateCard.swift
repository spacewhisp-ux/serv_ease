import SwiftUI

struct EmptyStateCard: View {
    let title: LocalizedStringKey
    let description: LocalizedStringKey

    var body: some View {
        SurfaceCard {
            VStack(spacing: 12) {
                Text(title)
                    .font(.titleLarge)
                    .foregroundColor(DesignTokens.nearBlack)
                    .multilineTextAlignment(.center)

                Text(description)
                    .font(.bodyMedium)
                    .foregroundColor(DesignTokens.slateGray)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
    }
}
