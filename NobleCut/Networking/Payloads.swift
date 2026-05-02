//
//  Payloads.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 01.05.26.
//

import Foundation

struct RemoteServicePayload: Decodable {
    let serviceId: Int
    let businessId: Int
    let name: String
    let durationMin: Int
    let price: Decimal
    let isActive: Bool

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: FlexibleCodingKey.self)
        serviceId = try container.decode(Int.self, forAnyOf: ["serviceId", "ServiceId"])
        businessId = try container.decode(Int.self, forAnyOf: ["businessId", "BusinessId"])
        name = try container.decode(String.self, forAnyOf: ["name", "Name"])
        durationMin = try container.decode(Int.self, forAnyOf: ["durationMin", "DurationMin"])
        price = try container.decode(Decimal.self, forAnyOf: ["price", "Price"])
        isActive = try container.decode(Bool.self, forAnyOf: ["isActive", "IsActive"])
    }
}

struct DayAvailabilityPayload: Decodable {
    let day: Int
    let isOpen: Bool
    let hasFreeSlots: Bool

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: FlexibleCodingKey.self)
        day = try container.decode(Int.self, forAnyOf: ["day", "Day"])
        isOpen = try container.decode(Bool.self, forAnyOf: ["isOpen", "IsOpen"])
        hasFreeSlots = try container.decode(Bool.self, forAnyOf: ["hasFreeSlots", "HasFreeSlots"])
    }
}

struct CalendarPayload: Decodable {
    let month: Int
    let year: Int
    let days: [DayAvailabilityPayload]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: FlexibleCodingKey.self)
        month = try container.decode(Int.self, forAnyOf: ["month", "Month"])
        year = try container.decode(Int.self, forAnyOf: ["year", "Year"])
        days = try container.decode([DayAvailabilityPayload].self, forAnyOf: ["days", "Days"])
    }
}

struct DailySlotsPayload: Decodable {
    let date: String
    let freeSlots: [String]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: FlexibleCodingKey.self)
        date = try container.decode(String.self, forAnyOf: ["date", "Date"])
        freeSlots = try container.decode([String].self, forAnyOf: ["freeSlots", "FreeSlots"])
    }
}

struct CreateBookingPayload: Encodable {
    let businessId: Int
    let serviceId: Int
    let startAtUtc: String
    let notes: String?
}

struct BookingPayload: Decodable {
    let bookingId: Int
    let serviceId: Int
    let customerId: Int
    let startAtUtc: Date
    let endAtUtc: Date
    let status: String
    let notes: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: FlexibleCodingKey.self)
        bookingId = try container.decode(Int.self, forAnyOf: ["bookingId", "BookingId"])
        serviceId = try container.decode(Int.self, forAnyOf: ["serviceId", "ServiceId"])
        customerId = try container.decode(Int.self, forAnyOf: ["customerId", "CustomerId"])
        startAtUtc = try container.decode(Date.self, forAnyOf: ["startAtUtc", "StartAtUtc"])
        endAtUtc = try container.decode(Date.self, forAnyOf: ["endAtUtc", "EndAtUtc"])
        status = try container.decode(String.self, forAnyOf: ["status", "Status"])
        notes = try container.decodeIfPresent(String.self, forAnyOf: ["notes", "Notes"])
    }
}

struct CreateCustomerPayload: Encodable {
    let businessId: Int
    let fullName: String
    let email: String?
    let phone: String?
}

struct CustomerPayload: Decodable {
    let customerId: Int
    let fullName: String
    let email: String?
    let phone: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: FlexibleCodingKey.self)
        customerId = try container.decode(Int.self, forAnyOf: ["customerId", "CustomerId"])
        fullName = try container.decode(String.self, forAnyOf: ["fullName", "FullName"])
        email = try container.decodeIfPresent(String.self, forAnyOf: ["email", "Email"])
        phone = try container.decodeIfPresent(String.self, forAnyOf: ["phone", "Phone"])
    }
}
