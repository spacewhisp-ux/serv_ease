import Foundation

actor ApiClient {
    static let shared = ApiClient()

    private let baseURL = "http://47.82.121.213:3001/v1/"
    private let session: URLSession
    private var accessToken: String?
    private var refreshTask: Task<Void, Error>?

    private let publicPaths: Set<String> = [
        "auth/login",
        "auth/register",
        "auth/refresh",
    ]

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 25
        config.timeoutIntervalForResource = 25
        self.session = URLSession(configuration: config)
    }

    // MARK: - Public methods

    func setAccessToken(_ token: String?) {
        accessToken = token
    }

    func clearSession() {
        accessToken = nil
        try? KeychainManager.shared.clearTokens()
    }

    func get<T: Decodable>(_ path: String, queryItems: [URLQueryItem]? = nil) async throws -> T {
        try await send("GET", path, body: nil as EmptyBody?, queryItems: queryItems, retried: false)
    }

    func post<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T {
        try await send("POST", path, body: body, queryItems: nil, retried: false)
    }

    func patch<T: Decodable, B: Encodable>(_ path: String, body: B? = nil) async throws -> T {
        try await send("PATCH", path, body: body, queryItems: nil, retried: false)
    }

    func delete<T: Decodable>(_ path: String) async throws -> T {
        try await send("DELETE", path, body: nil as EmptyBody?, queryItems: nil, retried: false)
    }

    // MARK: - Internal

    private func send<T: Decodable, B: Encodable>(
        _ method: String,
        _ path: String,
        body: B?,
        queryItems: [URLQueryItem]?,
        retried: Bool
    ) async throws -> T {
        let normalizedPath = path.hasPrefix("/") ? String(path.dropFirst()) : path

        guard var components = URLComponents(string: baseURL + normalizedPath) else {
            throw ApiError.invalidResponse
        }

        if let queryItems, !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw ApiError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if !publicPaths.contains(normalizedPath) {
            let token = try await resolveAccessToken()
            if let token, !token.isEmpty {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }

        if let body, !(body is EmptyBody) {
            request.httpBody = try encoder.encode(body)
        }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError where error.code == .timedOut {
            throw ApiError.timeout
        } catch {
            throw ApiError.networkError(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiError.invalidResponse
        }

        // 401 → auto refresh
        if httpResponse.statusCode == 401,
           !publicPaths.contains(normalizedPath),
           !retried {
            do {
                try await refreshSession()
                return try await send(method, path, body: body, queryItems: queryItems, retried: true)
            } catch {
                await clearSessionAfterFailedRefresh()
                throw ApiError.unauthorized
            }
        }

        // Decode envelope
        let rawJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any]

        if httpResponse.statusCode >= 400 {
            let errorMsg: String
            let errorCode: String?
            if let errorBody = rawJSON?["error"] as? [String: Any] {
                errorMsg = (errorBody["message"] as? String) ?? "Request failed"
                errorCode = errorBody["code"] as? String
            } else {
                errorMsg = "Request failed"
                errorCode = nil
            }
            throw ApiError.serverError(code: errorCode, message: errorMsg, statusCode: httpResponse.statusCode)
        }

        // Unwrap envelope: { success, data, error }
        if let envelope = rawJSON {
            if let success = envelope["success"] as? Bool, success == false {
                let err = envelope["error"] as? [String: Any]
                throw ApiException(
                    (err?["message"] as? String) ?? "Request failed",
                    code: err?["code"] as? String,
                    statusCode: httpResponse.statusCode
                )
            }

            if let dataField = envelope["data"] {
                let dataFieldData = try JSONSerialization.data(withJSONObject: dataField)
                return try decoder.decode(T.self, from: dataFieldData)
            }
        }

        // Fallback: try decoding entire response as T
        return try decoder.decode(T.self, from: data)
    }

    // MARK: - Token refresh

    private func resolveAccessToken() async throws -> String? {
        if let token = accessToken { return token }
        let saved = try KeychainManager.shared.readAccessToken()
        if let saved { accessToken = saved }
        return saved
    }

    private func refreshSession() async throws {
        if let existing = refreshTask {
            return try await existing.value
        }

        let task = Task<Void, Error> {
            defer { refreshTask = nil }

            guard let refreshToken = try KeychainManager.shared.readRefreshToken() else {
                throw ApiError.unauthorized
            }

            let body = RefreshRequest(refreshToken: refreshToken)
            let result: AuthResponse = try await send(
                "POST", "auth/refresh",
                body: body,
                queryItems: nil,
                retried: true
            )

            accessToken = result.accessToken
            try KeychainManager.shared.saveAccessToken(result.accessToken)
            try KeychainManager.shared.saveRefreshToken(result.refreshToken)
        }

        refreshTask = task
        return try await task.value
    }

    private func clearSessionAfterFailedRefresh() async {
        accessToken = nil
        try? KeychainManager.shared.clearTokens()
    }
}

private struct EmptyBody: Codable {}
