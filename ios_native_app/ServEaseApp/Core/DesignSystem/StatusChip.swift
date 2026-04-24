import SwiftUI

struct StatusChip: View {
    let label: String
    let isSelected: Bool
    let isPill: Bool
    let action: () -> Void

    init(_ label: String, isSelected: Bool = false, isPill: Bool = true, action: @escaping () -> Void) {
        self.label = label
        self.isSelected = isSelected
        self.isPill = isPill
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.captionSmall)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? DesignTokens.pureWhite : DesignTokens.nearBlack)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? DesignTokens.expoBlack : DesignTokens.cloudGray)
                .clipShape(isPill ? AnyShape(Capsule()) : AnyShape(RoundedRectangle(cornerRadius: 8)))
                .overlay(
                    (isPill ? AnyShape(Capsule()) : AnyShape(RoundedRectangle(cornerRadius: 8)))
                        .stroke(DesignTokens.borderLavender, lineWidth: isSelected ? 0 : 1)
                )
        }
        .buttonStyle(.plain)
    }
}
