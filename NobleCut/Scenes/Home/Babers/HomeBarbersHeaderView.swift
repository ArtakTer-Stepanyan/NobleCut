//
//  HomeBarbersHeaderView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 24.04.26.
//

import SwiftUI

struct HomeBarbersHeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Rated Barbers")
                .font(.system(size: 32))
                .fontWeight(.bold)
                .foregroundStyle(Color.white)
                
            Text("Meet our master craftsmen")
                .font(.system(size: 24))
                .fontWeight(.regular)
                .foregroundStyle(Color.gray)
            
        }
        .frame(height: 120)
        .frame(width: .infinity)
        .padding()
        .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.black)
                )
        .padding(.trailing, 40)
        
        
    }
}

#Preview {
    HomeBarbersHeaderView()
}
