//
//  BookingItemView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 27.04.26.
//

import SwiftUI

struct BookingItemView: View {
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: "scissors")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.appYellow)
                .frame(width: 28, height: 28)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Master Grooming")
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
                
                Text("$85 • 30 min")
                    .font(.system(size: 18))
                    .foregroundStyle(.appYellow)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 175, alignment: .leading)
        .padding(.leading, 32)
        .padding(.trailing, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.darkGray)
        )
        .padding(.horizontal)
    }
}

#Preview {
    BookingItemView()
}
