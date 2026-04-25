import SwiftUI

struct FaqListScreen: View {
    @StateObject private var vm = FaqListViewModel()

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let sectionSpacing = DesignTokens.DeviceAdaptation.sectionSpacing(for: geometry.size.height)
                let cardSpacing = DesignTokens.DeviceAdaptation.cardSpacing(for: geometry.size.height)

                ScrollView {
                    VStack(spacing: sectionSpacing) {
                        VStack(spacing: DesignTokens.Spacing.sm) {
                            Text("Help Center")
                                .font(.displaySmall)
                                .foregroundColor(DesignTokens.expoBlack)

                            Text("Find answers to common questions")
                                .font(.bodyLarge)
                                .foregroundColor(DesignTokens.slateGray)
                        }
                        .padding(.top, DesignTokens.Spacing.sm)

                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(DesignTokens.slateGray)
                            TextField("Search FAQs...", text: $vm.keyword)
                                .font(.bodyLarge)
                                .onSubmit {
                                    Task { await vm.search(keyword: vm.keyword) }
                                }
                        }
                        .padding(DesignTokens.Spacing.lg)
                        .background(DesignTokens.pureWhite)
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.inputRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.inputRadius)
                                .stroke(DesignTokens.inputBorder, lineWidth: 1)
                        )

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: DesignTokens.Spacing.sm) {
                                ForEach(vm.filteredCategories) { cat in
                                    StatusChip(
                                        cat.name,
                                        isSelected: (cat.id == "__all__" ? nil : cat.id) == vm.selectedCategoryId
                                    ) {
                                        Task { await vm.filterByCategory(categoryId: cat.id) }
                                    }
                                }
                            }
                            .padding(.horizontal, DesignTokens.Spacing.xs)
                        }

                        switch vm.status {
                        case .initial:
                            EmptyView()
                        case .loading:
                            ProgressView()
                                .padding(.top, DesignTokens.Spacing.xxl)
                        case .failure:
                            EmptyStateCard(
                                title: "Failed to load",
                                description: LocalizedStringKey(vm.errorMessage ?? "Please try again")
                            )
                        case .success:
                            if vm.items.isEmpty {
                                EmptyStateCard(
                                    title: "No results",
                                    description: "Try a different search term or category"
                                )
                            } else {
                                LazyVStack(spacing: cardSpacing) {
                                    ForEach(vm.items) { faq in
                                        NavigationLink(destination: FaqDetailScreen(faqId: faq.id)) {
                                            SurfaceCard(padding: DesignTokens.Spacing.lg) {
                                                HStack {
                                                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                                                        Text(faq.question)
                                                            .font(.titleLarge)
                                                            .foregroundColor(DesignTokens.nearBlack)
                                                            .lineLimit(2)

                                                        Text(faq.answerPreview)
                                                            .font(.bodyMedium)
                                                            .foregroundColor(DesignTokens.slateGray)
                                                            .lineLimit(3)
                                                    }

                                                    Spacer()

                                                    Image(systemName: "chevron.right")
                                                        .font(.caption)
                                                        .foregroundColor(DesignTokens.silver)
                                                }
                                            }
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                    .padding(DesignTokens.Spacing.lg)
                }
                .background(DesignTokens.cloudGray)
                .refreshable {
                    await vm.load()
                }
                .task {
                    await vm.load()
                }
            }
        }
    }
}
