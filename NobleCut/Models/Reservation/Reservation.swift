//
//  Reservation.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 30.04.26.
//

import Foundation

struct Reservation: Codable, Identifiable, Equatable {
    let id: UUID
    let service: Service
    let scheduledAt: Date
    let createdAt: Date

    init(
        id: UUID = UUID(),
        service: Service,
        scheduledAt: Date,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.service = service
        self.scheduledAt = scheduledAt
        self.createdAt = createdAt
    }
}
