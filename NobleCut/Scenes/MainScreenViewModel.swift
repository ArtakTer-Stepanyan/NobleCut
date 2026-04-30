//
//  MainScreenViewModel.swift
//  NobleCut
//
//  Created by OpenAI Codex on 30.04.26.
//

import Foundation
import SwiftUI
import Combine

enum MainScreenTab: Int, Hashable {
    case home
    case services
    case barbers
    case reservations
}

@MainActor
final class MainScreenViewModel: ObservableObject {
    @Published var selectedTab: MainScreenTab = .home
    @Published var activeBookingService: Service?

    func presentBooking(for service: Service) {
        activeBookingService = service
    }

    func dismissBooking() {
        activeBookingService = nil
    }

    func completeBookingFlow() {
        activeBookingService = nil
        selectedTab = .reservations
    }
}
