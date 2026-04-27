import SwiftUI
import Lottie

struct LottieAnimationView: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode
    let contentMode: UIView.ContentMode
    let speed: CGFloat

    init(
        name: String,
        loopMode: LottieLoopMode = .loop,
        contentMode: UIView.ContentMode = .scaleAspectFit,
        speed: CGFloat = 1.0
    ) {
        self.name = name
        self.loopMode = loopMode
        self.contentMode = contentMode
        self.speed = speed
    }

    func makeUIView(context: Context) -> Lottie.LottieAnimationView {
        let animationView = Lottie.LottieAnimationView(name: name)
        animationView.loopMode = loopMode
        animationView.contentMode = contentMode
        animationView.animationSpeed = speed
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.play()
        return animationView
    }

    func updateUIView(_ uiView: Lottie.LottieAnimationView, context: Context) {}
}

struct LottieLoadingView: View {
    let message: String?

    init(message: String? = nil) {
        self.message = message
    }

    var body: some View {
        VStack(spacing: 16) {
            LottieAnimationView(
                name: "loading_dots",
                loopMode: .loop,
                speed: 1.2
            )
            .frame(width: 120, height: 120)

            if let message {
                Text(message)
                    .font(AppFont.subheadline)
                    .foregroundStyle(AppPalette.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppPalette.background.ignoresSafeArea())
    }
}

struct LottieEmptyStateView: View {
    let title: String
    let subtitle: String?
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        title: String,
        subtitle: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: 16) {
            LottieAnimationView(
                name: "empty_state",
                loopMode: .playOnce,
                speed: 0.8
            )
            .frame(width: 160, height: 160)

            Text(title)
                .font(AppFont.headline)
                .foregroundStyle(AppPalette.textPrimary)

            if let subtitle {
                Text(subtitle)
                    .font(AppFont.subheadline)
                    .foregroundStyle(AppPalette.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(AppFont.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(AppPalette.primary)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(32)
    }
}
