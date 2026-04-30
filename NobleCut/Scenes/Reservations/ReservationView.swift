//
//  ReservationView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 30.04.26.
//

import SwiftUI

struct ReservationView: View {

    @StateObject private var viewModel: ReservationViewModel

    @MainActor
    init(viewModel: ReservationViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? ReservationViewModel())
    }

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                NavigationBar()
                if !viewModel.reservations.isEmpty {
                    ScrollView(.vertical) {
                        VStack(spacing: 16) {
                            ForEach(viewModel.reservations) { reservation in
                                ReservationItemView(reservation: reservation)
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
                            .font(.system(size: 30))
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
    }
}

#Preview {
    ReservationView()
}
