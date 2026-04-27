import SwiftUI

enum ToastStyle {
    case success
    case error
    case warning
    case info

    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .success: return AppPalette.success
        case .error: return AppPalette.primary
        case .warning: return AppPalette.warning
        case .info: return .blue
        }
    }
}

struct ToastItem: Equatable, Identifiable {
    let id = UUID()
    let style: ToastStyle
    let message: String
    let duration: TimeInterval

    init(style: ToastStyle, message: String, duration: TimeInterval = 2.5) {
        self.style = style
        self.message = message
        self.duration = duration
    }

    static func == (lhs: ToastItem, rhs: ToastItem) -> Bool {
        lhs.id == rhs.id
    }
}

struct ToastView: View {
    let item: ToastItem

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: item.style.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(item.style.iconColor)

            Text(item.message)
                .font(AppFont.body)
                .foregroundStyle(AppPalette.textPrimary)
                .lineLimit(2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(AppPalette.divider.opacity(0.5), lineWidth: 0.5)
        )
    }
}

final class ToastManager: ObservableObject {
    static let shared = ToastManager()

    @Published var currentToast: ToastItem?

    private var dismissTask: Task<Void, Never>?

    func show(_ style: ToastStyle, message: String, duration: TimeInterval = 2.5) {
        dismissTask?.cancel()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            currentToast = ToastItem(style: style, message: message, duration: duration)
        }
        dismissTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.25)) {
                currentToast = nil
            }
        }
    }

    func dismiss() {
        dismissTask?.cancel()
        withAnimation(.easeOut(duration: 0.25)) {
            currentToast = nil
        }
    }
}

struct ToastModifier: ViewModifier {
    @ObservedObject private var manager = ToastManager.shared

    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            if let toast = manager.currentToast {
                ToastView(item: toast)
                    .padding(.top, 56)
                    .padding(.horizontal, 20)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(999)
            }
        }
    }
}

extension View {
    func toast() -> some View {
        modifier(ToastModifier())
    }
}
