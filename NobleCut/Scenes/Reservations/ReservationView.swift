//
//  ReservationView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 30.04.26.
//

import SwiftUI

struct ReservationView: View {
    
    @StateObject var viewModel: ReservationViewModel = ReservationViewModel()

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            if !viewModel.reservations.isEmpty {
            ScrollView(.vertical) {
                    VStack {
                        ForEach(viewModel.reservations) { reservation in
                            ReservationItemView()
                        }
                    }
                }
            } else {
                Text("You have no reservation")
                    .foregroundStyle(.white)
                    .font(.system(size: 30))
            }
        }
    }
}

#Preview {
    ReservationView()
}
