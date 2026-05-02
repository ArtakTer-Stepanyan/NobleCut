//
//  APIService.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 02.05.26.
//

import Foundation

enum APIError: LocalizedError {
    case missingSession
    case invalidResponse
    case transport(String)
    case server(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .missingSession:
            return "You need to log in before using SmartAppt customer actions."
        case .invalidResponse:
            return "The SmartAppt API returned an unexpected response."
        case .transport:
            return "Couldn’t reach the SmartAppt API. Check the base URL and make sure the backend is running."
        case .server(let statusCode, let message):
            return resolvedMessage(message, statusCode: statusCode)
        }
    }

    var statusCode: Int? {
        switch self {
        case .server(let statusCode, _):
            return statusCode
        default:
            return nil
        }
    }

    private func resolvedMessage(_ rawMessage: String, statusCode: Int) -> String {
        if let message = rawMessage.trimmedNilIfBlank {
            if statusCode == 401 {
                return "Your SmartAppt session expired. Sign in again."
            }

            if statusCode == 403, message.caseInsensitiveCompare("Forbidden") == .orderedSame {
                return "You don’t have permission to perform this action."
            }

            return message
        }

        switch statusCode {
        case 400:
            return "SmartAppt rejected the request."
        case 401:
            return "Your SmartAppt session expired. Sign in again."
        case 403:
            return "You don’t have permission to perform this action."
        case 404:
            return "The requested SmartAppt resource was not found."
        case 409:
            return "SmartAppt reported a conflict for this request."
        default:
            return "SmartAppt request failed with status code \(statusCode)."
        }
    }
}

protocol APIServiceProtocol {
    func getServices(businessId: Int) async throws -> [RemoteServicePayload]
    func getMonthlyCalendar(
        serviceId: Int,
        year: Int,
        month: Int
    ) async throws -> CalendarPayload
    func getDailySlots(
        serviceId: Int,
        year: Int,
        month: Int,
        day: Int
    ) async throws -> DailySlotsPayload
    func getCustomerBookings() async throws -> [BookingPayload]
    func createBooking(serviceId: Int, startAtUtc: String, notes: String?) async throws -> BookingPayload
    func createCustomer(fullName: String, email: String?, phone: String?) async throws -> CustomerPayload
    func cancelCustomerBooking(id: Int) async throws -> Bool
}

final class APIService: APIServiceProtocol {
    private let httpClient: HTTPClient

    init(
        httpClient: HTTPClient = HTTPClient(
            baseURL: APIConfiguration.mainAPIBaseURL,
            decoder: APIService.makeDecoder()
        )
    ) {
        self.httpClient = httpClient
    }

    func getServices(businessId: Int) async throws -> [RemoteServicePayload] {
        try await performRequest { () async throws -> [RemoteServicePayload] in
            try await httpClient.get(
                path: APIConfiguration.servicesPath(businessId: businessId),
                requiresAuth: true
            )
        }
    }

    func getMonthlyCalendar(
        serviceId: Int,
        year: Int,
        month: Int
    ) async throws -> CalendarPayload {
        let businessId = try configuredBusinessID()

        return try await performRequest { () async throws -> CalendarPayload in
            try await httpClient.get(
                path: APIConfiguration.monthlyCalendarPath(
                    businessId: businessId,
                    serviceId: serviceId,
                    year: year,
                    month: month
                )
            )
        }
    }

    func getDailySlots(
        serviceId: Int,
        year: Int,
        month: Int,
        day: Int
    ) async throws -> DailySlotsPayload {
        let businessId = try configuredBusinessID()

        return try await performRequest { () async throws -> DailySlotsPayload in
            try await httpClient.get(
                path: APIConfiguration.dailySlotsPath(
                    businessId: businessId,
                    serviceId: serviceId,
                    year: year,
                    month: month,
                    day: day
                )
            )
        }
    }

    func getCustomerBookings() async throws -> [BookingPayload] {
        return try await performRequest { () async throws -> [BookingPayload] in
            try await httpClient.get(
                path: APIConfiguration.customerBookingsPath,
                requiresAuth: true
            )
        }
    }

    func createBooking(
        serviceId: Int,
        startAtUtc: String,
        notes: String?
    ) async throws -> BookingPayload {
        let request = CreateBookingPayload(
            businessId: try configuredBusinessID(),
            serviceId: serviceId,
            startAtUtc: startAtUtc,
            notes: notes
        )

        return try await performRequest { () async throws -> BookingPayload in
            try await httpClient.post(
                path: APIConfiguration.customerBookingsPath,
                body: request,
                requiresAuth: true
            )
        }
    }

    func createCustomer(
        fullName: String,
        email: String?,
        phone: String?
    ) async throws -> CustomerPayload {
        let request = CreateCustomerPayload(
            businessId: try configuredBusinessID(),
            fullName: fullName,
            email: email,
            phone: phone
        )

        return try await performRequest { () async throws -> CustomerPayload in
            try await httpClient.post(
                path: APIConfiguration.customersPath,
                body: request,
                requiresAuth: true
            )
        }
    }

    func cancelCustomerBooking(id: Int) async throws -> Bool {
        return try await performRequest { () async throws -> Bool in
            try await httpClient.post(
                path: APIConfiguration.cancelCustomerBookingPath(id),
                requiresAuth: true
            )
        }
    }

    private func configuredBusinessID() throws -> Int {
        guard let businessId = APIConfiguration.configuredBusinessID else {
            throw APIError.transport(
                "Missing SmartAppt customer API configuration. Set NOBLECUT_BUSINESS_ID."
            )
        }

        return businessId
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

    private func map(_ error: HTTPClientError) -> APIError {
        switch error {
        case .missingSession:
            return .missingSession
        case .invalidResponse:
            return .invalidResponse
        case .transport(let message):
            return .transport(message)
        case .server(let statusCode, let message):
            return .server(
                statusCode: statusCode,
                message: message ?? "SmartAppt request failed with status code \(statusCode)."
            )
        }
    }

    private static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)

            if let date = iso8601WithFractional.date(from: value) {
                return date
            }

            if let date = iso8601.date(from: value) {
                return date
            }

            if let date = localDateTimeFormatter.date(from: value) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported SmartAppt date format: \(value)"
            )
        }
        return decoder
    }

    private static let iso8601WithFractional: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static let localDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()
}

private extension String {
    var trimmedNilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
