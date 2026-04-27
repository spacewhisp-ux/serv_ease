import SwiftUI

struct FaqDetailView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var sessionViewModel: SessionViewModel
    @StateObject private var viewModel: FaqDetailViewModel

    init(faqID: String, repository: HelpCenterRepository) {
        _viewModel = StateObject(wrappedValue: FaqDetailViewModel(faqID: faqID, repository: repository))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if let faq = viewModel.faq {
                    SurfaceCard {
                        Text(faq.question)
                            .font(.system(size: 26, weight: .semibold))
                            .tracking(-0.5)
                            .foregroundStyle(AppPalette.textPrimary)
                        Text(faq.answer)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(AppPalette.textSecondary)
                            .lineSpacing(2)
                        if !faq.keywords.isEmpty {
                            FlowLayout(spacing: 8) {
                                ForEach(faq.keywords, id: \.self) { keyword in
                                    PillTag(title: keyword)
                                }
                            }
                        }
                    }

                    SurfaceCard {
                        SectionHeader(title: "这个 FAQ 有帮助吗？", subtitle: "你的反馈会帮助我们继续整理帮助中心内容")
                        HStack(spacing: 12) {
                            Button("已解决") {
                                viewModel.recordFeedback(isHelpful: true)
                            }
                            .buttonStyle(PrimaryButtonStyle())

                            Button("去提交工单") {
                                viewModel.recordFeedback(isHelpful: false)
                                router.selectedTab = .tickets
                                if !sessionViewModel.isAuthenticated {
                                    sessionViewModel.presentLogin(reason: .tickets)
                                }
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }
                        if let feedbackMessage = viewModel.feedbackMessage {
                            Text(feedbackMessage)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(AppPalette.textSecondary)
                        }
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    EmptyStateView(title: "FAQ 详情加载失败", message: errorMessage)
                } else {
                    LoadingStateView(title: "正在加载 FAQ 详情", message: "问题答案和关键词准备好后会显示在这里。")
                }
            }
            .padding(20)
        }
        .background(AppPalette.background.ignoresSafeArea())
        .navigationTitle("FAQ 详情")
        .task {
            await viewModel.load()
        }
    }
}

struct FlowLayout<Content: View>: View {
    let spacing: CGFloat
    let content: () -> Content

    init(spacing: CGFloat = 8, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        content()
    }
}
