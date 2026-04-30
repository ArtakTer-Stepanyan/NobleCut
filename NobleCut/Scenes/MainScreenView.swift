//
//  MainScreenView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 26.04.26.
//

import SwiftUI

struct MainScreenView: View {
    @StateObject private var viewModel: MainScreenViewModel
    private let appContainer: AppContainer

    @MainActor
    init(appContainer: AppContainer? = nil) {
        self.appContainer = appContainer ?? AppContainer()
        _viewModel = StateObject(wrappedValue: MainScreenViewModel())
    }

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            Tab("Home", systemImage: "house", value: MainScreenTab.home) {
                HomeView()
            }


            Tab("Services", systemImage: "scissors", value: MainScreenTab.services) {
                ServiceView(viewModel: appContainer.makeServiceViewModel()) { service in
                    viewModel.presentBooking(for: service)
                }
            }


            Tab("Barbers", systemImage: "person.2", value: MainScreenTab.barbers) {
                BarbersView()
            }
            
            Tab("Reservations", systemImage: "calendar", value: MainScreenTab.reservations) {
                ReservationView(viewModel: appContainer.makeReservationViewModel())
            }
        }
        .tint(.appYellow)
        .sheet(item: $viewModel.activeBookingService) { service in
            BookingView(
                viewModel: appContainer.makeBookingViewModel(for: service),
                onCancel: {
                    viewModel.dismissBooking()
                },
                onConfirmed: {
                    viewModel.completeBookingFlow()
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    MainScreenView()
}
