import SwiftUI

struct UserAgreementView: View {
    var body: some View {
        ScrollView {
            SurfaceCard {
                Text("用户协议")
                    .font(.title3.weight(.semibold))
                Text("首版先预留用户协议页面入口，后续替换为正式服务条款。")
                    .foregroundStyle(AppPalette.textSecondary)
            }
            .padding(20)
        }
        .background(AppPalette.background.ignoresSafeArea())
        .navigationTitle("用户协议")
    }
}
