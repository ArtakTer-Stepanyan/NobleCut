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
    private let apiService: any APIServiceProtocol

    init(apiService: any APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }

    func fetchServiceSections() async -> [ServiceSection] {
        let fallbackSections = Self.fallbackSections()

        guard let businessId = APIConfiguration.configuredBusinessID else {
            return fallbackSections
        }

        do {
            let remoteServices = try await apiService.getServices(businessId: businessId)

            let activeServices = remoteServices
                .filter(\.isActive)
                .map(Service.init(remotePayload:))
            let sections = Self.makeSections(from: activeServices)

            if !sections.isEmpty {
                return sections
            }

        } catch {
            print("[ServiceRepository] Failed to load remote services: \(error.localizedDescription)")
        }

        print("[ServiceRepository] Loaded fallback services: \(Self.debugDescription(for: fallbackSections))")
        return fallbackSections
    }

    private static func makeSections(from services: [Service]) -> [ServiceSection] {
        ServiceType.allCases.compactMap { type in
            let matchingServices = services.filter { $0.type == type }
            guard !matchingServices.isEmpty else {
                return nil
            }

            return ServiceSection(type: type, services: matchingServices)
        }
    }

    private static func debugDescription(for sections: [ServiceSection]) -> String {
        sections
            .flatMap(\.services)
            .map { service in
                "id=\(service.id), title=\(service.displayTitle), type=\(service.type), price=\(service.price), duration=\(service.duration)"
            }
            .joined(separator: " | ")
    }

    private static func debugDescription(for services: [RemoteServicePayload]) -> String {
        services
            .map { service in
                "serviceId=\(service.serviceId), name=\(service.name), price=\(service.price), durationMin=\(service.durationMin), isActive=\(service.isActive)"
            }
            .joined(separator: " | ")
    }

    private static func fallbackSections() -> [ServiceSection] {
        let configuredServices = APIConfiguration.configuredServices
        if !configuredServices.isEmpty {
            return makeSections(from: configuredServices)
        }

        return mockSections
    }

    private static var mockSections: [ServiceSection] {
        [
            ServiceSection(
                type: .haircut,
                services: [
                    .init(id: 0, type: .haircut, price: 45, duration: 35, usesConfiguredIDFallback: true),
                    .init(id: 1, type: .haircut, price: 60, duration: 50, usesConfiguredIDFallback: true),
                    .init(id: 2, type: .haircut, price: 70, duration: 65, usesConfiguredIDFallback: true)
                ]
            ),
            ServiceSection(
                type: .trim,
                services: [
                    .init(id: 3, type: .trim, price: 30, duration: 20, usesConfiguredIDFallback: true),
                    .init(id: 4, type: .trim, price: 45, duration: 30, usesConfiguredIDFallback: true),
                    .init(id: 5, type: .trim, price: 55, duration: 40, usesConfiguredIDFallback: true)
                ]
            ),
            ServiceSection(
                type: .deluxe,
                services: [
                    .init(id: 6, type: .deluxe, price: 70, duration: 45, usesConfiguredIDFallback: true),
                    .init(id: 7, type: .deluxe, price: 85, duration: 60, usesConfiguredIDFallback: true),
                    .init(id: 8, type: .deluxe, price: 95, duration: 75, usesConfiguredIDFallback: true)
                ]
            )
        ]
    }
}
