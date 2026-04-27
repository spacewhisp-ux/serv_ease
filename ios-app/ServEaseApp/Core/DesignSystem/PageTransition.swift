import SwiftUI

enum AppTransition {
    case slideUp
    case scaleFade
    case slideAndFade
    case crossDissolve

    var asAnyTransition: AnyTransition {
        switch self {
        case .slideUp:
            .asymmetric(
                insertion: .move(edge: .bottom).combined(with: .opacity),
                removal: .move(edge: .bottom).combined(with: .opacity)
            )
        case .scaleFade:
            .asymmetric(
                insertion: .scale(scale: 0.92).combined(with: .opacity),
                removal: .scale(scale: 0.92).combined(with: .opacity)
            )
        case .slideAndFade:
            .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .trailing).combined(with: .opacity)
            )
        case .crossDissolve:
            .opacity
        }
    }
}

extension Animation {
    static let appSpring = Animation.spring(response: 0.45, dampingFraction: 0.82)
    static let appSnappy = Animation.spring(response: 0.35, dampingFraction: 0.88)
    static let appBouncy = Animation.spring(response: 0.5, dampingFraction: 0.68)
    static let appSmooth = Animation.easeInOut(duration: 0.35)
}

struct StaggeredAppear: ViewModifier {
    let index: Int
    let delayBase: Double
    @State private var appeared = false

    init(index: Int, delayBase: Double = 0.06) {
        self.index = index
        self.delayBase = delayBase
    }

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 18)
            .onAppear {
                withAnimation(.appSpring.delay(Double(index) * delayBase)) {
                    appeared = true
                }
            }
    }
}

struct AppearFromBottom: ViewModifier {
    @State private var appeared = false
    let delay: Double

    init(delay: Double = 0) {
        self.delay = delay
    }

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 24)
            .scaleEffect(appeared ? 1 : 0.96)
            .onAppear {
                withAnimation(.appSpring.delay(delay)) {
                    appeared = true
                }
            }
    }
}

struct PulseEffect: ViewModifier {
    @State private var isPulsing = false
    let minOpacity: Double
    let maxOpacity: Double
    let duration: Double

    init(minOpacity: Double = 0.6, maxOpacity: Double = 1.0, duration: Double = 1.8) {
        self.minOpacity = minOpacity
        self.maxOpacity = maxOpacity
        self.duration = duration
    }

    func body(content: Content) -> some View {
        content
            .opacity(isPulsing ? minOpacity : maxOpacity)
            .onAppear {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
    }
}

extension View {
    func staggeredAppear(index: Int, delayBase: Double = 0.06) -> some View {
        modifier(StaggeredAppear(index: index, delayBase: delayBase))
    }

    func appearFromBottom(delay: Double = 0) -> some View {
        modifier(AppearFromBottom(delay: delay))
    }

    func pulse(minOpacity: Double = 0.6, maxOpacity: Double = 1.0, duration: Double = 1.8) -> some View {
        modifier(PulseEffect(minOpacity: minOpacity, maxOpacity: maxOpacity, duration: duration))
    }

    func cardPress() -> some View {
        self.scaleEffect(1)
            .onTapGesture {}
    }
}
