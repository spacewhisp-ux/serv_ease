import Foundation

actor AccountCheckRepository {
    func checkAccount(identifier: String) async throws -> AccountCheckResult {
        try await Task.sleep(for: .milliseconds(600))

        let trimmed = identifier.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return AccountCheckResult(summary: "请输入账号或标识后再查询。", riskLevel: "未查询")
        }

        return AccountCheckResult(
            summary: "已为 \(trimmed) 预留恶意账号查询能力，后续可接入正式风控接口。",
            riskLevel: "占位结果"
        )
    }
}
