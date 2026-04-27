import SwiftUI

struct HelpCenterView: View {
    @StateObject private var viewModel: HelpCenterViewModel
    private let repository: HelpCenterRepository
    private let chatRepository: ChatRepository

    init(appContext: AppContext) {
        self.repository = appContext.helpCenterRepository
        self.chatRepository = appContext.chatRepository
        _viewModel = StateObject(wrappedValue: HelpCenterViewModel(repository: appContext.helpCenterRepository))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // Banner card for online Q&A
                    NavigationLink {
                        ChatView(repository: chatRepository)
                    } label: {
                        SurfaceCard {
                            HStack(spacing: 14) {
                                Image(systemName: "bubble.left.and.bubble.right.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(AppPalette.primary)
                                    .frame(width: 44, height: 44)
                                    .background(AppPalette.primary.opacity(0.08))
                                    .clipShape(Circle())
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("在线问答")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(AppPalette.textPrimary)
                                    Text("智能客服解答常见问题，快速获取帮助")
                                        .font(.system(size: 14))
                                        .foregroundStyle(AppPalette.textSecondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(AppPalette.textSecondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .staggeredAppear(index: 0)

                    SurfaceCard {
                        SectionHeader(title: "自助解决中心", subtitle: "先搜索，再按分类浏览，最后进入 FAQ 详情查看解决方案")
                        TextField("搜索 FAQ", text: $viewModel.keyword)
                            .textFieldStyle(.roundedBorder)
                        Button("搜索") {
                            Task { await viewModel.reload() }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .frame(maxWidth: 180)
                    }
                    .staggeredAppear(index: 1)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            Button {
                                viewModel.selectCategory(nil)
                            } label: {
                                PillTag(title: "全部", isSelected: viewModel.selectedCategoryID == nil)
                            }
                            .buttonStyle(.plain)

                            ForEach(viewModel.categories) { category in
                                Button {
                                    viewModel.selectCategory(category.id)
                                } label: {
                                    PillTag(title: category.name, isSelected: viewModel.selectedCategoryID == category.id)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.horizontal, -20)
                    .staggeredAppear(index: 2)

                    if let errorMessage = viewModel.errorMessage {
                        EmptyStateView(title: "帮助中心暂时不可用", message: errorMessage)
                            .staggeredAppear(index: 3)
                    } else if viewModel.isLoading, viewModel.faqs.isEmpty {
                        FaqListSkeletonView(count: 4)
                    } else if viewModel.faqs.isEmpty {
                        EmptyStateView(title: "暂无 FAQ", message: "首版会在这里展示分类、热门问题和 FAQ 详情入口。")
                            .staggeredAppear(index: 3)
                    } else {
                        ForEach(Array(viewModel.faqs.enumerated()), id: \.element.id) { idx, faq in
                            NavigationLink {
                                FaqDetailView(faqID: faq.id, repository: repository)
                            } label: {
                                SurfaceCard {
                                    HStack(alignment: .top, spacing: 14) {
                                        Circle()
                                            .fill(AppPalette.primary.opacity(0.08))
                                            .frame(width: 36, height: 36)
                                            .overlay(
                                                Image(systemName: "questionmark")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundStyle(AppPalette.primary)
                                            )
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(faq.question)
                                                .font(.system(size: 18, weight: .semibold))
                                                .tracking(-0.25)
                                                .foregroundStyle(AppPalette.textPrimary)
                                            Text(faq.answerPreview)
                                                .font(.system(size: 15, weight: .regular))
                                                .foregroundStyle(AppPalette.textSecondary)
                                                .lineSpacing(2)
                                        }
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .staggeredAppear(index: idx + 3, delayBase: 0.05)
                        }
                    }
                }
                .padding(20)
            }
            .appBackground()
            .navigationTitle("帮助中心")
        }
        .task {
            await viewModel.loadIfNeeded()
        }
    }
}
