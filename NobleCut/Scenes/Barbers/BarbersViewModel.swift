//
//  BarbersViewModel.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 27.04.26.
//

import Foundation
import SwiftUI
import Combine

class BarbersViewModel: ObservableObject {
    @SwiftUI.Published var barbers: [BarberDetails]
    
    init() {
        self.barbers = [
            .init(image: "barber_julian", name: "Julian Alvarez", specialty: .haircut, description: "With over 15 years of experience in London's premier grooming houses, Julian specializes in architectural fades and traditional straight-razor finishes."),
            .init(image: "barber_julian", name: "Bob Martin", specialty: .beard, description: "With over 10 years of experience in Paris' Barber Shop, bob specializes in shaving and improving beard, giving phenomenal look.")
        ]
    }
}
