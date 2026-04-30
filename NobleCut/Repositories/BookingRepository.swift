//
//  BookingRepository.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 28.04.26.
//

import Foundation

protocol BookingRepositoryProtocol {
    func fetchAvailability(for service: Service) async -> BookingAvailability
}

struct BookingCalendarFactory {
    static var calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = .autoupdatingCurrent
        calendar.timeZone = .autoupdatingCurrent
        calendar.firstWeekday = 1
        return calendar
    }()
}

final class BookingRepository: BookingRepositoryProtocol {
    private let calendar = BookingCalendarFactory.calendar

    func fetchAvailability(for service: Service) async -> BookingAvailability {
        try? await Task.sleep(for: .milliseconds(300))

        let today = calendar.startOfDay(for: Date())
        let initialDate = calendar.date(byAdding: .day, value: service.id % 4, to: today) ?? today
        let finalDate = calendar.date(byAdding: .day, value: 45, to: today) ?? today

        return BookingAvailability(
            initialDate: initialDate,
            defaultSelectedTimeID: defaultSelectedTimeID(for: service.type),
            availableDateRange: today...finalDate,
            timeSections: getTimeSections(for: service.type)
        )
    }

    private func defaultSelectedTimeID(for serviceType: ServiceType) -> String {
        switch serviceType {
        case .haircut:
            return "afternoon-01:15 PM"
        case .trim:
            return "morning-09:45 AM"
        case .deluxe:
            return "evening-05:00 PM"
        }
    }

    private func getTimeSections(for serviceType: ServiceType) -> [BookingTimeSection] {
        [
            .init(
                title: "Morning",
                iconName: "morning_icon",
                slots: [
                    .init(id: "morning-09:00 AM", title: "09:00 AM", hour: 9, minute: 0),
                    .init(id: "morning-09:45 AM", title: "09:45 AM", hour: 9, minute: 45),
                    .init(id: "morning-10:30 AM", title: "10:30 AM", hour: 10, minute: 30),
                    .init(id: "morning-11:15 AM", title: "11:15 AM", hour: 11, minute: 15, isDisabled: serviceType == .deluxe)
                ]
            ),
            .init(
                title: "Afternoon",
                iconName: "afternoon_icon",
                slots: [
                    .init(id: "afternoon-12:30 PM", title: "12:30 PM", hour: 12, minute: 30),
                    .init(id: "afternoon-01:15 PM", title: "01:15 PM", hour: 13, minute: 15),
                    .init(id: "afternoon-02:00 PM", title: "02:00 PM", hour: 14, minute: 0),
                    .init(id: "afternoon-02:45 PM", title: "02:45 PM", hour: 14, minute: 45),
                    .init(id: "afternoon-03:30 PM", title: "03:30 PM", hour: 15, minute: 30, isDisabled: serviceType == .trim),
                    .init(id: "afternoon-04:15 PM", title: "04:15 PM", hour: 16, minute: 15, isDisabled: true)
                ]
            ),
            .init(
                title: "Evening",
                iconName: "evening_icon",
                slots: [
                    .init(id: "evening-05:00 PM", title: "05:00 PM", hour: 17, minute: 0),
                    .init(id: "evening-05:45 PM", title: "05:45 PM", hour: 17, minute: 45),
                    .init(id: "evening-06:30 PM", title: "06:30 PM", hour: 18, minute: 30, isDisabled: serviceType == .haircut)
                ]
            )
        ]
    }
}
