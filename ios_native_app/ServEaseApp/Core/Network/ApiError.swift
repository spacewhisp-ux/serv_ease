import Foundation

enum ApiError: LocalizedError {
    case networkError(String)
    case serverError(code: String?, message: String, statusCode: Int?)
    case unauthorized
    case decodingError(String)
    case timeout
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .networkError(let msg):     return msg
        case .serverError(_, let msg, _): return msg
        case .unauthorized:              return "Session expired"
        case .decodingError(let detail): return "Data format error: \(detail)"
        case .timeout:                   return "Request timed out"
        case .invalidResponse:           return "Invalid response format"
        }
    }
}

struct ApiException: Error, LocalizedError {
    let message: String
    let code: String?
    let statusCode: Int?

    init(_ message: String, code: String? = nil, statusCode: Int? = nil) {
        self.message = message
        self.code = code
        self.statusCode = statusCode
    }

    var errorDescription: String? { message }
}
