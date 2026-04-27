import SwiftUI

struct CreateTicketView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CreateTicketViewModel
    let onCreated: () -> Void

    init(repository: TicketRepository, onCreated: @escaping () -> Void) {
        self.onCreated = onCreated
        _viewModel = StateObject(wrappedValue: CreateTicketViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                SurfaceCard {
                    TextField("问题标题", text: $viewModel.subject)
                        .textFieldStyle(.roundedBorder)
                    TextField("问题分类", text: $viewModel.category)
                        .textFieldStyle(.roundedBorder)
                    TextEditor(text: $viewModel.detail)
                        .frame(minHeight: 160)
                        .padding(8)
                        .background(AppPalette.background)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }

                    Button(viewModel.isSubmitting ? "提交中…" : "创建工单") {
                        Task { await viewModel.submit() }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(viewModel.isSubmitting)
                }
                .padding(20)
            }
            .background(AppPalette.background.ignoresSafeArea())
            .navigationTitle("新建工单")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
            }
        }
        .onChange(of: viewModel.didCreateTicket) { _, didCreate in
            guard didCreate else { return }
            onCreated()
            dismiss()
        }
    }
}
