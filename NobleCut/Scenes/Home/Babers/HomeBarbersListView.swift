//
//  HomeBarbersListView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 24.04.26.
//

import SwiftUI

struct HomeBarbersListView: View {
    
    let barbers: [Barber]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 22) {
                ForEach(barbers) { barber in
                    HomeBarbersListItemView(name: barber.name, specialty: barber.specialty)
                }
            }
        }
    }
}

#Preview {
    HomeBarbersListView(
        barbers: [
            .init(id: Int.random(in: 0...10), name: "Marcus", specialty: "STYLING MASTER"),
            .init(id: Int.random(in: 11...20), name: "John", specialty: "STEAMING MASTER"),
        ])
}
