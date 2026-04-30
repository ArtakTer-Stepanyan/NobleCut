//
//  ReservationView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 30.04.26.
//

import SwiftUI

struct ReservationView: View {

    @StateObject private var viewModel: ReservationViewModel
    private let onMenuTap: (() -> Void)?

    @MainActor
    init(
        viewModel: ReservationViewModel? = nil,
        onMenuTap: (() -> Void)? = nil
    ) {
        _viewModel = StateObject(wrappedValue: viewModel ?? ReservationViewModel())
        self.onMenuTap = onMenuTap
    }

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                NavigationBar(onMenuTap: onMenuTap)
                if !viewModel.reservations.isEmpty {
                    ScrollView(.vertical) {
                        VStack(spacing: 16) {
                            ForEach(viewModel.reservations) { reservation in
                                Button {
                                    viewModel.promptCancellation(for: reservation)
                                } label: {
                                    ReservationItemView(reservation: reservation)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, 20)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                } else if viewModel.isLoading {
                    VStack {
                        Spacer()
                        ProgressView()
                            .tint(.appYellow)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack {
                        Spacer()
                        Text("You have no reservation")
                            .foregroundStyle(.white)
                            .font(.system(size: 30, design: .serif))
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadReservations()
            }
        }
        .alert(
            "Cancel Reservation?",
            isPresented: isCancellationAlertPresented,
            presenting: viewModel.reservationPendingCancellation
        ) { reservation in
            Button("No", role: .cancel) {
                viewModel.dismissCancellationPrompt()
            }

            Button("Yes", role: .destructive) {
                Task {
                    await viewModel.cancelReservation(reservation)
                }
            }
        } message: { reservation in
            Text("Do you want to cancel your \(reservation.service.type.title) reservation?")
        }
    }

    private var isCancellationAlertPresented: Binding<Bool> {
        Binding(
            get: {
                viewModel.reservationPendingCancellation != nil
            },
            set: { isPresented in
                if !isPresented {
                    viewModel.dismissCancellationPrompt()
                }
            }
        )
    }
}

#Preview {
    ReservationView()
}
