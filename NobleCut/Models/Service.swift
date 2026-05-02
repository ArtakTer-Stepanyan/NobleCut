//
//  Service.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 26.04.26.
//

import Foundation

struct Service: Codable, Identifiable, Equatable {
    let id: Int
    let type: ServiceType
    let price: Int
    var duration: Int = 10
    let title: String
    let details: String
    let usesConfiguredIDFallback: Bool

    init(
        id: Int,
        type: ServiceType,
        price: Int,
        duration: Int = 10,
        title: String? = nil,
        details: String? = nil,
        usesConfiguredIDFallback: Bool = false
    ) {
        self.id = id
        self.type = type
        self.price = price
        self.duration = duration
        self.title = title ?? type.title
        self.details = details ?? type.description
        self.usesConfiguredIDFallback = usesConfiguredIDFallback
    }

    var displayTitle: String {
        title
    }

    var displayDescription: String {
        details
    }
}

extension Service {
    init(remotePayload: RemoteServicePayload) {
        let inferredType = ServiceType.inferred(from: remotePayload.name)

        self.init(
            id: remotePayload.serviceId,
            type: inferredType,
            price: NSDecimalNumber(decimal: remotePayload.price).intValue,
            duration: remotePayload.durationMin,
            title: remotePayload.name,
            details: inferredType.description
        )
    }
}

enum ServiceType: Int, Codable, CaseIterable {
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

    var sectionTitle: String {
        switch self {
        case .haircut:
            return "Haircuts"
        case .trim:
            return "Beard Care"
        case .deluxe:
            return "Deluxe Rituals"
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

    static func inferred(from serviceName: String) -> ServiceType {
        let lowercasedName = serviceName.lowercased()

        if lowercasedName.contains("beard") ||
            lowercasedName.contains("trim") ||
            lowercasedName.contains("mustache") {
            return .trim
        }

        if lowercasedName.contains("shave") ||
            lowercasedName.contains("razor") ||
            lowercasedName.contains("deluxe") ||
            lowercasedName.contains("ritual") {
            return .deluxe
        }

        return .haircut
    }
}
