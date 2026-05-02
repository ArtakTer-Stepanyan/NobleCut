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

    private let apiService: any AuthServiceProtocol
    private let sessionStore: any AuthSessionStoreProtocol
    private let decoder = JSONDecoder()

    init(
        apiService: any AuthServiceProtocol = AuthService(),
        sessionStore: any AuthSessionStoreProtocol = AuthSessionStore.shared
    ) {
        self.apiService = apiService
        self.sessionStore = sessionStore
    }

    func restoreSession() async -> AuthSession? {
        guard let session = sessionStore.loadSession() else {
            return nil
        }

        guard isTokenStillValid(session.token) else {
            sessionStore.clearSession()
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

        let response = try await apiService.login(
            username: trimmedUsername,
            password: trimmedPassword
        )

        let session = try makeSession(
            jwt: response.jwt,
            fallbackUsername: trimmedUsername,
            fallbackFullName: nil
        )
        try sessionStore.saveSession(session)
        return session
    }

    func register(fullName: String, username: String, password: String) async throws -> AuthSession {
        guard !fullName.isEmpty, !username.isEmpty, !password.isEmpty else {
            throw AuthRepositoryError.invalidRegistrationData
        }

        let response = try await apiService.registerCustomer(
            fullName: fullName,
            username: username,
            password: password
        )

        let session = try makeSession(
            jwt: response.jwt,
            fallbackUsername: username,
            fallbackFullName: fullName
        )
        try sessionStore.saveSession(session)
        return session
    }

    func logout() async {
        sessionStore.clearSession()
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
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
