import SwiftUI

struct FaqListScreen: View {
    @StateObject private var vm = FaqListViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Help Center")
                            .font(.displaySmall)
                            .foregroundColor(DesignTokens.expoBlack)

                        Text("Find answers to common questions")
                            .font(.bodyLarge)
                            .foregroundColor(DesignTokens.slateGray)
                    }
                    .padding(.top, 8)

                    // Search
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(DesignTokens.slateGray)
                        TextField("Search FAQs...", text: $vm.keyword)
                            .font(.bodyLarge)
                            .onSubmit {
                                Task { await vm.search(keyword: vm.keyword) }
                            }
                    }
                    .padding(16)
                    .background(DesignTokens.pureWhite)
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.inputRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.inputRadius)
                            .stroke(DesignTokens.inputBorder, lineWidth: 1)
                    )

                    // Category chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(vm.filteredCategories) { cat in
                                StatusChip(
                                    cat.name,
                                    isSelected: (cat.id == "__all__" ? nil : cat.id) == vm.selectedCategoryId
                                ) {
                                    Task { await vm.filterByCategory(categoryId: cat.id) }
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }

                    // FAQ list
                    switch vm.status {
                    case .initial:
                        EmptyView()
                    case .loading:
                        ProgressView()
                            .padding(.top, 40)
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
                            LazyVStack(spacing: 12) {
                                ForEach(vm.items) { faq in
                                    NavigationLink(destination: FaqDetailScreen(faqId: faq.id)) {
                                        SurfaceCard(padding: 16) {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 6) {
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
                .padding(16)
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
