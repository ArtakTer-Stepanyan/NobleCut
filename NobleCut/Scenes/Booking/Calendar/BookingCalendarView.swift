//
//  BookingCalendarView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 27.04.26.
//

import SwiftUI

struct BookingCalendarView: View {
    private static var bookingCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = .autoupdatingCurrent
        calendar.timeZone = .autoupdatingCurrent
        calendar.firstWeekday = 1
        return calendar
    }()

    private static let weekdaySymbols = ["S", "M", "T", "W", "T", "F", "S"]

    @State private var selectedDate: Date
    @State private var displayedMonth: Date

    private let calendar = Self.bookingCalendar
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    init() {
        let today = Date()
        let month = Self.bookingCalendar.startOfMonth(for: today)
        _selectedDate = State(initialValue: today)
        _displayedMonth = State(initialValue: month)
    }

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

            calendarButton(systemImage: "chevron.left") {
                displayedMonth = calendar.date(
                    byAdding: .month,
                    value: -1,
                    to: displayedMonth
                ) ?? displayedMonth
            }

            calendarButton(systemImage: "chevron.right") {
                displayedMonth = calendar.date(
                    byAdding: .month,
                    value: 1,
                    to: displayedMonth
                ) ?? displayedMonth
            }
        }
    }

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(Array(Self.weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.28))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var dayGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(monthDays) { day in
                Button {
                    selectedDate = day.date
                    displayedMonth = calendar.startOfMonth(for: day.date)
                } label: {
                    Text(day.numberText)
                        .font(.system(size: 15, weight: day.isSelected ? .semibold : .medium))
                        .foregroundStyle(dayForegroundColor(for: day))
                        .frame(width: 34, height: 34)
                        .background(
                            Circle()
                                .fill(day.isSelected ? Color.appYellow : .clear)
                        )
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
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
                isSelected: calendar.isDate(date, inSameDayAs: selectedDate)
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

    private func calendarButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white.opacity(0.86))
                .frame(width: 30, height: 30)
                .background(Circle().fill(Color.clear))
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct CalendarDay: Identifiable {
    let date: Date
    let dayNumber: Int
    let isInDisplayedMonth: Bool
    let isSelected: Bool

    var id: Date { date }
    var numberText: String { String(dayNumber) }
}

private extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        dateInterval(of: .month, for: date)?.start ?? date
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        BookingCalendarView()
    }
    .preferredColorScheme(.dark)
}
