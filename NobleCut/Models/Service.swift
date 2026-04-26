//
//  Service.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 26.04.26.
//

import Foundation

struct Service: Codable, Identifiable {
    let id: Int
    let type: ServiceType
    let price: Int
    var duration: Int = 10
}

enum ServiceType: Int, Codable {
    case haircut = 1
    case trim = 2
    case deluxe = 3
    
    var title: String {
        switch self {
        case .haircut:
            return "Signature Haircut"
        case .trim:
            return "Beard Trim & Sculpt"
        case .deluxe:
            return "Deluxe Straight Razor Shave"
        }
    }
    
    var description: String {
        switch self {
        case .haircut:
            return "Includes wash and style"
        case .trim:
            return "Hot towel & oil finish"
        case .deluxe:
            return "The ultimate Heritage experience"
        }
    }
    
    var iconName: String {
        switch self {
        case .haircut:
            return "haircut_icon"
        case .trim:
            return "trim_icon"
        case .deluxe:
            return "deluxe_icon"
        }
    }
}
