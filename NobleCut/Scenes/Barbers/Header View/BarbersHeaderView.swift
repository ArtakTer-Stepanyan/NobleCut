//
//  BarbersHeaderView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 27.04.26.
//

import SwiftUI

struct BarbersHeaderView: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 18) {
                Text("Select Your Master")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(Color.white)
                
                Text("Choose from our curated collective of grooming specialists, each bringing a unique heritage of precision and style.")
                    .font(.system(size: 18, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.textGray)
                
            }
        }
    }
}

#Preview {
    BarbersHeaderView()
}
