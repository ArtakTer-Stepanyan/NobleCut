//
//  BookingCalendarView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 27.04.26.
//

import SwiftUI

struct BookingCalendarView: View {
    private static let weekdaySymbols = ["S", "M", "T", "W", "T", "F", "S"]

    let selectedDate: Date
    let displayedMonth: Date
    let availableDateRange: ClosedRange<Date>
    let availableDates: [Date]
    let onSelectDate: (Date) -> Void
    let onDisplayMonthChange: (Date) -> Void

    private let calendar = BookingCalendarFactory.calendar
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            header
            VStack(spacing: 12) {
                weekdayHeader
                dayGrid
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.darkGray)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.04), lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }

    private var header: some View {
        HStack(spacing: 14) {
            Text(displayedMonth.formatted(.dateTime.month(.wide).year()))
                .font(.system(size: 20, weight: .semibold, design: .serif))
                .foregroundStyle(.white.opacity(0.92))

            Spacer()

            calendarButton(systemImage: "chevron.left", isDisabled: !canGoToPreviousMonth) {
                onDisplayMonthChange(
                    calendar.date(
                    byAdding: .month,
                    value: -1,
                    to: displayedMonth
                    ) ?? displayedMonth
                )
            }

            calendarButton(systemImage: "chevron.right", isDisabled: !canGoToNextMonth) {
                onDisplayMonthChange(
                    calendar.date(
                    byAdding: .month,
                    value: 1,
                    to: displayedMonth
                    ) ?? displayedMonth
                )
            }
        }
    }

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(Array(Self.weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(.system(size: 11, weight: .semibold, design: .serif))
                    .foregroundStyle(.white.opacity(0.28))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var dayGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(monthDays) { day in
                Button {
                    onSelectDate(day.date)
                } label: {
                    Text(day.numberText)
                        .font(.system(size: 15, weight: day.isSelected ? .semibold : .medium, design: .serif))
                        .foregroundStyle(dayForegroundColor(for: day))
                        .frame(width: 34, height: 34)
                        .background(
                            Circle()
                                .fill(day.isSelected ? Color.appYellow : .clear)
                        )
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .disabled(!day.isSelectable)
                .opacity(day.isSelectable ? 1 : 0.28)
            }
        }
    }

    private var monthDays: [CalendarDay] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
            let numberOfDays = calendar.range(of: .day, in: .month, for: displayedMonth)?.count
        else {
            return []
        }

        let monthStart = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let leadingDays = (firstWeekday - calendar.firstWeekday + 7) % 7
        let totalVisibleDays = leadingDays + numberOfDays
        let trailingDays = (7 - (totalVisibleDays % 7)) % 7
        let visibleDayCount = totalVisibleDays + trailingDays
        let gridStart = calendar.date(byAdding: .day, value: -leadingDays, to: monthStart) ?? monthStart

        return (0..<visibleDayCount).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: gridStart) else {
                return nil
            }

            return CalendarDay(
                date: date,
                dayNumber: calendar.component(.day, from: date),
                isInDisplayedMonth: calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month),
                isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                isSelectable: isSelectable(date)
            )
        }
    }

    private func dayForegroundColor(for day: CalendarDay) -> Color {
        if day.isSelected {
            return Color.black.opacity(0.84)
        }

        return day.isInDisplayedMonth
            ? Color.white.opacity(0.82)
            : Color.white.opacity(0.16)
    }

    private var canGoToPreviousMonth: Bool {
        let currentMonth = calendar.startOfMonth(for: displayedMonth)
        let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        return previousMonth >= calendar.startOfMonth(for: availableDateRange.lowerBound)
    }

    private var canGoToNextMonth: Bool {
        let currentMonth = calendar.startOfMonth(for: displayedMonth)
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        return nextMonth <= calendar.startOfMonth(for: availableDateRange.upperBound)
    }

    private func isSelectable(_ date: Date) -> Bool {
        let normalizedDate = calendar.startOfDay(for: date)
        let lowerBound = calendar.startOfDay(for: availableDateRange.lowerBound)
        let upperBound = calendar.startOfDay(for: availableDateRange.upperBound)
        guard normalizedDate >= lowerBound, normalizedDate <= upperBound else {
            return false
        }

        return availableDates.contains(where: { calendar.isDate($0, inSameDayAs: normalizedDate) })
    }

    private func calendarButton(
        systemImage: String,
        isDisabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 12, weight: .bold, design: .serif))
                .foregroundStyle(.white.opacity(0.86))
                .frame(width: 30, height: 30)
                .background(Circle().fill(Color.clear))
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.35 : 1)
    }
}

private struct CalendarDay: Identifiable {
    let date: Date
    let dayNumber: Int
    let isInDisplayedMonth: Bool
    let isSelected: Bool
    let isSelectable: Bool

    var id: Date { date }
    var numberText: String { String(dayNumber) }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        BookingCalendarView(
            selectedDate: Date(),
            displayedMonth: BookingCalendarFactory.calendar.startOfMonth(for: Date()),
            availableDateRange: Date()...(BookingCalendarFactory.calendar.date(byAdding: .day, value: 30, to: Date()) ?? Date()),
            availableDates: [Date()],
            onSelectDate: { _ in },
            onDisplayMonthChange: { _ in }
        )
    }
    .preferredColorScheme(.dark)
}
