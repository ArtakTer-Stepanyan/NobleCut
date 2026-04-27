//
//  ScreenEntranceModifier.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 27.04.26.
//

import SwiftUI

struct ScreenEntranceModifier: ViewModifier {
    let isVisible: Bool
    let delay: Double

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 18)
            .scaleEffect(isVisible ? 1 : 0.985, anchor: .top)
            .animation(.easeOut(duration: 0.7).delay(delay), value: isVisible)
    }
}

extension View {
    func screenEntrance(isVisible: Bool, delay: Double = 0) -> some View {
        modifier(ScreenEntranceModifier(isVisible: isVisible, delay: delay))
    }
}
