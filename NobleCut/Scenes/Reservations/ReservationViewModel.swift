//
//  ReservationViewModel.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 30.04.26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class ReservationViewModel: ObservableObject {
    @Published private(set) var reservations: [Reservation] = []
    @Published private(set) var isLoading = false
    @Published private(set) var reservationPendingCancellation: Reservation?
    @Published private(set) var errorMessage: String?

    private let repository: any ReservationRepositoryProtocol

    init(repository: (any ReservationRepositoryProtocol)? = nil) {
        self.repository = repository ?? ReservationRepository()
    }

    func loadReservations() async {
        guard !isLoading else { return }

        isLoading = true
        do {
            reservations = try await repository.fetchReservations()
            errorMessage = nil
        } catch {
            reservations = []
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Couldn’t load reservations."
        }
        isLoading = false
    }

    func promptCancellation(for reservation: Reservation) {
        reservationPendingCancellation = reservation
    }

    func dismissCancellationPrompt() {
        reservationPendingCancellation = nil
    }

    func cancelReservation(_ reservation: Reservation) async {
        reservationPendingCancellation = nil

        do {
            try await repository.deleteReservation(id: reservation.id)
            reservations.removeAll { $0.id == reservation.id }
            errorMessage = nil
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Couldn’t cancel the reservation."
        }
    }
}
