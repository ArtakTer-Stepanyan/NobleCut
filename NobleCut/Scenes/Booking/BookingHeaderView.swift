//
//  BookingHeaderView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 27.04.26.
//

import SwiftUI

struct BookingHeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("BOOKING SELECTION")
                .font(.system(size: 18))
                .foregroundStyle(.appYellow)
            
            Text("Select Date & Time")
                .font(.system(size: 16))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: 175, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.darkGray)
        )
        .padding(.horizontal)
    }
}

#Preview {
    BookingHeaderView()
}
