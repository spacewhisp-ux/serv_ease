import SwiftUI

enum BottomSheetDetent {
    case medium
    case large
    case custom(CGFloat)

    @available(iOS 16.0, *)
    var presentationDetent: PresentationDetent {
        switch self {
        case .medium: return .medium
        case .large: return .large
        case .custom(let height): return .height(height)
        }
    }
}

struct BottomSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let detents: [BottomSheetDetent]
    let showGrabIndicator: Bool
    let sheetContent: SheetContent

    init(
        isPresented: Binding<Bool>,
        detents: [BottomSheetDetent] = [.medium, .large],
        showGrabIndicator: Bool = true,
        @ViewBuilder content: () -> SheetContent
    ) {
        self._isPresented = isPresented
        self.detents = detents
        self.showGrabIndicator = showGrabIndicator
        self.sheetContent = content()
    }

    func body(content: Content) -> some View {
        content.sheet(isPresented: $isPresented) {
            VStack(spacing: 0) {
                if showGrabIndicator {
                    grabIndicator
                }
                sheetContent
            }
            .presentationDetents(
                Set(detents.map { $0.presentationDetent })
            )
            .presentationDragIndicator(showGrabIndicator ? .hidden : .hidden)
            .presentationBackground(.regularMaterial)
            .presentationCornerRadius(20)
        }
    }

    private var grabIndicator: some View {
        Capsule()
            .fill(AppPalette.divider)
            .frame(width: 36, height: 5)
            .padding(.top, 8)
            .padding(.bottom, 4)
    }
}

struct ActionSheetItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let isDestructive: Bool
    let action: () -> Void

    init(title: String, icon: String, isDestructive: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isDestructive = isDestructive
        self.action = action
    }
}

struct ActionBottomSheet: View {
    let title: String
    let items: [ActionSheetItem]
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(AppFont.headline)
                .foregroundStyle(AppPalette.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

            ForEach(items) { item in
                Button {
                    item.action()
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: item.icon)
                            .font(.system(size: 18))
                            .foregroundStyle(item.isDestructive ? AppPalette.primary : AppPalette.textSecondary)
                            .frame(width: 24)

                        Text(item.title)
                            .font(AppFont.body)
                            .foregroundStyle(item.isDestructive ? AppPalette.primary : AppPalette.textPrimary)

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            Divider()
                .padding(.vertical, 8)

            Button {
                onCancel()
            } label: {
                Text("取消")
                    .font(AppFont.body.weight(.semibold))
                    .foregroundStyle(AppPalette.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 8)
        }
    }
}

extension View {
    func bottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        detents: [BottomSheetDetent] = [.medium, .large],
        showGrabIndicator: Bool = true,
        @ViewBuilder content: () -> Content
    ) -> some View {
        modifier(BottomSheetModifier(
            isPresented: isPresented,
            detents: detents,
            showGrabIndicator: showGrabIndicator,
            content: content
        ))
    }

    func actionSheet(
        isPresented: Binding<Bool>,
        title: String,
        items: [ActionSheetItem]
    ) -> some View {
        bottomSheet(isPresented: isPresented, detents: [.custom(CGFloat(items.count) * 52 + 160)]) {
            ActionBottomSheet(title: title, items: items, onCancel: { isPresented.wrappedValue = false })
        }
    }
}
