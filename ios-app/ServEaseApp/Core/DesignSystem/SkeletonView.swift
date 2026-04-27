import SwiftUI

struct SkeletonShape: View {
    let cornerRadius: CGFloat
    let height: CGFloat

    init(cornerRadius: CGFloat = 8, height: CGFloat = 16) {
        self.cornerRadius = cornerRadius
        self.height = height
    }

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color.gray.opacity(0.15))
            .frame(height: height)
            .shimmer()
    }
}

struct SkeletonCircle: View {
    let size: CGFloat

    init(size: CGFloat = 44) {
        self.size = size
    }

    var body: some View {
        Circle()
            .fill(Color.gray.opacity(0.15))
            .frame(width: size, height: size)
            .shimmer()
    }
}

struct SkeletonCard<Content: View>: View {
    @ViewBuilder let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppPalette.card)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppPalette.divider, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 8)
    }
}

struct BannerSkeletonView: View {
    var body: some View {
        SkeletonCard {
            SkeletonShape(cornerRadius: 6, height: 32)
            SkeletonShape(height: 14)
            SkeletonShape(height: 14)
                .padding(.trailing, 60)
            SkeletonShape(cornerRadius: 24, height: 52)
                .frame(maxWidth: 220)
        }
    }
}

struct QuickActionSkeletonView: View {
    var body: some View {
        SkeletonCard {
            SkeletonShape(height: 14)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(0..<4, id: \.self) { _ in
                    VStack(alignment: .leading, spacing: 12) {
                        SkeletonCircle(size: 28)
                        SkeletonShape(height: 14)
                            .frame(maxWidth: 60)
                    }
                    .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
                    .padding(16)
                    .background(Color.gray.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                }
            }
        }
    }
}

struct FaqListSkeletonView: View {
    let count: Int

    init(count: Int = 3) {
        self.count = count
    }

    var body: some View {
        SkeletonCard {
            SkeletonShape(height: 14)
            ForEach(0..<count, id: \.self) { _ in
                VStack(alignment: .leading, spacing: 8) {
                    SkeletonShape(height: 16)
                    SkeletonShape(height: 12)
                        .padding(.trailing, 80)
                }
                if count > 1 { Divider() }
            }
        }
    }
}

struct TicketListSkeletonView: View {
    let count: Int

    init(count: Int = 3) {
        self.count = count
    }

    var body: some View {
        ForEach(0..<count, id: \.self) { _ in
            SkeletonCard {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        SkeletonShape(height: 16)
                        SkeletonShape(cornerRadius: 4, height: 12)
                            .frame(maxWidth: 100)
                    }
                    Spacer()
                    SkeletonShape(cornerRadius: 12, height: 28)
                        .frame(width: 64)
                }
                HStack {
                    SkeletonShape(cornerRadius: 4, height: 12)
                        .frame(maxWidth: 60)
                    Spacer()
                    SkeletonShape(cornerRadius: 4, height: 12)
                        .frame(maxWidth: 80)
                }
            }
        }
    }
}

struct ProfileSkeletonView: View {
    var body: some View {
        SkeletonCard {
            HStack(spacing: 16) {
                SkeletonCircle(size: 54)
                VStack(alignment: .leading, spacing: 8) {
                    SkeletonShape(height: 20)
                        .frame(maxWidth: 120)
                    SkeletonShape(height: 14)
                        .frame(maxWidth: 180)
                }
            }
        }
    }
}

struct HomeSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            BannerSkeletonView()
            SkeletonCard {
                SkeletonShape(height: 14)
                SkeletonShape(cornerRadius: 4, height: 12)
            }
            QuickActionSkeletonView()
            FaqListSkeletonView()
            SkeletonCard {
                SkeletonShape(height: 16)
                SkeletonShape(height: 12)
                    .padding(.trailing, 100)
            }
        }
        .padding(20)
    }
}
