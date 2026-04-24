//
//  BarbersListView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 24.04.26.
//

import SwiftUI

struct BarbersListView: View {
    
    let barbers: [Barber]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(barbers) { barber in
                    BarbersListItemView(name: barber.name, specialty: barber.specialty)
                }
            }
        }
    }
}

#Preview {
    BarbersListView(
        barbers: [
            .init(id: Int.random(in: 0...10), name: "Marcus", specialty: "STYLING MASTER"),
            .init(id: Int.random(in: 11...20), name: "John", specialty: "STEAMING MASTER"),
        ])
}
