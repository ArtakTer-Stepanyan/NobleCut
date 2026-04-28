//
//  BookingView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 28.04.26.
//

import SwiftUI

struct BookingView: View {
    @StateObject private var viewModel: BookingViewModel
    @State private var isContentVisible = false
    @State private var hasAnimatedOnce = false

    init(viewModel: BookingViewModel = BookingViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    NavigationBar()
                    BookingHeaderView()
                    BookingCalendarView()
                        .screenEntrance(isVisible: isContentVisible)

                    VStack(spacing: 28) {
                        ForEach(Array(viewModel.state.timeSections.enumerated()), id: \.element.id) { indexedSection in
                            timeSectionView(for: indexedSection.element)
                                .screenEntrance(
                                    isVisible: isContentVisible,
                                    delay: 0.08 + (Double(indexedSection.offset) * 0.08)
                                )
                        }
                    }
                    .padding(.horizontal, 16)

                    footer
                        .screenEntrance(isVisible: isContentVisible, delay: 0.32)
                }
                .padding(.top, 18)
                .padding(.bottom, 24)
            }
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

    private func timeSectionView(for section: BookingTimeSection) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionHeader(for: section)
            timeGrid(for: section)
        }
    }

    private func sectionHeader(for section: BookingTimeSection) -> some View {
        HStack(spacing: 10) {
            Image(section.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)

            Text(section.title)
                .font(.system(size: 27, weight: .semibold, design: .serif))
                .foregroundStyle(.white.opacity(0.86))
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.white.opacity(0.05))
                .frame(height: 1)
                .offset(y: 14)
        }
    }

    private func timeGrid(for section: BookingTimeSection) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ],
            spacing: 12
        ) {
            ForEach(section.slots) { slot in
                Button {
                    viewModel.selectTime(slot)
                } label: {
                    BookingDayTimeView(
                        title: slot.title,
                        isSelected: viewModel.isSelected(slot),
                        isDisabled: slot.isDisabled
                    )
                }
                .buttonStyle(.plain)
                .disabled(slot.isDisabled)
            }
        }
    }

    private var footer: some View {
        HStack(spacing: 12) {
            footerButton(
                title: "CANCEL",
                foregroundColor: .appYellow,
                backgroundColor: .clear,
                borderColor: .appYellow,
                isFilled: false
            )

            footerButton(
                title: "CONFIRM\nSELECTION",
                foregroundColor: Color.black.opacity(0.78),
                backgroundColor: .appYellow,
                borderColor: .appYellow,
                isFilled: true
            )
        }
        .padding(.horizontal, 14)
        .padding(.top, 16)
        .padding(.bottom, 12)
        .background(Color.black.opacity(0.96))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.white.opacity(0.05))
                .frame(height: 1)
        }
    }

    private func footerButton(
        title: String,
        foregroundColor: Color,
        backgroundColor: Color,
        borderColor: Color,
        isFilled: Bool
    ) -> some View {
        Button {
            // Booking actions will be connected when the flow is integrated.
        } label: {
            Text(title)
                .multilineTextAlignment(.center)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(foregroundColor)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(backgroundColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(borderColor.opacity(isFilled ? 1 : 0.9), lineWidth: 1.4)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    BookingView()
        .preferredColorScheme(.dark)
}
