//
//  ReservationViewModel.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 30.04.26.
//

import Foundation
import SwiftUI
import Combine

class ReservationViewModel: ObservableObject {
    @SwiftUI.Published var reservations: [Reservation] = []
}
