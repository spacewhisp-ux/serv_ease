import SwiftUI

struct SecurityMaintenanceCard: View {
    var body: some View {
        SurfaceCard {
            Text("安全维护")
                .font(.headline)
                .foregroundStyle(AppPalette.textPrimary)
            Text("为账号风险识别、服务状态通知和人工支持流程预留统一入口。")
                .font(.subheadline)
                .foregroundStyle(AppPalette.textSecondary)
            HStack(spacing: 12) {
                Label("风险查询", systemImage: "shield.lefthalf.filled")
                Label("帮助中心", systemImage: "book")
                Label("提交工单", systemImage: "ticket")
            }
            .font(.footnote.weight(.medium))
            .foregroundStyle(AppPalette.primary)
        }
    }
}
