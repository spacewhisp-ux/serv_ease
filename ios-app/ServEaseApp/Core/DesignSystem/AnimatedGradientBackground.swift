import SwiftUI

struct AnimatedGradientBackground: View {
    @State private var startPoint = UnitPoint(x: 0, y: 0)
    @State private var endPoint = UnitPoint(x: 1, y: 1)
    let colors: [Color]
    let duration: Double

    init(
        colors: [Color] = [
            Color(red: 248 / 255, green: 244 / 255, blue: 245 / 255),
            Color(red: 252 / 255, green: 237 / 255, blue: 239 / 255),
            Color(red: 245 / 255, green: 240 / 255, blue: 250 / 255),
            Color(red: 248 / 255, green: 244 / 255, blue: 245 / 255)
        ],
        duration: Double = 6.0
    ) {
        self.colors = colors
        self.duration = duration
    }

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: startPoint,
            endPoint: endPoint
        )
        .onAppear {
            withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                startPoint = UnitPoint(x: 1, y: 1)
                endPoint = UnitPoint(x: 0, y: 0)
            }
        }
    }
}

struct MeshGradientBackground: View {
    @State private var t: Float = 0
    let colors: [Color]

    init(colors: [Color]? = nil) {
        self.colors = colors ?? [
            Color(red: 248 / 255, green: 244 / 255, blue: 245 / 255),
            Color(red: 252 / 255, green: 237 / 255, blue: 239 / 255),
            Color(red: 245 / 255, green: 240 / 255, blue: 250 / 255),
            Color(red: 248 / 255, green: 244 / 255, blue: 245 / 255)
        ]
    }

    var body: some View {
        if #available(iOS 18.0, *) {
            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    .init(x: 0, y: 0), .init(x: 0.5, y: sin(t) * 0.1), .init(x: 1, y: 0),
                    .init(x: sin(t) * 0.1, y: 0.5), .init(x: 0.5, y: 0.5), .init(x: 1 - sin(t) * 0.1, y: 0.5),
                    .init(x: 0, y: 1), .init(x: 0.5, y: 1 - sin(t) * 0.1), .init(x: 1, y: 1)
                ],
                colors: colors
            )
            .onAppear {
                withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                    t = .pi * 2
                }
            }
        } else {
            AnimatedGradientBackground(colors: colors)
        }
    }
}

struct FloatingOrb: View {
    @State private var isAnimating = false
    let color: Color
    let size: CGFloat
    let xOffset: CGFloat
    let yOffset: CGFloat
    let duration: Double

    init(
        color: Color = AppPalette.primary.opacity(0.06),
        size: CGFloat = 200,
        xOffset: CGFloat = 100,
        yOffset: CGFloat = -60,
        duration: Double = 8.0
    ) {
        self.color = color
        self.size = size
        self.xOffset = xOffset
        self.yOffset = yOffset
        self.duration = duration
    }

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .blur(radius: size * 0.3)
            .offset(
                x: isAnimating ? xOffset : -xOffset * 0.5,
                y: isAnimating ? yOffset : -yOffset * 0.5
            )
            .onAppear {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}

struct AppBackground: View {
    var body: some View {
        ZStack {
            AnimatedGradientBackground()

            FloatingOrb(
                color: AppPalette.primary.opacity(0.05),
                size: 260,
                xOffset: 120,
                yOffset: -80,
                duration: 10
            )

            FloatingOrb(
                color: AppPalette.accent.opacity(0.04),
                size: 180,
                xOffset: -100,
                yOffset: 100,
                duration: 12
            )

            FloatingOrb(
                color: Color.purple.opacity(0.03),
                size: 140,
                xOffset: 60,
                yOffset: 160,
                duration: 14
            )
        }
        .ignoresSafeArea()
    }
}

extension View {
    func appBackground() -> some View {
        background(AppBackground())
    }
}
