//
//  AuthViewModel.swift
//  NobleCut
//
//  Created by OpenAI Codex on 30.04.26.
//

import Combine
import Foundation

enum AuthMode: Equatable {
    case login
    case register

    var eyebrowTitle: String {
        switch self {
        case .login:
            return "MEMBERS ACCESS"
        case .register:
            return "CREATE PROFILE"
        }
    }

    var headline: String {
        switch self {
        case .login:
            return "Return to your chair."
        case .register:
            return "Claim your place at NobleCut."
        }
    }

    var description: String {
        switch self {
        case .login:
            return "Sign in with your SmartAppt username and password. Your JWT is cached locally after login."
        case .register:
            return "Create a SmartAppt customer account with your full name, username, and password. You’ll be signed in immediately."
        }
    }

    var cardTitle: String {
        switch self {
        case .login:
            return "Login"
        case .register:
            return "Register"
        }
    }

    var primaryButtonTitle: String {
        switch self {
        case .login:
            return "SIGN IN"
        case .register:
            return "CREATE ACCOUNT"
        }
    }

    var secondaryPrompt: String {
        switch self {
        case .login:
            return "Need an account?"
        case .register:
            return "Already registered?"
        }
    }

    var secondaryActionTitle: String {
        switch self {
        case .login:
            return "REGISTER"
        case .register:
            return "BACK TO LOGIN"
        }
    }
}

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var mode: AuthMode = .login
    @Published var loginUsername = ""
    @Published var loginPassword = ""
    @Published var registerFullName = ""
    @Published var registerUsername = ""
    @Published var registerPassword = ""
    @Published var isSubmitting = false
    @Published var errorMessage: String?

    private let repository: any AuthRepositoryProtocol
    private let onAuthenticated: (AuthSession) -> Void

    init(
        repository: any AuthRepositoryProtocol,
        onAuthenticated: @escaping (AuthSession) -> Void
    ) {
        self.repository = repository
        self.onAuthenticated = onAuthenticated
    }

    func submit() async {
        errorMessage = nil

        guard validateInput() else { return }
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            let session: AuthSession
            switch mode {
            case .login:
                session = try await repository.login(
                    username: loginUsername,
                    password: loginPassword
                )
            case .register:
                session = try await repository.register(
                    fullName: registerFullName,
                    username: registerUsername,
                    password: registerPassword
                )
            }

            clearSensitiveFields()
            onAuthenticated(session)
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Authentication failed."
        }
    }

    func switchMode() {
        errorMessage = nil
        mode = mode == .login ? .register : .login
    }

    func prepareForLoggedOutState() {
        mode = .login
        clearAllFields()
        errorMessage = nil
    }

    private func validateInput() -> Bool {
        switch mode {
        case .login:
            guard !loginUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !loginPassword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                errorMessage = "Enter both username and password to continue."
                return false
            }
        case .register:
            guard !registerFullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !registerUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !registerPassword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                errorMessage = "Complete full name, username, and password to create an account."
                return false
            }
        }

        return true
    }

    private func clearSensitiveFields() {
        loginPassword = ""
        registerPassword = ""
    }

    private func clearAllFields() {
        loginUsername = ""
        loginPassword = ""
        registerFullName = ""
        registerUsername = ""
        registerPassword = ""
    }
}
