//
//  BookingAvailability.swift
//  NobleCut
//
//  Created by OpenAI Codex on 30.04.26.
//

import Foundation

struct BookingAvailability {
    let selectedDate: Date
    let defaultSelectedTimeID: String
    let availableDateRange: ClosedRange<Date>
    let availableDates: [Date]
    let timeSections: [BookingTimeSection]
}

struct BookingTimeSection: Identifiable, Equatable {
    let title: String
    let iconName: String
    let slots: [BookingTimeSlot]

    var id: String { title }
}

struct BookingTimeSlot: Identifiable, Equatable {
    let id: String
    let title: String
    let hour: Int
    let minute: Int
    var isDisabled: Bool = false
}

extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        dateInterval(of: .month, for: date)?.start ?? date
    }
}
