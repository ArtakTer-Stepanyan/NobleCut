//
//  ReservationItemView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 29.04.26.
//

import SwiftUI

struct ReservationItemView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
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
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                    Image(systemName: "calendar")
                        .foregroundStyle(.white)
                    Text("Monday, May 3")
                        .foregroundStyle(Color.white)
                }
                HStack(spacing: 16) {
                    Image(systemName: "clock")
                        .foregroundStyle(.white)
                    Text("12:45 PM")
                        .foregroundStyle(Color.white)
                }
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
    ReservationItemView()
}
