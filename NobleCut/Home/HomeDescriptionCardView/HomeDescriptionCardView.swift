//
//  HomeDescriptionCardView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 22.04.26.
//

import SwiftUI

struct HomeDescriptionCardView: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("home_desc_background")
                .resizable()
                .scaledToFill()
                .frame(height: 420)
                .clipped()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.15),
                    Color.black.opacity(0.35),
                    Color.black.opacity(0.72)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 18) {
                Text("home_title")
                    .font(.system(size: 42, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)

                Text("Precision grooming meet timeless luxury. Book your chair at the city's finest")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.white.opacity(0.85))
                    .lineSpacing(10)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 28)
        }
        .frame(height: 420)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: .black.opacity(0.25), radius: 18, x: 0, y: 10)
        .padding()
    }
}

#Preview {
    HomeDescriptionCardView()
}
