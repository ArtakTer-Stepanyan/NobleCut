//
//  BookingRepository.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 28.04.26.
//

import Foundation

class BookingRepository {
    var defaultSelectedTimeID: String {
        "afternoon-01:15 PM"
    }

    func getTimeSections() -> [BookingTimeSection] {
        [
            .init(
                title: "Morning",
                iconName: "morning_icon",
                slots: [
                    .init(id: "morning-09:00 AM", title: "09:00 AM"),
                    .init(id: "morning-09:45 AM", title: "09:45 AM"),
                    .init(id: "morning-10:30 AM", title: "10:30 AM"),
                    .init(id: "morning-11:15 AM", title: "11:15 AM")
                ]
            ),
            .init(
                title: "Afternoon",
                iconName: "afternoon_icon",
                slots: [
                    .init(id: "afternoon-12:30 PM", title: "12:30 PM"),
                    .init(id: "afternoon-01:15 PM", title: "01:15 PM"),
                    .init(id: "afternoon-02:00 PM", title: "02:00 PM"),
                    .init(id: "afternoon-02:45 PM", title: "02:45 PM"),
                    .init(id: "afternoon-03:30 PM", title: "03:30 PM"),
                    .init(id: "afternoon-04:15 PM", title: "04:15 PM", isDisabled: true)
                ]
            ),
            .init(
                title: "Evening",
                iconName: "evening_icon",
                slots: [
                    .init(id: "evening-05:00 PM", title: "05:00 PM"),
                    .init(id: "evening-05:45 PM", title: "05:45 PM"),
                    .init(id: "evening-06:30 PM", title: "06:30 PM")
                ]
            )
        ]
    }
}

struct BookingTimeSection: Identifiable {
    let title: String
    let iconName: String
    let slots: [BookingTimeSlot]

    var id: String { title }
}

struct BookingTimeSlot: Identifiable {
    let id: String
    let title: String
    var isDisabled: Bool = false
}
