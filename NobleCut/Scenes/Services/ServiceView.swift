//
//  ServiceView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 26.04.26.
//

import SwiftUI

struct ServiceView: View {

    @StateObject private var viewModel: ServiceViewModel
    @State private var isContentVisible = false
    @State private var hasAnimatedOnce = false
    private let onMenuTap: (() -> Void)?
    private let onSelectService: (Service) -> Void

    @MainActor
    init(
        viewModel: ServiceViewModel? = nil,
        onMenuTap: (() -> Void)? = nil,
        onSelectService: @escaping (Service) -> Void = { _ in }
    ) {
        _viewModel = StateObject(wrappedValue: viewModel ?? ServiceViewModel())
        self.onMenuTap = onMenuTap
        self.onSelectService = onSelectService
    }

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    NavigationBar(onMenuTap: onMenuTap)
                        .screenEntrance(isVisible: isContentVisible)

                    ServiceHeaderView()
                        .screenEntrance(isVisible: isContentVisible, delay: 0.08)

                    if viewModel.isLoading && viewModel.sections.isEmpty {
                        ProgressView()
                            .tint(.appYellow)
                            .padding(.top, 60)
                    } else {
                        VStack(alignment: .leading, spacing: 33) {
                            ForEach(Array(viewModel.sections.enumerated()), id: \.element.id) { indexedSection in
                                let section = indexedSection.element
                                let sectionIndex = indexedSection.offset

                                HStack(spacing: 16) {
                                    Image(section.type.iconName)
                                    Text(section.type.sectionTitle)
                                        .font(.system(size: 32, design: .serif))
                                        .foregroundStyle(Color.white)
                                }
                                .padding(.horizontal, 12)
                                .screenEntrance(
                                    isVisible: isContentVisible,
                                    delay: sectionDelay(for: sectionIndex)
                                )

                                ForEach(Array(section.services.enumerated()), id: \.element.id) { indexedService in
                                    ServiceItemView(service: indexedService.element) {
                                        onSelectService(indexedService.element)
                                    }
                                    .screenEntrance(
                                        isVisible: isContentVisible,
                                        delay: serviceDelay(
                                            sectionIndex: sectionIndex,
                                            serviceIndex: indexedService.offset
                                        )
                                    )
                                }
                            }
                        }
                        .padding(.top, 32)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
            }
        }
        .task {
            await viewModel.loadServices()
        }
        .onAppear {
            guard !hasAnimatedOnce else {
                isContentVisible = true
                return
            }
            
            hasAnimatedOnce = true
            isContentVisible = true
        }
    }
    
    private func sectionDelay(for sectionIndex: Int) -> Double {
        0.18 + (Double(sectionIndex) * 0.14)
    }
    
    private func serviceDelay(sectionIndex: Int, serviceIndex: Int) -> Double {
        0.26 + (Double(sectionIndex) * 0.2) + (Double(serviceIndex) * 0.08)
    }
}

#Preview {
    ServiceView()
}
