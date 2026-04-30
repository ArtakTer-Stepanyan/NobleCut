//
//  ServiceViewModel.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 26.04.26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class ServiceViewModel: ObservableObject {
    @Published private(set) var sections: [ServiceSection] = []
    @Published private(set) var isLoading = false

    private let repository: any ServiceRepositoryProtocol
    private var hasLoaded = false

    init(repository: (any ServiceRepositoryProtocol)? = nil) {
        self.repository = repository ?? ServiceRepository()
    }

    func loadServices() async {
        guard !hasLoaded else { return }

        isLoading = true
        sections = await repository.fetchServiceSections()
        isLoading = false
        hasLoaded = true
    }
}
