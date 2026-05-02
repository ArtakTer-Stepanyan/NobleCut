//
//  HTTPClient.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 02.05.26.
//

import Foundation

enum HTTPClientError: Error {
    case missingSession
    case invalidResponse
    case transport(String)
    case server(statusCode: Int, message: String?)
}

final class HTTPClient {
    private struct EmptyBody: Encodable {}

    private struct ResponseEnvelope<Payload: Decodable>: Decodable {
        let data: Payload?
        let message: String?
        let httpStatusCode: Int?

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: FlexibleCodingKey.self)
            data = try container.decodeIfPresent(Payload.self, forAnyOf: ["data", "Data"])
            message = try container.decodeIfPresent(String.self, forAnyOf: ["message", "Message"])
            httpStatusCode = try container.decodeIfPresent(Int.self, forAnyOf: ["httpStatusCode", "HttpStatusCode"])
        }
    }

    private struct MessageEnvelope: Decodable {
        let error: String?
        let message: String?
        let status: Int?

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: FlexibleCodingKey.self)
            error = try container.decodeIfPresent(String.self, forAnyOf: ["error", "Error"])
            message = try container.decodeIfPresent(String.self, forAnyOf: ["message", "Message"])
            status = try container.decodeIfPresent(Int.self, forAnyOf: ["status", "Status"])
        }
    }

    private let baseURL: URL
    private let sessionStore: any AuthSessionStoreProtocol
    private let urlSession: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        baseURL: URL,
        sessionStore: any AuthSessionStoreProtocol = AuthSessionStore.shared,
        urlSession: URLSession = .shared,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.sessionStore = sessionStore
        self.urlSession = urlSession
        self.encoder = encoder
        self.decoder = decoder
    }

    func get<Payload: Decodable>(
        path: String,
        requiresAuth: Bool = false
    ) async throws -> Payload {
        try await request(
            url: baseURL.appendingPathComponent(path),
            method: "GET",
            bodyData: nil,
            requiresAuth: requiresAuth
        )
    }

    func get<Payload: Decodable>(
        url: URL,
        requiresAuth: Bool = false
    ) async throws -> Payload {
        try await request(
            url: url,
            method: "GET",
            bodyData: nil,
            requiresAuth: requiresAuth
        )
    }

    func post<RequestBody: Encodable, Payload: Decodable>(
        path: String,
        body: RequestBody,
        requiresAuth: Bool = false
    ) async throws -> Payload {
        try await request(
            url: baseURL.appendingPathComponent(path),
            method: "POST",
            bodyData: try encoder.encode(body),
            requiresAuth: requiresAuth
        )
    }

    func post<Payload: Decodable>(
        path: String,
        requiresAuth: Bool = false
    ) async throws -> Payload {
        try await request(
            url: baseURL.appendingPathComponent(path),
            method: "POST",
            bodyData: try encoder.encode(EmptyBody()),
            requiresAuth: requiresAuth
        )
    }

    private func request<Payload: Decodable>(
        url: URL,
        method: String,
        bodyData: Data?,
        requiresAuth: Bool
    ) async throws -> Payload {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let bodyData {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = bodyData
        }

        if requiresAuth {
            guard let token = sessionStore.loadSession()?.token else {
                throw HTTPClientError.missingSession
            }

            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await urlSession.data(for: request)
        } catch {
            throw HTTPClientError.transport(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPClientError.invalidResponse
        }

        guard (200 ..< 300).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 {
                sessionStore.clearSession()
            }

            throw HTTPClientError.server(
                statusCode: httpResponse.statusCode,
                message: extractErrorMessage(from: data)
            )
        }

        do {
            if let envelope = try? decoder.decode(ResponseEnvelope<Payload>.self, from: data),
               let payload = envelope.data {
                return payload
            }

            return try decoder.decode(Payload.self, from: data)
        } catch {
            throw HTTPClientError.invalidResponse
        }
    }

    private func extractErrorMessage(from data: Data) -> String? {
        if let response = try? decoder.decode(ResponseEnvelope<String>.self, from: data) {
            if let message = response.message?.trimmedNilIfBlank {
                return message
            }

            if let embeddedMessage = response.data?.trimmedNilIfBlank {
                return embeddedMessage
            }
        }

        if let response = try? decoder.decode(MessageEnvelope.self, from: data) {
            if let error = response.error?.trimmedNilIfBlank {
                return error
            }

            if let message = response.message?.trimmedNilIfBlank {
                return message
            }
        }

        return nil
    }
}

private extension String {
    var trimmedNilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
