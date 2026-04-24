import SwiftUI

struct SurfaceCard<Content: View>: View {
    let padding: CGFloat
    @ViewBuilder let content: () -> Content

    init(padding: CGFloat = 20, @ViewBuilder content: @escaping () -> Content) {
        self.padding = padding
        self.content = content
    }

    var body: some View {
        content()
            .frame(maxWidth: .infinity)
            .padding(padding)
            .background(DesignTokens.pureWhite)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cardRadius))
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.cardRadius)
                    .stroke(DesignTokens.borderLavender, lineWidth: 1)
            )
            .shadow(
                color: Color.black.opacity(0.08),
                radius: 18, x: 0, y: 6
            )
    }
}
