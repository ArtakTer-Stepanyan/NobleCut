//
//  SideMenuView.swift
//  NobleCut
//
//  Created by OpenAI Codex on 30.04.26.
//

import SwiftUI

struct SideMenuView: View {
    static let drawerWidth: CGFloat = 320
    static let hiddenOffset: CGFloat = drawerWidth + 40

    let session: AuthSession
    let onClose: () -> Void
    let onLogout: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                infoSection
                Spacer(minLength: 24)
                footerSection
            }
            .frame(width: Self.drawerWidth)
            .frame(maxHeight: .infinity, alignment: .topLeading)
            .background(menuBackground)
            .clipShape(RoundedCornersShape(radius: 34, corners: [.topRight, .bottomRight]))
            .overlay(alignment: .trailing) {
                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 1)
            }
            .shadow(color: .black.opacity(0.34), radius: 24, x: 12, y: 0)

            Spacer(minLength: 0)
        }
        .ignoresSafeArea()
        .padding(.top, 32)
    }

    private var headerSection: some View {
        ZStack(alignment: .topLeading) {
            Image("home_desc_background")
                .resizable()
                .scaledToFill()
                .frame(height: 246)
                .clipped()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.18),
                    Color.black.opacity(0.36),
                    Color.black.opacity(0.88)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Button {
                        onClose()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold, design: .serif))
                            .foregroundStyle(.white.opacity(0.86))
                            .frame(width: 38, height: 38)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.42))
                            )
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }

                Spacer()

                VStack(alignment: .leading, spacing: 10) {
                    Text("ACCOUNT")
                        .font(.system(size: 12, weight: .semibold, design: .serif))
                        .kerning(1.8)
                        .foregroundStyle(.appYellow)

                    Text(session.fullName)
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(4)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("@\(session.username)")
                        .font(.system(size: 15, weight: .medium, design: .serif))
                        .foregroundStyle(.white.opacity(0.72))
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 18)
            .padding(.bottom, 24)
        }
        .frame(height: 246)
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 10) {
                Text("NOBLECUT")
                    .font(.system(size: 18, weight: .medium, design: .serif))
                    .foregroundStyle(.appYellow)

                Text("Your SmartAppt session is active. The JWT is cached on this device until it expires or you log out.")
                    .font(.system(size: 15, weight: .regular, design: .serif))
                    .foregroundStyle(.white.opacity(0.68))
                    .lineSpacing(6)
            }

            VStack(alignment: .leading, spacing: 12) {
                menuInfoRow(
                    title: "Session",
                    value: "SmartAppt JWT cached locally"
                )

                menuInfoRow(
                    title: "Status",
                    value: "Signed in"
                )
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 26)
    }

    private var footerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Leave the chair?")
                .font(.system(size: 14, weight: .medium, design: .serif))
                .foregroundStyle(.white.opacity(0.58))

            Button {
                onLogout()
            } label: {
                HStack {
                    Text("LOG OUT")
                        .font(.system(size: 15, weight: .bold, design: .serif))
                        .tracking(0.6)

                    Spacer()

                    Image(systemName: "arrow.backward")
                        .font(.system(size: 15, weight: .semibold, design: .serif))
                }
                .foregroundStyle(Color.black.opacity(0.82))
                .padding(.horizontal, 18)
                .frame(height: 56)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.appYellow)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 22)
        .padding(.top, 16)
        .padding(.bottom, 42)
    }

    private var menuBackground: some View {
        ZStack {
            Color.black

            LinearGradient(
                colors: [
                    Color.white.opacity(0.04),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private func menuInfoRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold, design: .serif))
                .kerning(1.1)
                .foregroundStyle(.white.opacity(0.42))

            Text(value)
                .font(.system(size: 16, weight: .medium, design: .serif))
                .foregroundStyle(.white.opacity(0.88))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.darkGray.opacity(0.48))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        }
    }
}

#Preview {
    SideMenuView(
        session: AuthSession(token: "mock", username: "marcus", fullName: "Marcus Cole"),
        onClose: {},
        onLogout: {}
    )
    .preferredColorScheme(.dark)
}
