//
//  AuthRepository.swift
//  NobleCut
//
//  Created by OpenAI Codex on 30.04.26.
//

import Foundation

protocol AuthRepositoryProtocol: AnyObject {
    func restoreSession() async -> AuthSession?
    func login(username: String, password: String) async throws -> AuthSession
    func register(fullName: String, username: String, password: String) async throws -> AuthSession
    func logout() async
}

final class AuthRepository: AuthRepositoryProtocol {
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

    private struct AuthTokenResponse: Decodable {
        let jwt: String
    }

    private struct APIErrorResponse: Decodable {
        let error: String?
        let message: String?
        let status: Int?

        enum CodingKeys: String, CodingKey {
            case error = "Error"
            case message
            case status = "Status"
        }
    }

    private struct JWTClaims: Decodable {
        let expiration: TimeInterval?
        let uniqueName: String?
        let uriName: String?
        let name: String?

        enum CodingKeys: String, CodingKey {
            case expiration = "exp"
            case uniqueName = "unique_name"
            case uriName = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
            case name
        }

        var resolvedUsername: String? {
            uriName?.nilIfBlank ?? uniqueName?.nilIfBlank ?? name?.nilIfBlank
        }

        var resolvedFullName: String? {
            guard let name = name?.nilIfBlank else { return nil }
            guard name != resolvedUsername else { return nil }
            return name
        }
    }

    static let defaultBaseURL = URL(
        string: ProcessInfo.processInfo.environment["NOBLECUT_AUTH_BASE_URL"]
            ?? "http://localhost:5141/api/Auth"
    )!

    private let baseURL: URL
    private let urlSession: URLSession
    private let fileManager: FileManager
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(
        baseURL: URL = AuthRepository.defaultBaseURL,
        urlSession: URLSession = .shared,
        fileManager: FileManager = .default
    ) {
        self.baseURL = baseURL
        self.urlSession = urlSession
        self.fileManager = fileManager
    }

    func restoreSession() async -> AuthSession? {
        guard let session = loadSession() else {
            return nil
        }

        guard isTokenStillValid(session.token) else {
            clearPersistedSession()
            return nil
        }

        return session
    }

    func login(username: String, password: String) async throws -> AuthSession {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedUsername.isEmpty, !trimmedPassword.isEmpty else {
            throw AuthRepositoryError.invalidCredentials
        }

        let response = try await sendRequest(
            path: "login",
            body: LoginRequest(userName: trimmedUsername, password: trimmedPassword)
        )

        let session = try makeSession(
            jwt: response.jwt,
            fallbackUsername: trimmedUsername,
            fallbackFullName: nil
        )
        try persist(session, to: sessionFileURL)
        return session
    }

    func register(fullName: String, username: String, password: String) async throws -> AuthSession {
        let trimmedFullName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedFullName.isEmpty, !trimmedUsername.isEmpty, !trimmedPassword.isEmpty else {
            throw AuthRepositoryError.invalidRegistrationData
        }

        let response = try await sendRequest(
            path: "register/customer",
            body: RegisterRequest(
                fullName: trimmedFullName,
                userName: trimmedUsername,
                password: trimmedPassword
            )
        )

        let session = try makeSession(
            jwt: response.jwt,
            fallbackUsername: trimmedUsername,
            fallbackFullName: trimmedFullName
        )
        try persist(session, to: sessionFileURL)
        return session
    }

    func logout() async {
        clearPersistedSession()
    }

    private func loadSession() -> AuthSession? {
        guard let data = try? Data(contentsOf: sessionFileURL) else {
            return nil
        }

        return try? decoder.decode(AuthSession.self, from: data)
    }

    private func persist<T: Encodable>(_ value: T, to url: URL) throws {
        let directoryURL = url.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: directoryURL.path) {
            try fileManager.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }

        let data = try encoder.encode(value)
        try data.write(to: url, options: .atomic)
    }

    private func sendRequest<Body: Encodable>(
        path: String,
        body: Body
    ) async throws -> AuthTokenResponse {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await urlSession.data(for: request)
        } catch {
            throw AuthRepositoryError.transport(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthRepositoryError.invalidServerResponse
        }

        guard (200 ..< 300).contains(httpResponse.statusCode) else {
            throw decodeAPIError(from: data, statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode(AuthTokenResponse.self, from: data)
        } catch {
            throw AuthRepositoryError.invalidServerResponse
        }
    }

    private func makeSession(
        jwt: String,
        fallbackUsername: String,
        fallbackFullName: String?
    ) throws -> AuthSession {
        guard !jwt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AuthRepositoryError.missingToken
        }

        let claims = decodeJWTClaims(from: jwt)
        let username = claims?.resolvedUsername ?? fallbackUsername

        guard !username.isEmpty else {
            throw AuthRepositoryError.invalidTokenPayload
        }

        let fullName = fallbackFullName?.nilIfBlank
            ?? claims?.resolvedFullName
            ?? prettifiedDisplayName(from: username)

        return AuthSession(token: jwt, username: username, fullName: fullName)
    }

    private func decodeAPIError(from data: Data, statusCode: Int) -> AuthRepositoryError {
        if let response = try? decoder.decode(APIErrorResponse.self, from: data) {
            let message = response.error?.nilIfBlank ?? response.message?.nilIfBlank
            if let message {
                if statusCode == 404 {
                    return .invalidCredentials
                }

                if message.localizedCaseInsensitiveContains("already") {
                    return .userAlreadyExists
                }

                return .server(message)
            }
        }

        return statusCode == 404
            ? .invalidCredentials
            : .server("Authentication failed with status code \(statusCode).")
    }

    private func decodeJWTClaims(from jwt: String) -> JWTClaims? {
        let segments = jwt.split(separator: ".")
        guard segments.count > 1 else { return nil }

        let payload = String(segments[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let paddingLength = (4 - payload.count % 4) % 4
        let paddedPayload = payload + String(repeating: "=", count: paddingLength)

        guard let data = Data(base64Encoded: paddedPayload) else {
            return nil
        }

        return try? decoder.decode(JWTClaims.self, from: data)
    }

    private func isTokenStillValid(_ token: String) -> Bool {
        guard let expiration = decodeJWTClaims(from: token)?.expiration else {
            return false
        }

        return Date(timeIntervalSince1970: expiration) > Date()
    }

    private func prettifiedDisplayName(from username: String) -> String {
        let formatted = username
            .replacingOccurrences(of: ".", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .split(separator: " ")
            .map { String($0).capitalized }
            .joined(separator: " ")

        return formatted.nilIfBlank ?? username
    }

    private func clearPersistedSession() {
        guard fileManager.fileExists(atPath: sessionFileURL.path) else {
            return
        }

        try? fileManager.removeItem(at: sessionFileURL)
    }

    private var sessionFileURL: URL {
        cachesDirectoryURL.appendingPathComponent("smartappt_auth_session.json")
    }

    private var cachesDirectoryURL: URL {
        (try? fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true))
            ?? fileManager.temporaryDirectory
    }
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
