import SwiftUI

struct TagBadge: View {
    let label: String
    var backgroundColor: Color = DesignTokens.cloudGray
    var textColor: Color = DesignTokens.nearBlack
    var fontSize: Font = .captionSmall

    var body: some View {
        Text(label)
            .font(fontSize)
            .fontWeight(.medium)
            .foregroundColor(textColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .clipShape(Capsule())
    }
}
