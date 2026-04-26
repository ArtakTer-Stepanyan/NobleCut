//
//  HomeServiceView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 26.04.26.
//

import SwiftUI

struct HomeServiceView: View {
    let services: [Service]
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            VStack(alignment: .leading, spacing: 24) {
                Text("Popular Services")
                    .foregroundStyle(Color.white)
                    .font(.system(size: 32))
                    .padding(.leading, 16)
                
                VStack(spacing: 16) {
                    ForEach(services) { service in
                        HomeServiceItemView(service: service)
                    }
                }
                
            }
        }
    }
}

#Preview {
    HomeServiceView(
        services: [
            .init(id: 0, type: .haircut, price: 45),
            .init(id: 1, type: .trim, price: 38),
            .init(id: 2, type: .deluxe, price: 60),
        ]
    )
}
