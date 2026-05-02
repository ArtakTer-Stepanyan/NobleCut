//
//  BookingHeaderView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 27.04.26.
//

import SwiftUI

struct BookingHeaderView: View {
    let service: Service

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("BOOKING SELECTION")
                .font(.system(size: 18, design: .serif))
                .foregroundStyle(.appYellow)

            Text(service.displayTitle)
                .font(.system(size: 28, weight: .semibold, design: .serif))
                .foregroundStyle(.white)

            Text("\(service.displayDescription) • \(service.duration) min • $\(service.price)")
                .font(.system(size: 16, design: .serif))
                .foregroundStyle(Color.textGray)

            Text("Select a date and time to confirm your reservation.")
                .font(.system(size: 15, design: .serif))
                .foregroundStyle(.white.opacity(0.82))
        }
        .frame(maxWidth: .infinity, minHeight: 175, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.darkGray)
        )
        .padding(.horizontal)
    }
}

#Preview {
    BookingHeaderView(service: .init(id: 0, type: .haircut, price: 45, duration: 35))
}
