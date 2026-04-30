//
//  NavigationBar.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 25.04.26.
//

import SwiftUI

struct NavigationBar: View {
    var onMenuTap: (() -> Void)?

    var body: some View {
        HStack(spacing: 18) {
            Button {
                onMenuTap?()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.darkGray.opacity(0.72))

                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .foregroundStyle(Color.appYellow)
                }
                .frame(width: 46, height: 46)
            }
            .buttonStyle(.plain)

            Text("NOBLECUT")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundStyle(Color.appYellow)

            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .background(Color.black)
    }
}

#Preview {
    NavigationBar()
}
