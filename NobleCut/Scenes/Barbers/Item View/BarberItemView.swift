//
//  BarberItemView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 27.04.26.
//

import SwiftUI

struct BarberItemView: View {
    let barberDetails: BarberDetails
    
    var body: some View {
        VStack(spacing: 0) {
            
            ZStack {
                Image(.barberMarcus)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .clipped()
                
                LinearGradient(
                    colors: [
                        .clear,
                        Color("Dark Gray").opacity(0.35),
                        Color("Dark Gray").opacity(0.75),
                        Color("Dark Gray")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 300)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Text(barberDetails.name)
                    .font(.system(size: 32, weight: .medium, design: .serif))
                    .foregroundStyle(.white)
                    .padding(.top)
                Text(barberDetails.specialty.title.uppercased())
                    .font(.system(size: 13, weight: .semibold, design: .serif))
                    .foregroundStyle(.appYellow)
                    .padding(.top)
                
                Text(barberDetails.description)
                    .font(.system(size: 16, design: .serif))
                    .foregroundStyle(.textGray)
                    .padding(.vertical)
            }
            .padding()

            
            HStack() {
                Button {
                    // action
                } label: {
                    Text("VIEW\nPROFILE")
                        .font(.system(size: 16, weight: .medium, design: .serif))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .frame(maxWidth: 160)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.appYellow)
                        )
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button {
                } label: {
                    Image(systemName: "calendar")
                        .font(.system(size: 20, weight: .regular, design: .serif))
                        .foregroundStyle(.textGray)
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button {
                } label: {
                    Image(systemName: "scissors")
                        .font(.system(size: 20, weight: .regular, design: .serif))
                        .foregroundStyle(.textGray)
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button {
                } label: {
                    Image(systemName: "message")
                        .font(.system(size: 20, weight: .regular, design: .serif))
                        .foregroundStyle(.textGray)
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(.plain)
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("Dark Gray"))
        )
        .padding(.horizontal)
    }
}

#Preview {
        BarberItemView(
            barberDetails: .init(
                image: "barber_julian",
                name: "Julian Thorne",
                specialty: .haircut,
                description: "With over 15 years of experience in London's premier grooming houses, Julian specializes in architectural fades and traditional straight-razor finishes."
            )
        )
        .padding(20)
    
}
