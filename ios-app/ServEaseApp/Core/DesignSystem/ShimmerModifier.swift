import SwiftUI

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1
    let duration: Double
    let bounce: Bool

    init(duration: Double = 1.6, bounce: Bool = false) {
        self.duration = duration
        self.bounce = bounce
    }

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geometry in
                    let gradient = Gradient(stops: [
                        .init(color: .clear, location: max(0, phase - 0.3)),
                        .init(color: .white.opacity(0.35), location: phase),
                        .init(color: .clear, location: min(1, phase + 0.3))
                    ])

                    LinearGradient(
                        gradient: gradient,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
            .onAppear {
                withAnimation(
                    bounce
                    ? .easeInOut(duration: duration).repeatForever(autoreverses: true)
                    : .linear(duration: duration).repeatForever(autoreverses: false)
                ) {
                    phase = bounce ? 1 : 2
                }
            }
    }
}

extension View {
    func shimmer(duration: Double = 1.6, bounce: Bool = false) -> some View {
        modifier(ShimmerModifier(duration: duration, bounce: bounce))
    }
}
