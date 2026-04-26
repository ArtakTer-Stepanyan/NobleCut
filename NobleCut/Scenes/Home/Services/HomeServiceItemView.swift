//
//  HomeServiceItemView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 26.04.26.
//

import SwiftUI

struct HomeServiceItemView: View {
    
    let service: Service
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            Image(service.type.iconName)
            VStack(alignment: .leading, spacing: 10) {
                Text(service.type.title)
                    .font(.system(size: 22))
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                    .foregroundStyle(Color.white)
                Text(service.type.description)
                    .font(.system(size: 16))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .foregroundStyle(Color.textGray)
            }
            
            Text("$\(service.price)")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.appYellow)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 36)
        .frame(maxWidth: .greatestFiniteMagnitude, maxHeight: 130)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.darkGray))
        .padding(.horizontal)
    }
}

#Preview {
    HomeServiceItemView(service: .init(id: 0, type: .deluxe, price: 45))
}
