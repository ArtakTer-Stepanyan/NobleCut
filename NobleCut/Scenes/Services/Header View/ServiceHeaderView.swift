//
//  ServiceHeaderView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 26.04.26.
//

import SwiftUI

struct ServiceHeaderView: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 18) {
                Text("Select Your Service")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(Color.white)
                
                Text("Precision grooming tailored to your unique style. Choose from our curated menu of heritage barbering services.")
                    .font(.system(size: 18, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.textGray)
                
            }
        }
    }
}

#Preview {
    ServiceHeaderView()
}
