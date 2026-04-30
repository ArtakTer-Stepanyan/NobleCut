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
    var isLoading: Bool
    var isConfirming: Bool
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
        let lastAvailableDay = BookingCalendarFactory.calendar.date(byAdding: .day, value: 30, to: today) ?? today

        self.bookingRepository = bookingRepository ?? BookingRepository()
        self.reservationRepository = reservationRepository ?? ReservationRepository()
        self.state = BookingViewState(
            service: service,
            selectedDate: today,
            displayedMonth: BookingCalendarFactory.calendar.startOfMonth(for: today),
            selectedTimeID: "",
            timeSections: [],
            availableDateRange: today...lastAvailableDay,
            isLoading: true,
            isConfirming: false
        )
    }

    func loadAvailability() async {
        guard !hasLoaded else { return }

        let availability = await bookingRepository.fetchAvailability(for: state.service)
        state.selectedDate = calendar.startOfDay(for: availability.initialDate)
        state.displayedMonth = calendar.startOfMonth(for: availability.initialDate)
        state.selectedTimeID = availability.defaultSelectedTimeID
        state.timeSections = availability.timeSections
        state.availableDateRange = availability.availableDateRange
        state.isLoading = false
        hasLoaded = true
    }

    func selectDate(_ date: Date) {
        let normalizedDate = calendar.startOfDay(for: date)
        guard state.availableDateRange.contains(normalizedDate) else { return }

        state.selectedDate = normalizedDate
        state.displayedMonth = calendar.startOfMonth(for: normalizedDate)
    }

    func updateDisplayedMonth(_ month: Date) {
        let normalizedMonth = calendar.startOfMonth(for: month)
        let lowerMonth = calendar.startOfMonth(for: state.availableDateRange.lowerBound)
        let upperMonth = calendar.startOfMonth(for: state.availableDateRange.upperBound)

        guard normalizedMonth >= lowerMonth, normalizedMonth <= upperMonth else { return }
        state.displayedMonth = normalizedMonth
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
        _ = await reservationRepository.createReservation(
            service: state.service,
            scheduledAt: scheduledAt
        )
        state.isConfirming = false
        return true
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
