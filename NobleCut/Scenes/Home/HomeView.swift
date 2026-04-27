//
//  HomeView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 22.04.26.
//

import SwiftUI

struct HomeView: View {
    @State private var isContentVisible = false
    @State private var hasAnimatedOnce = false

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack() {
                    NavigationBar()
                        .screenEntrance(isVisible: isContentVisible)
                    
                    HomeDescriptionCardView()
                        .screenEntrance(isVisible: isContentVisible, delay: 0.08)
                    
                    HomeBarbersView()
                        .screenEntrance(isVisible: isContentVisible, delay: 0.18)
                    
                    HomeServiceView(services: [
                        .init(id: 0, type: .haircut, price: 45),
                        .init(id: 1, type: .trim, price: 38),
                        .init(id: 2, type: .deluxe, price: 60),
                    ])
                    .padding(.top, 26)
                    .screenEntrance(isVisible: isContentVisible, delay: 0.28)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            guard !hasAnimatedOnce else {
                isContentVisible = true
                return
            }
            
            hasAnimatedOnce = true
            isContentVisible = true
        }
    }
}

#Preview {
    HomeView()
}
