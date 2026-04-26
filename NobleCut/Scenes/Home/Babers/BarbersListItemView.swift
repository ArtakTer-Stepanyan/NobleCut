//
//  BarbersListItemView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 24.04.26.
//

import SwiftUI

struct BarbersListItemView: View {
    
    let name: String
    let specialty: String
    
    var body: some View {
        VStack(spacing: 0) {
            
            Image(.barberMarcus)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .clipped()

            VStack(spacing: 0) {
                Text(name)
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                    .padding(.top)
                Text(specialty)
                    .font(.system(size: 13))
                    .foregroundStyle(.white)
                    .padding()
            }
            .frame(maxWidth: .infinity)
            .background(
                RoundedCornersShape(radius: 12, corners: [.bottomLeft, .bottomRight])
                    .fill(Color("Dark Gray"))
            )
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    BarbersListItemView(name: "Marcus", specialty: "SENIOR MASTER STYLIST")
}
