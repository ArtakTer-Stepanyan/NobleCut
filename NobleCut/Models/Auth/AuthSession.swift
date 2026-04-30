//
//  AuthSession.swift
//  NobleCut
//
//  Created by OpenAI Codex on 30.04.26.
//

import Foundation

struct AuthSession: Codable, Equatable {
    let token: String
    let username: String
    let fullName: String
}

enum AuthRepositoryError: LocalizedError {
    case noRegisteredUser
    case invalidCredentials
    case userAlreadyExists
    case invalidRegistrationData

    var errorDescription: String? {
        switch self {
        case .noRegisteredUser:
            return "No account was found. Register first to create one."
        case .invalidCredentials:
            return "The username or password is incorrect."
        case .userAlreadyExists:
            return "That username is already taken."
        case .invalidRegistrationData:
            return "Please complete every field before continuing."
        }
    }
}
