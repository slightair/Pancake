import SwiftUI
import HorizonCalendar

extension Calendar {
    func firstDate(of month: Month) -> Date {
        let firstDateComponents = DateComponents(era: month.era, year: month.year, month: month.month)
        guard let firstDate = date(from: firstDateComponents) else {
            preconditionFailure("Failed to create a `Date` representing the first day of \(month).")
        }

        return firstDate
    }
}

struct CalendarView: UIViewRepresentable {
    static var calendar = Calendar.current

    static var monthHeaderDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = calendar
        dateFormatter.locale = calendar.locale
        dateFormatter.dateFormat = DateFormatter.dateFormat(
            fromTemplate: "MMMM yyyy",
            options: 0,
            locale: calendar.locale ?? Locale.current)
        return dateFormatter
    }()

    static var dayDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = calendar
        dateFormatter.locale = calendar.locale
        dateFormatter.dateFormat = DateFormatter.dateFormat(
            fromTemplate: "EEEE, MMM d, yyyy",
            options: 0,
            locale: calendar.locale ?? Locale.current)
        return dateFormatter
    }()

    var selectedDate: Date

    func makeUIView(context: Context) -> HorizonCalendar.CalendarView {
        let calendarView = HorizonCalendar.CalendarView(initialContent: makeContent())
        calendarView.backgroundColor = AppTheme.UIKit.backgroundColor
        return calendarView
    }

    func updateUIView(_ uiView: HorizonCalendar.CalendarView, context: Context) {
        uiView.setContent(makeContent())
    }

    private func makeContent() -> CalendarViewContent {
        let calendar = Self.calendar
        return CalendarViewContent(
            calendar: calendar,
            visibleDateRange: selectedDate...selectedDate,
            monthsLayout: .horizontal(options: .init()))
            .interMonthSpacing(24)
            .monthHeaderItemProvider { month in
                var invariantViewProperties = MonthHeaderView.InvariantViewProperties.base
                invariantViewProperties.textColor = AppTheme.UIKit.textColor
                let firstDateInMonth = calendar.firstDate(of: month)
                let monthText = Self.monthHeaderDateFormatter.string(from: firstDateInMonth)
                return CalendarItemModel<MonthHeaderView>(
                    invariantViewProperties: invariantViewProperties,
                    viewModel: .init(
                        monthText: monthText,
                        accessibilityLabel: monthText
                    )
                )
            }
            .dayOfWeekItemProvider { _, weekdayIndex in
                var invariantViewProperties = DayOfWeekView.InvariantViewProperties.base
                invariantViewProperties.textColor = AppTheme.UIKit.textColor
                invariantViewProperties.font = .boldSystemFont(ofSize: 16)
                let dayOfWeekText = Self.monthHeaderDateFormatter.veryShortStandaloneWeekdaySymbols[weekdayIndex]
                return CalendarItemModel<DayOfWeekView>(
                    invariantViewProperties: invariantViewProperties,
                    viewModel: .init(
                        dayOfWeekText: dayOfWeekText,
                        accessibilityLabel: dayOfWeekText
                    )
                )
            }
            .dayItemProvider { day in
                var invariantViewProperties = DayView.InvariantViewProperties.baseInteractive
                invariantViewProperties.shape = .rectangle(cornerRadius: 8)
                invariantViewProperties.interaction = .disabled
                let date = calendar.date(from: day.components)
                if calendar.date(selectedDate, matchesComponents: day.components) {
                    let color: UIColor = AppTheme.UIKit.textColor
                    invariantViewProperties.backgroundShapeDrawingConfig.fillColor = color.withAlphaComponent(0.2)
                }
                invariantViewProperties.textColor = AppTheme.UIKit.textColor
                return CalendarItemModel<DayView>(
                    invariantViewProperties: invariantViewProperties,
                    viewModel: .init(
                        dayText: "\(day.day)",
                        accessibilityLabel: date.map { Self.dayDateFormatter.string(from: $0) },
                        accessibilityHint: nil))
            }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            let baseWidth = geometry.size.width / 3
            HStack(alignment: .top) {
                CalendarView(selectedDate: Date(timeIntervalSince1970: 1656601200))
                    .frame(width: baseWidth)
                Spacer()
            }
        }
        .frame(maxHeight: 300)
    }
}
