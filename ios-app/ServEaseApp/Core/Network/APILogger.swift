import Foundation
import OSLog

#if DEBUG
    struct APILogger {
        private static let logger = Logger(subsystem: "com.alanyu.servease", category: "API")

        static func logRequest(_ request: URLRequest, body: Data?) {
            guard DebugSettings.networkLoggingEnabled else { return }

            let method = request.httpMethod ?? "UNKNOWN"
            let url = request.url?.absoluteString ?? "no-url"
            let headers = request.allHTTPHeaderFields?.map { "  \($0.key): \($0.value)" }.joined(separator: "\n") ?? "  none"

            var log = """
            ┌──────────────────────────────────────────────
            │ ➤ REQUEST: \(method) \(url)
            │ HEADERS:
            \(headers)
            """

            if DebugSettings.curlExportEnabled {
                let curl = curlCommand(from: request, body: body)
                log += "\n│ CURL:\n│   \(curl)"
            }

            if let body, let bodyString = String(data: body, encoding: .utf8) {
                log += "\n│ BODY:\n│   \(bodyString)"
            }

            log += "\n└──────────────────────────────────────────────"
            logger.info("\(log)")
        }

        static func logResponse(_ response: URLResponse, data: Data?, duration: TimeInterval) {
            guard DebugSettings.networkLoggingEnabled else { return }

            let httpResponse = response as? HTTPURLResponse
            let statusCode = httpResponse?.statusCode ?? 0
            let url = response.url?.absoluteString ?? "no-url"
            let headers = httpResponse?.allHeaderFields.map { "  \($0.key): \($0.value)" }.joined(separator: "\n") ?? "  none"

            var log = """
            ┌──────────────────────────────────────────────
            │ ➤ RESPONSE: \(statusCode) \(url)
            │ DURATION: \(String(format: "%.0f", duration * 1000))ms
            │ HEADERS:
            \(headers)
            """

            if let data, let bodyString = String(data: data, encoding: .utf8) {
                let truncated = bodyString.count > 2000 ? String(bodyString.prefix(2000)) + "… (truncated)" : bodyString
                log += "\n│ BODY:\n│   \(truncated)"
            }

            let emoji = (200...299).contains(statusCode) ? "✅" : "❌"
            log += "\n│ RESULT: \(emoji)"
            log += "\n└──────────────────────────────────────────────"
            logger.info("\(log)")
        }

        private static func curlCommand(from request: URLRequest, body: Data?) -> String {
            var parts = ["curl"]
            if let method = request.httpMethod, method != "GET" {
                parts.append("-X \(method)")
            }
            if let headers = request.allHTTPHeaderFields {
                for (key, value) in headers {
                    parts.append("-H '\(key): \(value)'")
                }
            }
            if let body, let bodyString = String(data: body, encoding: .utf8) {
                parts.append("-d '\(bodyString)'")
            }
            parts.append("'\(request.url?.absoluteString ?? "")'")
            return parts.joined(separator: " \\\n     ")
        }
    }
#endif
