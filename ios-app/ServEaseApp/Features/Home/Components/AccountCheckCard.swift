import SwiftUI

struct AccountCheckCard: View {
    @Binding var input: String
    let isLoading: Bool
    let result: AccountCheckResult?
    let errorMessage: String?
    let onSubmit: () -> Void

    var body: some View {
        SurfaceCard {
            SectionHeader(title: "恶意账号查询", subtitle: "先预留标准交互结构，后续再接真实风控逻辑")
            TextField("输入账号 / ID / 标识", text: $input)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
            Button(isLoading ? "查询中…" : "立即查询", action: onSubmit)
                .buttonStyle(PrimaryButtonStyle())
                .disabled(isLoading)

            if let result {
                SurfaceCard {
                    Text(result.riskLevel)
                        .font(.headline)
                        .foregroundStyle(AppPalette.warning)
                    Text(result.summary)
                        .font(.subheadline)
                        .foregroundStyle(AppPalette.textSecondary)
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
    }
}
