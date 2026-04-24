import SwiftUI

struct FaqDetailScreen: View {
    let faqId: String
    @StateObject private var vm = FaqDetailViewModel()

    var body: some View {
        ScrollView {
            if vm.isLoading {
                ProgressView()
                    .padding(.top, 60)
            } else if let error = vm.errorMessage {
                EmptyStateCard(
                    title: "Failed to load",
                    description: LocalizedStringKey(error)
                )
                .padding(24)
            } else if let faq = vm.faq {
                VStack(alignment: .leading, spacing: 20) {
                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(faq.question)
                                .font(.headlineMedium)
                                .foregroundColor(DesignTokens.expoBlack)

                            Text(faq.answer)
                                .font(.bodyLarge)
                                .foregroundColor(DesignTokens.nearBlack)
                                .lineSpacing(4)
                        }
                    }

                    if !faq.keywords.isEmpty {
                        SurfaceCard(padding: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Related topics")
                                    .font(.bodyMedium)
                                    .foregroundColor(DesignTokens.slateGray)

                                FlowLayout(spacing: 8) {
                                    ForEach(faq.keywords, id: \.self) { kw in
                                        TagBadge(label: kw)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(16)
            }
        }
        .background(DesignTokens.cloudGray)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await vm.load(faqId: faqId)
        }
    }
}

// Simple flow layout for tags
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        let maxWidth = proposal.width ?? .infinity
        var origin = CGPoint.zero
        var rowHeight: CGFloat = 0
        var frames: [CGRect] = []

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if origin.x + size.width > maxWidth, origin.x > 0 {
                origin.x = 0
                origin.y += rowHeight + spacing
                rowHeight = 0
            }
            frames.append(CGRect(origin: origin, size: size))
            origin.x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }

        let totalHeight = origin.y + rowHeight
        return (CGSize(width: maxWidth, height: totalHeight), frames)
    }
}
