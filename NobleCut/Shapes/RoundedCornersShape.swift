//
//  RoundedCornersShape.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 24.04.26.
//

import SwiftUI

struct RoundedCornersShape: Shape {
    var radius: CGFloat = 12
    var corners: UIRectCorner = [.bottomLeft, .bottomRight]

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
