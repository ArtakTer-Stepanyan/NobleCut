//
//  ReservationItemView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 29.04.26.
//

import SwiftUI

struct ReservationItemView: View {
    let reservation: Reservation

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 20) {
                Image(reservation.service.type.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(reservation.service.displayTitle)
                        .font(.system(size: 20, design: .serif))
                        .foregroundStyle(.white)
                    
                    Text("$\(reservation.service.price) • \(reservation.service.duration) min")
                        .font(.system(size: 18, design: .serif))
                        .foregroundStyle(.appYellow)
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                    Image(systemName: "calendar")
                        .foregroundStyle(.white)
                    Text(reservation.scheduledAt.formattedReservationDate)
                        .foregroundStyle(Color.white)
                }
                HStack(spacing: 16) {
                    Image(systemName: "clock")
                        .foregroundStyle(.white)
                    Text(reservation.scheduledAt.formattedReservationTime)
                        .foregroundStyle(Color.white)
                }
            }
        }
        .padding(.vertical, 20)
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
    ReservationItemView(
        reservation: Reservation(
            service: .init(id: 0, type: .deluxe, price: 85, duration: 60),
            scheduledAt: Date()
        )
    )
}

private extension Date {
    var formattedReservationDate: String {
        formatted(.dateTime.weekday(.wide).month(.wide).day())
    }

    var formattedReservationTime: String {
        formatted(.dateTime.hour().minute())
    }
}
