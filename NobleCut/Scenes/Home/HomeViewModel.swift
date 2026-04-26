//
//  HomeViewModel.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 24.04.26.
//

import Foundation
import SwiftUI
import Combine

struct BarbersViewState {
    var barbers: [Barber] = []
}

class HomeViewModel: ObservableObject {
    @SwiftUI.Published var barbers: [Barber] = []
}

