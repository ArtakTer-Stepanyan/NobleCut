//
//  AppFlowView.swift
//  NobleCut
//
//  Created by OpenAI Codex on 30.04.26.
//

import SwiftUI

struct AppFlowView: View {
    @StateObject private var sessionViewModel: AppSessionViewModel
    @StateObject private var authViewModel: AuthViewModel
    private let appContainer: AppContainer

    @MainActor
    init(appContainer: AppContainer? = nil) {
        let resolvedContainer = appContainer ?? AppContainer()
        self.appContainer = resolvedContainer

        let sessionViewModel = resolvedContainer.makeAppSessionViewModel()
        _sessionViewModel = StateObject(wrappedValue: sessionViewModel)
        _authViewModel = StateObject(
            wrappedValue: resolvedContainer.makeAuthFlowViewModel { [weak sessionViewModel] session in
                sessionViewModel?.handleAuthenticated(session)
            }
        )
    }

    var body: some View {
        Group {
            switch sessionViewModel.state {
            case .loading:
                loadingView
            case .unauthenticated:
                AuthView(viewModel: authViewModel)
            case .authenticated(let session):
                MainScreenView(
                    appContainer: appContainer,
                    session: session,
                    onLogout: handleLogout
                )
            }
        }
        .task {
            await sessionViewModel.restoreSessionIfNeeded()
        }
    }

    private var loadingView: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Text("NOBLECUT")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(.appYellow)

                ProgressView()
                    .tint(.appYellow)

                Text("Restoring your session")
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .foregroundStyle(.white.opacity(0.72))
            }
        }
    }

    private func handleLogout() {
        Task {
            await sessionViewModel.logout()
            authViewModel.prepareForLoggedOutState()
        }
    }
}

#Preview {
    AppFlowView()
        .preferredColorScheme(.dark)
}
