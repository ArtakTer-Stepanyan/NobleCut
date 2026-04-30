//
//  HomeDescriptionCardView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 22.04.26.
//

import SwiftUI

struct HomeDescriptionCardView: View {
    private let cardHeight: CGFloat = 420
    private let imageHorizontalInset: CGFloat = 6

    var body: some View {
        GeometryReader { proxy in
            let imageWidth = max(proxy.size.width - (imageHorizontalInset * 2), 0)

            ZStack {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(Color.black)

                ZStack(alignment: .bottomLeading) {
                    Image("home_desc_background")
                        .resizable()
                        .scaledToFill()
                        .frame(width: imageWidth, height: cardHeight)
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
                    .frame(width: imageWidth, height: cardHeight)

                    VStack(alignment: .leading, spacing: 18) {
                        Text("home_title")
                            .font(.system(size: 42, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(4)

                        Text("Precision grooming meet timeless luxury. Book your chair at the city's finest")
                            .font(.system(size: 18, weight: .regular, design: .serif))
                            .foregroundColor(.white.opacity(0.85))
                            .lineSpacing(10)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                }
                .frame(width: imageWidth, height: cardHeight)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
            .frame(width: proxy.size.width, height: cardHeight)
        }
        .frame(maxWidth: .infinity)
        .frame(height: cardHeight)
        .shadow(color: .black.opacity(0.25), radius: 18, x: 0, y: 10)
        .padding()
    }
}

#Preview {
    HomeDescriptionCardView()
}
