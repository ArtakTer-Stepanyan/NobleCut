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
    private struct StoredUser: Codable {
        let fullName: String
        let username: String
        let password: String
    }

    private let fileManager: FileManager
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func restoreSession() async -> AuthSession? {
        try? await Task.sleep(for: .milliseconds(120))
        return loadSession()
    }

    func login(username: String, password: String) async throws -> AuthSession {
        try? await Task.sleep(for: .milliseconds(250))

        let normalizedUsername = normalize(username)
        let normalizedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let users = loadUsers()

        guard !users.isEmpty else {
            throw AuthRepositoryError.noRegisteredUser
        }

        guard let matchingUser = users.first(where: {
            $0.username == normalizedUsername && $0.password == normalizedPassword
        }) else {
            throw AuthRepositoryError.invalidCredentials
        }

        let session = makeSession(for: matchingUser)
        try persist(session, to: sessionFileURL)
        return session
    }

    func register(fullName: String, username: String, password: String) async throws -> AuthSession {
        try? await Task.sleep(for: .milliseconds(300))

        let normalizedFullName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedUsername = normalize(username)
        let normalizedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedFullName.isEmpty, !normalizedUsername.isEmpty, !normalizedPassword.isEmpty else {
            throw AuthRepositoryError.invalidRegistrationData
        }

        var users = loadUsers()

        guard users.contains(where: { $0.username == normalizedUsername }) == false else {
            throw AuthRepositoryError.userAlreadyExists
        }

        let user = StoredUser(
            fullName: normalizedFullName,
            username: normalizedUsername,
            password: normalizedPassword
        )

        users.append(user)
        try persist(users, to: usersFileURL)

        let session = makeSession(for: user)
        try persist(session, to: sessionFileURL)
        return session
    }

    func logout() async {
        try? await Task.sleep(for: .milliseconds(100))

        guard fileManager.fileExists(atPath: sessionFileURL.path) else { return }
        try? fileManager.removeItem(at: sessionFileURL)
    }

    private func makeSession(for user: StoredUser) -> AuthSession {
        AuthSession(
            token: makeMockJWTToken(for: user),
            username: user.username,
            fullName: user.fullName
        )
    }

    private func loadUsers() -> [StoredUser] {
        guard let data = try? Data(contentsOf: usersFileURL) else {
            return []
        }

        return (try? decoder.decode([StoredUser].self, from: data)) ?? []
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

    private func normalize(_ username: String) -> String {
        username
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    private func makeMockJWTToken(for user: StoredUser) -> String {
        let header = ["alg": "HS256", "typ": "JWT"]
        let payload = [
            "sub": user.username,
            "name": user.fullName,
            "iss": "NobleCut.mock",
            "iat": ISO8601DateFormatter().string(from: Date())
        ]

        let encodedHeader = encodeJWTComponent(header)
        let encodedPayload = encodeJWTComponent(payload)
        let signature = Data(UUID().uuidString.utf8)
            .base64EncodedString()
            .jwtBase64URLComponent()

        return "\(encodedHeader).\(encodedPayload).\(signature)"
    }

    private func encodeJWTComponent(_ value: [String: String]) -> String {
        let data = (try? JSONSerialization.data(withJSONObject: value, options: [])) ?? Data()
        return data.base64EncodedString().jwtBase64URLComponent()
    }

    private var usersFileURL: URL {
        cachesDirectoryURL.appendingPathComponent("mock_auth_users.json")
    }

    private var sessionFileURL: URL {
        cachesDirectoryURL.appendingPathComponent("mock_auth_session.json")
    }

    private var cachesDirectoryURL: URL {
        (try? fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true))
            ?? fileManager.temporaryDirectory
    }
}

private extension String {
    func jwtBase64URLComponent() -> String {
        replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
