import SwiftUI

#if DEBUG
    struct APIDebugView: View {
        @StateObject private var viewModel: APIDebugViewModel
        @Environment(\.dismiss) private var dismiss

        init(appContext: AppContext) {
            _viewModel = StateObject(wrappedValue: APIDebugViewModel(appContext: appContext))
        }

        var body: some View {
            List {
                authSection
                endpointsSection
            }
            .navigationTitle("API 调试")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        if viewModel.isRunningAll {
                            Button("停止") { viewModel.stop() }
                                .foregroundStyle(.red)
                        }
                        Button(viewModel.isRunningAll ? "测试中…" : "测试全部") {
                            Task { await viewModel.runAll() }
                        }
                        .disabled(viewModel.isRunningAll)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("重置") { viewModel.resetAll() }
                }
            }
            .overlay(alignment: .bottom) {
                if let summary = viewModel.testingSummary {
                    Text(summary)
                        .font(.system(size: 14, weight: .medium))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .padding(.bottom, 8)
                }
            }
        }

        private var authSection: some View {
            Section {
                HStack {
                    Text("+86")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                    TextField("手机号", text: $viewModel.authPhone)
                        .keyboardType(.phonePad)
                        .font(.system(size: 15))
                }

                HStack {
                    Text("密码")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .leading)
                    SecureField("输入密码", text: $viewModel.authPassword)
                        .font(.system(size: 15))
                }

                HStack {
                    Text("昵称")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .leading)
                    TextField("注册用昵称", text: $viewModel.authDisplayName)
                        .font(.system(size: 15))
                }

                HStack {
                    Text("已登录")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Circle()
                        .fill(viewModel.isLoggedIn ? Color.green : Color(.systemGray4))
                        .frame(width: 10, height: 10)
                    Text(viewModel.isLoggedIn ? "是" : "否")
                        .font(.system(size: 15))
                        .foregroundStyle(viewModel.isLoggedIn ? Color.green : .secondary)
                }

                Button {
                    Task { await viewModel.login() }
                } label: {
                    Label("先登录（获取Token）", systemImage: "key.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            } header: {
                Text("认证信息")
            }
        }

        private var endpointsSection: some View {
            ForEach(APIDebugViewModel.EndpointCategory.allCases) { category in
                let categoryEndpoints = viewModel.endpoints.filter { $0.category == category }
                if !categoryEndpoints.isEmpty {
                    Section(category.rawValue) {
                        ForEach(Array(categoryEndpoints.enumerated()), id: \.element.id) { _, endpoint in
                            EndpointRow(endpoint: endpoint) {
                                if let idx = viewModel.endpoints.firstIndex(where: { $0.id == endpoint.id }) {
                                    Task { await viewModel.runSingle(index: idx) }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private struct EndpointRow: View {
        let endpoint: APIDebugViewModel.Endpoint
        let onTap: () -> Void

        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    methodBadge(endpoint.method)
                    Text(endpoint.name)
                        .font(.system(size: 15, weight: .medium))
                    Spacer()
                    if endpoint.requiresAuth {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.orange)
                    }
                    Button {
                        onTap()
                    } label: {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.blue)
                    }
                    .buttonStyle(.plain)
                }

                Text(endpoint.path)
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundStyle(.secondary)

                stateView
            }
            .padding(.vertical, 4)
        }

        private func methodBadge(_ method: String) -> some View {
            Text(method)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(methodColor(method))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(methodColor(method).opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        }

        private func methodColor(_ method: String) -> Color {
            switch method {
            case "GET": return .green
            case "POST": return .blue
            case "PATCH": return .orange
            case "DELETE": return .red
            default: return .gray
            }
        }

        @ViewBuilder
        private var stateView: some View {
            switch endpoint.state {
            case .pending:
                EmptyView()
            case .running:
                HStack(spacing: 6) {
                    ProgressView().scaleEffect(0.7)
                    Text("请求中…")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            case let .success(data):
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.green)
                    Text(data)
                        .font(.system(size: 12))
                        .foregroundStyle(.green)
                    if let duration = endpoint.duration {
                        Text("(\(String(format: "%.0f", duration * 1000))ms)")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                }
            case let .failure(status, error):
                HStack(spacing: 6) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.red)
                    Text("[\(status)] \(error)")
                        .font(.system(size: 12))
                        .foregroundStyle(.red)
                        .lineLimit(2)
                    if let duration = endpoint.duration {
                        Text("(\(String(format: "%.0f", duration * 1000))ms)")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
#endif
