//
//  HomeView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 22.04.26.
//

import SwiftUI

struct HomeView: View {
    

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack() {
                    NavigationBar()
                    HomeDescriptionCardView()
                    HomeBarbersView()
                    HomeServiceView(services: [
                        .init(id: 0, type: .haircut, price: 45),
                        .init(id: 1, type: .trim, price: 38),
                        .init(id: 2, type: .deluxe, price: 60),
                    ])
                    .padding(.top, 26)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    HomeView()
}
