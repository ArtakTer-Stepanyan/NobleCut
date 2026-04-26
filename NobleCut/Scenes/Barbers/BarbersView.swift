//
//  BarbersView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 27.04.26.
//

import SwiftUI

struct BarbersView: View {
    
    @StateObject var viewModel: BarbersViewModel = BarbersViewModel()
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    NavigationBar()
                    BarbersHeaderView()
                    
                    VStack(spacing: 50) {
                        ForEach(viewModel.barbers) { item in
                            BarberItemView(barberDetails: item)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 20)
        }
    }
}

#Preview {
    BarbersView()
}
