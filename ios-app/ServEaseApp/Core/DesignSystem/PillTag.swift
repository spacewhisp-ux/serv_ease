import SwiftUI

struct PillTag: View {
    let title: String
    var isSelected: Bool = false

    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(isSelected ? .white : AppPalette.textSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(isSelected ? AppPalette.primary : AppPalette.card)
            .overlay(
                Capsule()
                    .stroke(isSelected ? AppPalette.primary : AppPalette.divider, lineWidth: 1)
            )
            .clipShape(Capsule())
    }
}
