//
//  MainScreenView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 26.04.26.
//

import SwiftUI

struct MainScreenView: View {
    
    @State private var selection: Int = 0
    
    var body: some View {
        TabView(selection: $selection) {
            Tab("Home", systemImage: "house", value: 0) {
                HomeView()
            }


            Tab("Services", systemImage: "scissors", value: 1) {
                ServiceView()
            }


            Tab("Barbers", systemImage: "person.2", value: 2) {
                BarbersView()
            }
            
            Tab("Reservations", systemImage: "calendar", value: 3) {
                ReservationView()
            }
        }
        .tint(.appYellow)
    }
}

#Preview {
    MainScreenView()
}
