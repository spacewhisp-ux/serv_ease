import Foundation

enum APIError: LocalizedError, Equatable {
    case invalidResponse
    case http(statusCode: Int, message: String?)
    case decodingFailed
    case missingRefreshToken

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "服务器响应无效"
        case let .http(statusCode, message):
            return message ?? "请求失败（\(statusCode)）"
        case .decodingFailed:
            return "数据解析失败"
        case .missingRefreshToken:
            return "缺少刷新令牌"
        }
    }
}

struct EmptyResponse: Decodable {}

private struct APIResponseEnvelope<T: Decodable>: Decodable {
    let success: Bool
    let data: T
    let message: String
}

private struct APIErrorEnvelope: Decodable {
    let message: String?
    let error: ErrorDetail?

    struct ErrorDetail: Decodable {
        let message: String?
        let error: String?
        let statusCode: Int?
    }
}

actor APIClient {
    private let config: EnvironmentConfig
    private let tokenStore: TokenStore
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    private let session: URLSession

    init(
        config: EnvironmentConfig = .current,
        tokenStore: TokenStore,
        session: URLSession = .shared
    ) {
        self.config = config
        self.tokenStore = tokenStore
        self.session = session
        self.jsonDecoder = JSONDecoder()
        self.jsonEncoder = JSONEncoder()
    }

    func get<Response: Decodable>(_ path: String, requiresAuth: Bool = false) async throws -> Response {
        try await requestWithoutBody(path: path, method: "GET", requiresAuth: requiresAuth)
    }

    func post<Body: Encodable, Response: Decodable>(
        _ path: String,
        body: Body,
        requiresAuth: Bool = false
    ) async throws -> Response {
        try await request(path: path, method: "POST", body: body, requiresAuth: requiresAuth)
    }

    func patch<Body: Encodable, Response: Decodable>(
        _ path: String,
        body: Body,
        requiresAuth: Bool = false
    ) async throws -> Response {
        try await request(path: path, method: "PATCH", body: body, requiresAuth: requiresAuth)
    }

    func delete<Body: Encodable, Response: Decodable>(
        _ path: String,
        body: Body,
        requiresAuth: Bool = false
    ) async throws -> Response {
        try await request(path: path, method: "DELETE", body: body, requiresAuth: requiresAuth)
    }

    private func requestWithoutBody<Response: Decodable>(
        path: String,
        method: String,
        requiresAuth: Bool,
        hasRetried: Bool = false
    ) async throws -> Response {
        let request = try makeRequest(path: path, method: method, bodyData: nil, requiresAuth: requiresAuth)
        return try await perform(request: request, requiresAuth: requiresAuth, retryInfo: (path, method, nil, hasRetried))
    }

    private func request<Body: Encodable, Response: Decodable>(
        path: String,
        method: String,
        body: Body,
        requiresAuth: Bool,
        hasRetried: Bool = false
    ) async throws -> Response {
        let bodyData = try jsonEncoder.encode(body)
        let request = try makeRequest(path: path, method: method, bodyData: bodyData, requiresAuth: requiresAuth)
        return try await perform(request: request, requiresAuth: requiresAuth, retryInfo: (path, method, bodyData, hasRetried))
    }

    private func perform<Response: Decodable>(
        request: URLRequest,
        requiresAuth: Bool,
        retryInfo: (path: String, method: String, bodyData: Data?, hasRetried: Bool)
    ) async throws -> Response {
        let startTime = Date()
        #if DEBUG
            APILogger.logRequest(request, body: retryInfo.bodyData)
        #endif

        let (data, response) = try await session.data(for: request)

        let duration = Date().timeIntervalSince(startTime)
        #if DEBUG
            APILogger.logResponse(response, data: data, duration: duration)
        #endif

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if httpResponse.statusCode == 401, requiresAuth, !retryInfo.hasRetried {
            try await refreshTokens()
            let retryRequest = try makeRequest(
                path: retryInfo.path,
                method: retryInfo.method,
                bodyData: retryInfo.bodyData,
                requiresAuth: requiresAuth
            )
            return try await perform(request: retryRequest, requiresAuth: requiresAuth, retryInfo: (retryInfo.path, retryInfo.method, retryInfo.bodyData, true))
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw APIError.http(statusCode: httpResponse.statusCode, message: decodeMessage(from: data))
        }

        do {
            let envelope = try jsonDecoder.decode(APIResponseEnvelope<Response>.self, from: data)
            return envelope.data
        } catch {
            throw APIError.decodingFailed
        }
    }

    private func makeRequest(
        path: String,
        method: String,
        bodyData: Data?,
        requiresAuth: Bool
    ) throws -> URLRequest {
        let trimmedPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        guard let url = URL(string: "\(config.apiBaseURL.absoluteString)/\(trimmedPath)") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if requiresAuth, let accessToken = tokenStore.accessToken() {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        if let bodyData {
            request.httpBody = bodyData
        }

        return request
    }

    private func refreshTokens() async throws {
        guard let refreshToken = tokenStore.refreshToken() else {
            throw APIError.missingRefreshToken
        }

        let refreshRequest = RefreshTokenRequest(refreshToken: refreshToken)
        let tokens: AuthTokens = try await request(
            path: "auth/refresh",
            method: "POST",
            body: refreshRequest,
            requiresAuth: false,
            hasRetried: true
        )

        try tokenStore.save(tokens: tokens)
    }

    private func decodeMessage(from data: Data) -> String? {
        if let envelope = try? jsonDecoder.decode(APIErrorEnvelope.self, from: data) {
            return envelope.error?.message ?? envelope.error?.error ?? envelope.message
        }
        return String(data: data, encoding: .utf8)
    }
}
