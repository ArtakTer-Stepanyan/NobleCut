//
//  NobleCutApp.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 22.04.26.
//

import SwiftUI

@main
struct NobleCutApp: App {
    private let appContainer = AppContainer()

    var body: some Scene {
        WindowGroup {
            MainScreenView(appContainer: appContainer)
                .preferredColorScheme(.dark)
        }
    }
}
