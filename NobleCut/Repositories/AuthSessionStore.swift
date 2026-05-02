//
//  AuthSessionStore.swift
//  NobleCut
//
//  Created by OpenAI Codex on 01.05.26.
//

import Foundation

protocol AuthSessionStoreProtocol: AnyObject {
    func loadSession() -> AuthSession?
    func saveSession(_ session: AuthSession) throws
    func clearSession()
}

final class AuthSessionStore: AuthSessionStoreProtocol {
    static let shared = AuthSessionStore()

    private let fileManager: FileManager
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func loadSession() -> AuthSession? {
        guard let data = try? Data(contentsOf: sessionFileURL) else {
            return nil
        }

        return try? decoder.decode(AuthSession.self, from: data)
    }

    func saveSession(_ session: AuthSession) throws {
        let directoryURL = sessionFileURL.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: directoryURL.path) {
            try fileManager.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }

        let data = try encoder.encode(session)
        try data.write(to: sessionFileURL, options: .atomic)
    }

    func clearSession() {
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
