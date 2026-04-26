//
//  BarbersView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 24.04.26.
//

import SwiftUI

struct BarbersView: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack {
                BarbersHeaderView()
                
                BarbersListView(barbers: [
                    .init(id: Int.random(in: 0...10), name: "Marcus", specialty: "STYLING MASTER"),
                    .init(id: Int.random(in: 11...20), name: "John", specialty: "STEAMING MASTER"),
                ])
                .padding(.leading, 21)
            }
        }
    }
}

#Preview {
    BarbersView()
}
