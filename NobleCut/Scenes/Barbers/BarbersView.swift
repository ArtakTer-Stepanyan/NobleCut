//
//  BarbersView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 27.04.26.
//

import SwiftUI

struct BarbersView: View {
    
    @StateObject var viewModel: BarbersViewModel = BarbersViewModel()
    @State private var isContentVisible = false
    @State private var hasAnimatedOnce = false
    var onMenuTap: (() -> Void)?
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    NavigationBar(onMenuTap: onMenuTap)
                        .screenEntrance(isVisible: isContentVisible)
                    
                    BarbersHeaderView()
                        .screenEntrance(isVisible: isContentVisible, delay: 0.08)
                    
                    VStack(spacing: 50) {
                        ForEach(Array(viewModel.barbers.enumerated()), id: \.element.id) { indexedBarber in
                            BarberItemView(barberDetails: indexedBarber.element)
                                .screenEntrance(
                                    isVisible: isContentVisible,
                                    delay: 0.18 + (Double(indexedBarber.offset) * 0.12)
                                )
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 20)
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
    BarbersView()
}
