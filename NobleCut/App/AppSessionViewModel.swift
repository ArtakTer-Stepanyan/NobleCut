//
//  AppSessionViewModel.swift
//  NobleCut
//
//  Created by OpenAI Codex on 30.04.26.
//

import Combine
import Foundation

enum AppSessionState {
    case loading
    case unauthenticated
    case authenticated(AuthSession)
}

@MainActor
final class AppSessionViewModel: ObservableObject {
    @Published private(set) var state: AppSessionState = .loading

    private let repository: any AuthRepositoryProtocol
    private var hasAttemptedRestore = false

    init(repository: any AuthRepositoryProtocol) {
        self.repository = repository
    }

    func restoreSessionIfNeeded() async {
        guard !hasAttemptedRestore else { return }
        hasAttemptedRestore = true

        if let session = await repository.restoreSession() {
            state = .authenticated(session)
        } else {
            state = .unauthenticated
        }
    }

    func handleAuthenticated(_ session: AuthSession) {
        state = .authenticated(session)
    }

    func logout() async {
        await repository.logout()
        state = .unauthenticated
    }
}
