//
//  ServiceRepository.swift
//  NobleCut
//
//  Created by OpenAI Codex on 30.04.26.
//

import Foundation
import Combine

protocol ServiceRepositoryProtocol {
    func fetchServiceSections() async -> [ServiceSection]
}

final class ServiceRepository: ServiceRepositoryProtocol {
    func fetchServiceSections() async -> [ServiceSection] {
        try? await Task.sleep(for: .milliseconds(350))

        return [
            ServiceSection(
                type: .haircut,
                services: [
                    .init(id: 0, type: .haircut, price: 45, duration: 35),
                    .init(id: 1, type: .haircut, price: 60, duration: 50),
                    .init(id: 2, type: .haircut, price: 70, duration: 65)
                ]
            ),
            ServiceSection(
                type: .trim,
                services: [
                    .init(id: 3, type: .trim, price: 30, duration: 20),
                    .init(id: 4, type: .trim, price: 45, duration: 30),
                    .init(id: 5, type: .trim, price: 55, duration: 40)
                ]
            ),
            ServiceSection(
                type: .deluxe,
                services: [
                    .init(id: 6, type: .deluxe, price: 70, duration: 45),
                    .init(id: 7, type: .deluxe, price: 85, duration: 60),
                    .init(id: 8, type: .deluxe, price: 95, duration: 75)
                ]
            )
        ]
    }
}
