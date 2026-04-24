//
//  NavigationBar.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 25.04.26.
//

import SwiftUI

import SwiftUI

struct NavigationBar: View {
    var onMenuTap: (() -> Void)?

    var body: some View {
        HStack(spacing: 24) {
            Button {
                onMenuTap?()
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundStyle(Color.yellow)
            }

            Text("NOBLECUT")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundStyle(Color.yellow)

            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .background(Color.black)
        .padding(.horizontal, 26)
    }
}

#Preview {
    NavigationBar()
}
