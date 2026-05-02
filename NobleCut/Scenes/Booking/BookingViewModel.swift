//
//  BookingViewModel.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 28.04.26.
//

import Foundation
import SwiftUI
import Combine

struct BookingViewState {
    let service: Service
    var selectedDate: Date
    var displayedMonth: Date
    var selectedTimeID: String
    var timeSections: [BookingTimeSection]
    var availableDateRange: ClosedRange<Date>
    var availableDates: [Date]
    var isLoading: Bool
    var isConfirming: Bool
    var errorMessage: String?
}

@MainActor
final class BookingViewModel: ObservableObject {
    @Published private(set) var state: BookingViewState

    private let calendar = BookingCalendarFactory.calendar
    private let bookingRepository: any BookingRepositoryProtocol
    private let reservationRepository: any ReservationRepositoryProtocol
    private var hasLoaded = false

    init(
        service: Service,
        bookingRepository: (any BookingRepositoryProtocol)? = nil,
        reservationRepository: (any ReservationRepositoryProtocol)? = nil
    ) {
        let today = BookingCalendarFactory.calendar.startOfDay(for: Date())
        let firstBookableDay = BookingCalendarFactory.calendar.date(byAdding: .day, value: 1, to: today) ?? today
        let lastAvailableDay = BookingCalendarFactory.calendar.date(byAdding: .day, value: 30, to: firstBookableDay) ?? firstBookableDay

        self.bookingRepository = bookingRepository ?? BookingRepository()
        self.reservationRepository = reservationRepository ?? ReservationRepository()
        self.state = BookingViewState(
            service: service,
            selectedDate: firstBookableDay,
            displayedMonth: BookingCalendarFactory.calendar.startOfMonth(for: firstBookableDay),
            selectedTimeID: "",
            timeSections: [],
            availableDateRange: firstBookableDay...lastAvailableDay,
            availableDates: [],
            isLoading: true,
            isConfirming: false,
            errorMessage: nil
        )
    }

    func loadAvailability() async {
        guard !hasLoaded else { return }

        await refreshAvailability(
            month: state.displayedMonth,
            selectedDate: state.selectedDate
        )
        hasLoaded = true
    }

    func selectDate(_ date: Date) {
        let normalizedDate = calendar.startOfDay(for: date)
        guard isSelectableDate(normalizedDate) else { return }

        state.errorMessage = nil

        guard !calendar.isDate(normalizedDate, inSameDayAs: state.selectedDate) else {
            return
        }

        state.selectedDate = normalizedDate
        state.displayedMonth = calendar.startOfMonth(for: normalizedDate)

        Task {
            await refreshAvailability(
                month: state.displayedMonth,
                selectedDate: normalizedDate
            )
        }
    }

    func updateDisplayedMonth(_ month: Date) {
        let normalizedMonth = calendar.startOfMonth(for: month)
        let lowerMonth = calendar.startOfMonth(for: state.availableDateRange.lowerBound)
        let upperMonth = calendar.startOfMonth(for: state.availableDateRange.upperBound)

        guard normalizedMonth >= lowerMonth, normalizedMonth <= upperMonth else { return }
        guard normalizedMonth != state.displayedMonth else { return }

        state.errorMessage = nil
        state.displayedMonth = normalizedMonth

        Task {
            await refreshAvailability(
                month: normalizedMonth,
                selectedDate: state.selectedDate
            )
        }
    }

    func selectTime(_ slot: BookingTimeSlot) {
        guard !slot.isDisabled else { return }
        state.selectedTimeID = slot.id
    }

    func isSelected(_ slot: BookingTimeSlot) -> Bool {
        state.selectedTimeID == slot.id
    }

    var canConfirm: Bool {
        !state.isLoading && !state.isConfirming && selectedTimeSlot != nil
    }

    func confirmSelection() async -> Bool {
        guard canConfirm, let scheduledAt = scheduledDate else { return false }

        state.isConfirming = true
        state.errorMessage = nil

        do {
            _ = try await reservationRepository.createReservation(
                service: state.service,
                scheduledAt: scheduledAt
            )
        } catch {
            state.errorMessage = (error as? LocalizedError)?.errorDescription ?? "Couldn’t create the booking."
            state.isConfirming = false
            return false
        }

        state.isConfirming = false
        return true
    }

    private func refreshAvailability(
        month: Date,
        selectedDate: Date?
    ) async {
        state.isLoading = true

        do {
            let availability = try await bookingRepository.fetchAvailability(
                for: state.service,
                month: month,
                selectedDate: selectedDate
            )

            state.selectedDate = calendar.startOfDay(for: availability.selectedDate)
            state.displayedMonth = calendar.startOfMonth(for: month)
            state.selectedTimeID = availability.defaultSelectedTimeID
            state.timeSections = availability.timeSections
            state.availableDateRange = availability.availableDateRange
            state.availableDates = availability.availableDates.map { calendar.startOfDay(for: $0) }
            state.errorMessage = nil
            state.isLoading = false
        } catch {
            state.selectedTimeID = ""
            state.timeSections = []
            state.availableDates = []
            state.errorMessage = (error as? LocalizedError)?.errorDescription ?? "Couldn’t load availability."
            state.isLoading = false
        }
    }

    private func isSelectableDate(_ date: Date) -> Bool {
        state.availableDates.contains(where: { calendar.isDate($0, inSameDayAs: date) })
    }

    private var selectedTimeSlot: BookingTimeSlot? {
        state.timeSections
            .flatMap(\.slots)
            .first(where: { $0.id == state.selectedTimeID })
    }

    private var scheduledDate: Date? {
        guard let slot = selectedTimeSlot else { return nil }

        return calendar.date(
            bySettingHour: slot.hour,
            minute: slot.minute,
            second: 0,
            of: state.selectedDate
        )
    }
}
