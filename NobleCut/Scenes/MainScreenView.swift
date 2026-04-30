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
    private let session: AuthSession
    private let onLogout: () -> Void

    @MainActor
    init(
        appContainer: AppContainer? = nil,
        session: AuthSession,
        onLogout: @escaping () -> Void = {}
    ) {
        self.appContainer = appContainer ?? AppContainer()
        self.session = session
        self.onLogout = onLogout
        _viewModel = StateObject(wrappedValue: MainScreenViewModel())
    }

    var body: some View {
        ZStack(alignment: .leading) {
            TabView(selection: $viewModel.selectedTab) {
                Tab("Home", systemImage: "house", value: MainScreenTab.home) {
                    HomeView(onMenuTap: viewModel.openSideMenu)
                }

                Tab("Services", systemImage: "scissors", value: MainScreenTab.services) {
                    ServiceView(
                        viewModel: appContainer.makeServiceViewModel(),
                        onMenuTap: viewModel.openSideMenu
                    ) { service in
                        viewModel.presentBooking(for: service)
                    }
                }

                Tab("Barbers", systemImage: "person.2", value: MainScreenTab.barbers) {
                    BarbersView(onMenuTap: viewModel.openSideMenu)
                }

                Tab("Reservations", systemImage: "calendar", value: MainScreenTab.reservations) {
                    ReservationView(
                        viewModel: appContainer.makeReservationViewModel(),
                        onMenuTap: viewModel.openSideMenu
                    )
                }
            }
            .tint(.appYellow)
            .disabled(viewModel.isSideMenuPresented)

            sideMenuOverlay
        }
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
        .animation(
            .spring(response: 0.38, dampingFraction: 0.84, blendDuration: 0.16),
            value: viewModel.isSideMenuPresented
        )
    }

    private var sideMenuOverlay: some View {
        ZStack(alignment: .leading) {
            Color.black
                .opacity(viewModel.isSideMenuPresented ? 0.56 : 0)
                .ignoresSafeArea()
                .onTapGesture {
                    guard viewModel.isSideMenuPresented else { return }
                    viewModel.closeSideMenu()
                }
                .allowsHitTesting(viewModel.isSideMenuPresented)

            SideMenuView(
                session: session,
                onClose: viewModel.closeSideMenu,
                onLogout: handleLogout
            )
            .offset(x: viewModel.isSideMenuPresented ? 0 : -SideMenuView.hiddenOffset)
        }
        .allowsHitTesting(viewModel.isSideMenuPresented)
    }

    private func handleLogout() {
        viewModel.closeSideMenu()
        onLogout()
    }
}

#Preview {
    MainScreenView(session: AuthSession(token: "mock", username: "marcus", fullName: "Marcus Cole"))
}
