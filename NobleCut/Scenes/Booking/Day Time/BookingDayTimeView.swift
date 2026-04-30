//
//  BookingDayTimeView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 27.04.26.
//

import SwiftUI

struct BookingDayTimeView: View {
    let title: String
    let isSelected: Bool
    var isDisabled: Bool = false
    
    var body: some View {
        Text(title)
            .font(.system(size: 15, weight: .semibold, design: .serif))
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(borderColor, lineWidth: 1.2)
            )
            .opacity(isDisabled ? 0.38 : 1)
            .strikethrough(isDisabled, color: .white.opacity(0.18))
    }

    private var foregroundColor: Color {
        if isDisabled {
            return .white.opacity(0.42)
        }

        return isSelected ? .appYellow : .white.opacity(0.82)
    }

    private var backgroundColor: Color {
        if isDisabled {
            return .white.opacity(0.01)
        }

        return isSelected ? Color.appYellow.opacity(0.08) : Color.darkGray.opacity(0.22)
    }

    private var borderColor: Color {
        if isDisabled {
            return .white.opacity(0.06)
        }

        return isSelected ? .appYellow : Color.white.opacity(0.08)
    }
}

#Preview {
    BookingDayTimeView(title: "09:45 AM", isSelected: true)
}
