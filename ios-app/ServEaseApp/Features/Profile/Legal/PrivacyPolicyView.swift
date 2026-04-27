import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            SurfaceCard {
                Text("隐私政策")
                    .font(.title3.weight(.semibold))
                Text("首版先预留隐私政策页面入口，后续替换为正式合规文案。")
                    .foregroundStyle(AppPalette.textSecondary)
            }
            .padding(20)
        }
        .background(AppPalette.background.ignoresSafeArea())
        .navigationTitle("隐私政策")
    }
}
