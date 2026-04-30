//
//  ReservationRepository.swift
//  NobleCut
//
//  Created by OpenAI Codex on 30.04.26.
//

import Foundation

protocol ReservationRepositoryProtocol: AnyObject {
    func fetchReservations() async -> [Reservation]
    func createReservation(service: Service, scheduledAt: Date) async -> Reservation
}

final class ReservationRepository: ReservationRepositoryProtocol {
    private var storage: [Reservation]

    init(storage: [Reservation] = []) {
        self.storage = storage.sorted(by: Self.sortReservations)
    }

    func fetchReservations() async -> [Reservation] {
        try? await Task.sleep(for: .milliseconds(250))
        return storage
    }

    func createReservation(service: Service, scheduledAt: Date) async -> Reservation {
        try? await Task.sleep(for: .milliseconds(300))

        let reservation = Reservation(service: service, scheduledAt: scheduledAt)
        storage.insert(reservation, at: 0)
        storage.sort(by: Self.sortReservations)
        return reservation
    }

    private static func sortReservations(lhs: Reservation, rhs: Reservation) -> Bool {
        lhs.scheduledAt < rhs.scheduledAt
    }
}
