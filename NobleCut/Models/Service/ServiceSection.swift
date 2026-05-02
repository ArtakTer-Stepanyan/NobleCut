//
//  ServiceSection.swift
//  NobleCut
//
//  Created by OpenAI Codex on 30.04.26.
//

import Foundation

struct ServiceSection: Identifiable, Equatable {
    let type: ServiceType
    let services: [Service]

    var id: ServiceType { type }
}
