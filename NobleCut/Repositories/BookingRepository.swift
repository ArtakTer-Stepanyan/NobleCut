//
//  BookingRepository.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 28.04.26.
//

import Foundation

protocol BookingRepositoryProtocol {
    func fetchAvailability(for service: Service, month: Date, selectedDate: Date?) async throws -> BookingAvailability
}

private struct BookingTimeSectionDescriptor: Hashable {
    let title: String
    let iconName: String
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
    private let apiService: any APIServiceProtocol
    private let debugDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = BookingCalendarFactory.calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    private let slotTitleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = BookingCalendarFactory.calendar
        formatter.locale = .autoupdatingCurrent
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateFormat = "hh:mm a"
        return formatter
    }()

    init(apiService: any APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }

    func fetchAvailability(
        for service: Service,
        month: Date,
        selectedDate: Date?
    ) async throws -> BookingAvailability {
        let resolvedService = APIConfiguration.resolvedConfiguredService(for: service)
        let availability: BookingAvailability
        let source: String

        if APIConfiguration.configuredBusinessID == nil {
            availability = mockAvailability(for: service, month: month, selectedDate: selectedDate)
            source = "mock"
        } else {
            availability = try await remoteAvailability(
                for: resolvedService,
                month: month,
                selectedDate: selectedDate
            )
            source = "remote"
        }

        logAvailability(availability, for: resolvedService, source: source)
        return availability
    }

    private func remoteAvailability(
        for service: Service,
        month: Date,
        selectedDate: Date?
    ) async throws -> BookingAvailability {
        let normalizedMonth = calendar.startOfMonth(for: month)
        let year = calendar.component(.year, from: normalizedMonth)
        let monthNumber = calendar.component(.month, from: normalizedMonth)
        let today = calendar.startOfDay(for: Date())
        let earliestBookableDay = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        let lastAvailableDay = calendar.date(
            byAdding: .day,
            value: APIConfiguration.bookingWindowDays,
            to: earliestBookableDay
        ) ?? earliestBookableDay

        let monthlyCalendar = try await apiService.getMonthlyCalendar(
            serviceId: service.id,
            year: year,
            month: monthNumber
        )

        print(
            "[BookingRepository] Monthly calendar response for service \(service.id) (\(year)-\(monthNumber)): \(describe(monthlyCalendar))"
        )

        let availableDates = monthlyCalendar.days.compactMap { day -> Date? in
            guard day.isOpen, day.hasFreeSlots else {
                return nil
            }

            return calendar.date(from: DateComponents(year: year, month: monthNumber, day: day.day))
        }
        .map { calendar.startOfDay(for: $0) }
        .filter { $0 >= earliestBookableDay }
        .sorted()

        let normalizedSelectedDate = selectedDate.map { calendar.startOfDay(for: $0) }
        let effectiveDate = normalizedSelectedDate.flatMap { selectedDate in
            availableDates.first(where: { calendar.isDate($0, inSameDayAs: selectedDate) })
        } ?? availableDates.first
            ?? normalizedSelectedDate
            ?? earliestBookableDay

        let timeSections: [BookingTimeSection]
        if availableDates.contains(where: { calendar.isDate($0, inSameDayAs: effectiveDate) }) {
            timeSections = try await loadTimeSections(
                serviceId: service.id,
                date: effectiveDate
            )
        } else {
            timeSections = []
        }

        let defaultSelectedTimeID = timeSections
            .flatMap(\.slots)
            .first(where: { !$0.isDisabled })?
            .id ?? ""

        return BookingAvailability(
            selectedDate: effectiveDate,
            defaultSelectedTimeID: defaultSelectedTimeID,
            availableDateRange: earliestBookableDay...lastAvailableDay,
            availableDates: availableDates,
            timeSections: timeSections
        )
    }

    private func loadTimeSections(
        serviceId: Int,
        date: Date
    ) async throws -> [BookingTimeSection] {
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)

        let dailySlots = try await apiService.getDailySlots(
            serviceId: serviceId,
            year: year,
            month: month,
            day: day
        )

        print(
            "[BookingRepository] Daily slots response for service \(serviceId) on \(formattedDate(year: year, month: month, day: day)): date=\(dailySlots.date), freeSlots=\(dailySlots.freeSlots)"
        )

        let slots = dailySlots.freeSlots.compactMap(parseSlot(from:)).sorted { lhs, rhs in
            if lhs.hour == rhs.hour {
                return lhs.minute < rhs.minute
            }

            return lhs.hour < rhs.hour
        }

        return makeTimeSections(from: slots)
    }

    private func parseSlot(from value: String) -> BookingTimeSlot? {
        let normalizedValue = value.split(separator: ".").last.map(String.init) ?? value
        let components = normalizedValue.split(separator: ":")

        guard components.count >= 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return nil
        }

        let anchorDate = calendar.startOfDay(for: Date())
        let title = calendar.date(
            bySettingHour: hour,
            minute: minute,
            second: 0,
            of: anchorDate
        )
        .map { slotTitleFormatter.string(from: $0) }
        ?? String(format: "%02d:%02d", hour, minute)

        return BookingTimeSlot(
            id: String(format: "%02d:%02d", hour, minute),
            title: title,
            hour: hour,
            minute: minute
        )
    }

    private func makeTimeSections(from slots: [BookingTimeSlot]) -> [BookingTimeSection] {
        let groupedSlots = Dictionary(grouping: slots, by: sectionDescriptor(for:))

        return [
            BookingTimeSectionDescriptor(title: "Morning", iconName: "morning_icon"),
            BookingTimeSectionDescriptor(title: "Afternoon", iconName: "afternoon_icon"),
            BookingTimeSectionDescriptor(title: "Evening", iconName: "evening_icon")
        ]
        .compactMap { descriptor in
            guard let slots = groupedSlots[descriptor], !slots.isEmpty else {
                return nil
            }

            return BookingTimeSection(
                title: descriptor.title,
                iconName: descriptor.iconName,
                slots: slots
            )
        }
    }

    private func sectionDescriptor(for slot: BookingTimeSlot) -> BookingTimeSectionDescriptor {
        switch slot.hour {
        case ..<12:
            return BookingTimeSectionDescriptor(title: "Morning", iconName: "morning_icon")
        case 12..<17:
            return BookingTimeSectionDescriptor(title: "Afternoon", iconName: "afternoon_icon")
        default:
            return BookingTimeSectionDescriptor(title: "Evening", iconName: "evening_icon")
        }
    }

    private func logAvailability(
        _ availability: BookingAvailability,
        for service: Service,
        source: String
    ) {
        let availableDates = availability.availableDates
            .map { debugDateFormatter.string(from: $0) }
            .joined(separator: ", ")
        let availableTimes = availability.timeSections
            .flatMap(\.slots)
            .filter { !$0.isDisabled }
            .map(\.title)
            .joined(separator: ", ")

        print(
            """
            [BookingRepository] Resolved \(source) availability for service \(service.id) (\(service.displayTitle)):
            availableDates=[\(availableDates)]
            availableTimes=[\(availableTimes)]
            """
        )
    }

    private func describe(_ payload: CalendarPayload) -> String {
        payload.days
            .map { day in
                "day=\(day.day), isOpen=\(day.isOpen), hasFreeSlots=\(day.hasFreeSlots)"
            }
            .joined(separator: " | ")
    }

    private func formattedDate(year: Int, month: Int, day: Int) -> String {
        String(format: "%04d-%02d-%02d", year, month, day)
    }

    private func mockAvailability(
        for service: Service,
        month: Date,
        selectedDate: Date?
    ) -> BookingAvailability {
        let today = calendar.startOfDay(for: Date())
        let earliestBookableDay = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        let preferredDate = selectedDate.map { calendar.startOfDay(for: $0) }
        let initialDate = preferredDate
            ?? calendar.date(byAdding: .day, value: service.id % 4, to: earliestBookableDay)
            ?? earliestBookableDay
        let finalDate = calendar.date(byAdding: .day, value: 45, to: earliestBookableDay) ?? earliestBookableDay
        let availableDates = generateMockAvailableDates(
            lowerBound: earliestBookableDay,
            upperBound: finalDate,
            month: month
        )
        let effectiveDate = availableDates.first(where: { calendar.isDate($0, inSameDayAs: initialDate) })
            ?? availableDates.first
            ?? initialDate

        return BookingAvailability(
            selectedDate: effectiveDate,
            defaultSelectedTimeID: defaultSelectedTimeID(for: service.type),
            availableDateRange: earliestBookableDay...finalDate,
            availableDates: availableDates,
            timeSections: getTimeSections(for: service.type)
        )
    }

    private func generateMockAvailableDates(
        lowerBound: Date,
        upperBound: Date,
        month: Date
    ) -> [Date] {
        let normalizedMonth = calendar.startOfMonth(for: month)
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: normalizedMonth),
            let dayRange = calendar.range(of: .day, in: .month, for: normalizedMonth)
        else {
            return []
        }

        return dayRange.compactMap { day in
            let date = calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start)
            guard let date else {
                return nil
            }

            let normalizedDate = calendar.startOfDay(for: date)
            guard normalizedDate >= lowerBound, normalizedDate <= upperBound else {
                return nil
            }

            return normalizedDate
        }
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
