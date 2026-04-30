//
//  ServiceItemView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 26.04.26.
//

import SwiftUI

struct ServiceItemView: View {
    let service: Service
    let onSelect: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(service.type.title)
                        .font(.system(size: 22, weight: .semibold, design: .serif))
                        .minimumScaleFactor(0.8)
                        .foregroundStyle(Color.white)
                    
                    Spacer()
                    
                    Text("$\(service.price)")
                        .font(.system(size: 22, design: .serif))
                        .foregroundStyle(Color.appYellow)
                }
                
                Text(service.type.description)
                    .font(.system(size: 14, design: .serif))
                    .foregroundStyle(Color.textGray)
            }
        
            HStack {
                Text("\(service.duration) MIN")
                    .foregroundStyle(Color.textGray)
                    .font(.system(size: 12, design: .serif))
                
                Spacer()
                
                Button(action: onSelect) {
                    Text("SELECT")
                        .font(.system(size: 18, weight: .medium, design: .serif))
                        .foregroundStyle(.appYellow)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(.appYellow, lineWidth: 2)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .frame(maxWidth: .greatestFiniteMagnitude, maxHeight: 175)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.darkGray))
        .padding(.horizontal)
    }
}

#Preview {
    ServiceItemView(service: .init(id: 1, type: .haircut, price: 45, duration: 20)) {}
}
