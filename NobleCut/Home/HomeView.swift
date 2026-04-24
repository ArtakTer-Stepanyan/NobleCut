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
            
            ScrollView {
                VStack {
                    NavigationBar()
                    HomeDescriptionCardView()
                    BarbersView()
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
