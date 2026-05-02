//
//  AppContainer.swift
//  NobleCut
//
//  Created by OpenAI Codex on 30.04.26.
//

import Foundation

@MainActor
final class AppContainer {
    let authAPIService: any AuthServiceProtocol
    let smartApptAPIService: any APIServiceProtocol
    let authRepository: any AuthRepositoryProtocol
    let serviceRepository: any ServiceRepositoryProtocol
    let bookingRepository: any BookingRepositoryProtocol
    let reservationRepository: any ReservationRepositoryProtocol

    init(
        authAPIService: (any AuthServiceProtocol)? = nil,
        smartApptAPIService: (any APIServiceProtocol)? = nil,
        authRepository: (any AuthRepositoryProtocol)? = nil,
        serviceRepository: (any ServiceRepositoryProtocol)? = nil,
        bookingRepository: (any BookingRepositoryProtocol)? = nil,
        reservationRepository: (any ReservationRepositoryProtocol)? = nil
    ) {
        let resolvedAuthAPIService = authAPIService ?? AuthService()
        let resolvedSmartApptAPIService = smartApptAPIService ?? APIService()

        self.authAPIService = resolvedAuthAPIService
        self.smartApptAPIService = resolvedSmartApptAPIService
        self.authRepository = authRepository ?? AuthRepository(apiService: resolvedAuthAPIService)
        self.serviceRepository = serviceRepository ?? ServiceRepository(apiService: resolvedSmartApptAPIService)
        self.bookingRepository = bookingRepository ?? BookingRepository(apiService: resolvedSmartApptAPIService)
        self.reservationRepository = reservationRepository ?? ReservationRepository(apiService: resolvedSmartApptAPIService)
    }

    func makeAppSessionViewModel() -> AppSessionViewModel {
        AppSessionViewModel(repository: authRepository)
    }

    func makeAuthFlowViewModel(onAuthenticated: @escaping (AuthSession) -> Void) -> AuthViewModel {
        AuthViewModel(repository: authRepository, onAuthenticated: onAuthenticated)
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
