//
//  BookingViewModel.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 28.04.26.
//

import Foundation
import SwiftUI
import Combine

struct BookingViewState {
    var selectedTimeID: String
    var timeSections: [BookingTimeSection]
}

class BookingViewModel: ObservableObject {
    @SwiftUI.Published private(set) var state: BookingViewState

    private let repository: BookingRepository

    init(repository: BookingRepository = BookingRepository()) {
        self.repository = repository
        self.state = BookingViewState(
            selectedTimeID: repository.defaultSelectedTimeID,
            timeSections: repository.getTimeSections()
        )
    }

    func selectTime(_ slot: BookingTimeSlot) {
        guard !slot.isDisabled else { return }
        state.selectedTimeID = slot.id
    }

    func isSelected(_ slot: BookingTimeSlot) -> Bool {
        state.selectedTimeID == slot.id
    }
}
