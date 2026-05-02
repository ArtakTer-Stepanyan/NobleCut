//
//  APIConfiguration.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 01.05.26.
//

import Foundation

enum APIConfiguration {
    static let mainAPIBaseURL = URLConfiguration.resolvedURL(
        infoDictionaryKey: "NOBLECUT_MAIN_API_BASE_URL",
        environmentKey: "NOBLECUT_MAIN_API_BASE_URL",
        fallbackURLString: "http://localhost:5011/api"
    )

    static let bookingWindowDays = Int(
        ProcessInfo.processInfo.environment["NOBLECUT_BOOKING_WINDOW_DAYS"] ?? ""
    ) ?? 90

    static var configuredBusinessID: Int? {
        configuredInt(for: "NOBLECUT_BUSINESS_ID")
    }

    static var configuredServices: [Service] {
        ServiceType.allCases.compactMap(configuredService(for:))
    }

    static func resolvedConfiguredService(for service: Service) -> Service {
        guard service.usesConfiguredIDFallback else {
            return service
        }

        return configuredService(for: service.type) ?? service
    }

    static var customersPath: String {
        "customers"
    }

    static var customerBookingsPath: String {
        "\(customersPath)/bookings"
    }

    static func customerBookingPath(_ bookingID: Int) -> String {
        "\(customerBookingsPath)/\(bookingID)"
    }

    static func cancelCustomerBookingPath(_ bookingID: Int) -> String {
        "\(customerBookingPath(bookingID))/cancel"
    }

    static func monthlyCalendarPath(
        businessId: Int,
        serviceId: Int,
        year: Int,
        month: Int
    ) -> String {
        "business/\(businessId)/services/\(serviceId)/calendar/\(year)/\(month)"
    }
    
    static func servicesPath(
        businessId: Int
    ) -> String {
        "businesses/\(businessId)/services"
    }

    static func dailySlotsPath(
        businessId: Int,
        serviceId: Int,
        year: Int,
        month: Int,
        day: Int
    ) -> String {
        "\(monthlyCalendarPath(businessId: businessId, serviceId: serviceId, year: year, month: month))/\(day)/slots"
    }

    private static func configuredService(for type: ServiceType) -> Service? {
        guard
            let serviceId = configuredInt(for: type.serviceIDConfigurationKey)
        else {
            return nil
        }

        return Service(
            id: serviceId,
            type: type,
            price: type.defaultPrice,
            duration: type.defaultDuration
        )
    }

    private static func configuredInt(for key: String) -> Int? {
        configuredString(for: key).flatMap(Int.init)
    }

    private static func configuredString(for key: String) -> String? {
        let rawValue = ProcessInfo.processInfo.environment[key]
            ?? Bundle.main.object(forInfoDictionaryKey: key) as? String

        return rawValue?.nilIfBlank
    }
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

private extension ServiceType {
    var serviceIDConfigurationKey: String {
        switch self {
        case .haircut:
            return "NOBLECUT_HAIRCUT_SERVICE_ID"
        case .trim:
            return "NOBLECUT_TRIM_SERVICE_ID"
        case .deluxe:
            return "NOBLECUT_DELUXE_SERVICE_ID"
        }
    }

    var defaultPrice: Int {
        switch self {
        case .haircut:
            return 45
        case .trim:
            return 30
        case .deluxe:
            return 70
        }
    }

    var defaultDuration: Int {
        switch self {
        case .haircut:
            return 35
        case .trim:
            return 20
        case .deluxe:
            return 45
        }
    }
}
