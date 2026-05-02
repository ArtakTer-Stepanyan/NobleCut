//
//  BarberDetails.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 27.04.26.
//

import Foundation

struct BarberDetails: Codable, Identifiable {
    let id: UUID = UUID()
    let image: String
    let name: String
    let specialty: BarberSpecialtyType
    let description: String
}

enum BarberSpecialtyType: Int, Codable {
    case haircut = 0
    case beard = 1
    case styling = 2
    
    var title: String {
        switch self {
        case .haircut:
            return "Haircuts & Grooming"
        case .beard:
            return "Beard & Shave"
        case .styling:
            return "Hair & Beard Styling"
        }
    }
}
