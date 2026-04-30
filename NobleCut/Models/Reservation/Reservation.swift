//
//  Reservation.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 30.04.26.
//

import Foundation

struct Reservation: Codable, Identifiable {
    let id: Int
    let name: String
    let price: Int
    let duration: Int
    let date: Date
}
