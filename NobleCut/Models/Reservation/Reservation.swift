//
//  Reservation.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 30.04.26.
//

import Foundation

struct Reservation: Codable, Identifiable, Equatable {
    let id: String
    let service: Service
    let scheduledAt: Date
    let createdAt: Date
    let status: String

    init(
        id: String = UUID().uuidString,
        service: Service,
        scheduledAt: Date,
        createdAt: Date = Date(),
        status: String = "Pending"
    ) {
        self.id = id
        self.service = service
        self.scheduledAt = scheduledAt
        self.createdAt = createdAt
        self.status = status
    }
}
