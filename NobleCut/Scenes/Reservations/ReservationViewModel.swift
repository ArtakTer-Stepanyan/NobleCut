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

    private let repository: any ReservationRepositoryProtocol

    init(repository: (any ReservationRepositoryProtocol)? = nil) {
        self.repository = repository ?? ReservationRepository()
    }

    func loadReservations() async {
        guard !isLoading else { return }

        isLoading = true
        reservations = await repository.fetchReservations()
        isLoading = false
    }
}
