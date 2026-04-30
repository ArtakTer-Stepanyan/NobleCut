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
    case invalidCredentials
    case userAlreadyExists
    case invalidRegistrationData
    case missingToken
    case invalidTokenPayload
    case invalidServerResponse
    case transport(String)
    case server(String)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "The username or password is incorrect."
        case .userAlreadyExists:
            return "That username is already taken."
        case .invalidRegistrationData:
            return "Please complete every field before continuing."
        case .missingToken:
            return "The auth service did not return a token."
        case .invalidTokenPayload:
            return "The auth service returned an unreadable session token."
        case .invalidServerResponse:
            return "The auth service returned an unexpected response."
        case .transport:
            return "Couldn’t reach the auth service. Make sure it is running and the base URL is correct."
        case .server(let message):
            return message
        }
    }
}
