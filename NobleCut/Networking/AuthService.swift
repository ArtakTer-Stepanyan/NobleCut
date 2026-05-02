//
//  AuthService.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 02.05.26.
//

import Foundation

struct AuthTokenResponse: Decodable {
    let jwt: String
}

protocol AuthServiceProtocol {
    func login(username: String, password: String) async throws -> AuthTokenResponse
    func registerCustomer(fullName: String, username: String, password: String) async throws -> AuthTokenResponse
}

final class AuthService: AuthServiceProtocol {
    private struct LoginRequest: Encodable {
        let userName: String
        let password: String

        enum CodingKeys: String, CodingKey {
            case userName = "UserName"
            case password = "Password"
        }
    }

    private struct RegisterRequest: Encodable {
        let fullName: String
        let userName: String
        let password: String

        enum CodingKeys: String, CodingKey {
            case fullName = "FullName"
            case userName = "UserName"
            case password = "Password"
        }
    }

    static let defaultBaseURL = URLConfiguration.resolvedURL(
        infoDictionaryKey: "NOBLECUT_AUTH_BASE_URL",
        environmentKey: "NOBLECUT_AUTH_BASE_URL",
        fallbackURLString: "http://localhost:5141/api/Auth"
    )

    private let httpClient: HTTPClient

    init(httpClient: HTTPClient = HTTPClient(baseURL: AuthService.defaultBaseURL)) {
        self.httpClient = httpClient
    }

    func login(username: String, password: String) async throws -> AuthTokenResponse {
        try await performRequest {
            try await httpClient.post(
                path: "login",
                body: LoginRequest(userName: username, password: password)
            )
        }
    }

    func registerCustomer(
        fullName: String,
        username: String,
        password: String
    ) async throws -> AuthTokenResponse {
        try await performRequest {
            try await httpClient.post(
                path: "register/customer",
                body: RegisterRequest(fullName: fullName, userName: username, password: password)
            )
        }
    }

    private func performRequest<Payload>(
        _ operation: () async throws -> Payload
    ) async throws -> Payload {
        do {
            return try await operation()
        } catch let error as HTTPClientError {
            throw map(error)
        }
    }

    private func map(_ error: HTTPClientError) -> AuthRepositoryError {
        switch error {
        case .missingSession:
            return .server("Authentication requires an active session.")
        case .invalidResponse:
            return .invalidServerResponse
        case .transport(let message):
            return .transport(message)
        case .server(let statusCode, let message):
            if statusCode == 404 {
                return .invalidCredentials
            }

            if let message = message?.trimmedNilIfBlank {
                if message.localizedCaseInsensitiveContains("already") {
                    return .userAlreadyExists
                }

                return .server(message)
            }

            return .server("Authentication failed with status code \(statusCode).")
        }
    }
}

private extension String {
    var trimmedNilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
