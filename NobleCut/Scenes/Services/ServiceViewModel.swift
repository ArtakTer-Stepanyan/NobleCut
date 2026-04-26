//
//  ServiceViewModel.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 26.04.26.
//

import Foundation
import SwiftUI
import Combine

struct ServiceSection: Identifiable {
    let id: UUID = UUID()
    let type: ServiceType
    let services: [Service]
    
}

class ServiceViewModel: ObservableObject {
    @SwiftUI.Published var sections: [ServiceSection] = []
    
    init() {
        self.sections = [
            ServiceSection(type: .haircut, services:
                            [
                                .init(id: 0, type: .haircut, price: 45),
                                .init(id: 1, type: .haircut, price: 60),
                                .init(id: 2, type: .haircut, price: 70),
                            ]
                          ),
            ServiceSection(type: .trim, services:
                            [
                                .init(id: 3, type: .trim, price: 45),
                                .init(id: 4, type: .trim, price: 60),
                                .init(id: 5, type: .trim, price: 70),
                            ]
                          ),
            ServiceSection(type: .deluxe, services:
                            [
                                .init(id: 6, type: .deluxe, price: 70),
                                .init(id: 7, type: .deluxe, price: 80),
                                .init(id: 8, type: .deluxe, price: 90),
                            ]
                          )
        ]
    }
}
