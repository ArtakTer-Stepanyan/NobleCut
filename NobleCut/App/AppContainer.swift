//
//  AppContainer.swift
//  NobleCut
//
//  Created by OpenAI Codex on 30.04.26.
//

import Foundation

@MainActor
final class AppContainer {
    let serviceRepository: any ServiceRepositoryProtocol
    let bookingRepository: any BookingRepositoryProtocol
    let reservationRepository: any ReservationRepositoryProtocol

    init(
        serviceRepository: (any ServiceRepositoryProtocol)? = nil,
        bookingRepository: (any BookingRepositoryProtocol)? = nil,
        reservationRepository: (any ReservationRepositoryProtocol)? = nil
    ) {
        self.serviceRepository = serviceRepository ?? ServiceRepository()
        self.bookingRepository = bookingRepository ?? BookingRepository()
        self.reservationRepository = reservationRepository ?? ReservationRepository()
    }

    func makeServiceViewModel() -> ServiceViewModel {
        ServiceViewModel(repository: serviceRepository)
    }

    func makeBookingViewModel(for service: Service) -> BookingViewModel {
        BookingViewModel(
            service: service,
            bookingRepository: bookingRepository,
            reservationRepository: reservationRepository
        )
    }

    func makeReservationViewModel() -> ReservationViewModel {
        ReservationViewModel(repository: reservationRepository)
    }
}
