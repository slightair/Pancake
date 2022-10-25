import HorizonCalendar
import SwiftUI

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
    static let calendar = Calendar.current
    static let locale = Locale(identifier: "ja_JP")

    static let monthHeaderDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = calendar
        dateFormatter.locale = locale
        dateFormatter.dateFormat = DateFormatter.dateFormat(
            fromTemplate: "MMMM yyyy",
            options: 0,
            locale: locale
        )
        return dateFormatter
    }()

    static let dayDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = calendar
        dateFormatter.locale = locale
        dateFormatter.dateFormat = DateFormatter.dateFormat(
            fromTemplate: "EEEE, MMM d, yyyy",
            options: 0,
            locale: locale
        )
        return dateFormatter
    }()

    var selectedDate: Date

    func makeUIView(context _: Context) -> HorizonCalendar.CalendarView {
        let calendarView = HorizonCalendar.CalendarView(initialContent: makeContent())
        calendarView.backgroundColor = .clear
        return calendarView
    }

    func updateUIView(_ uiView: HorizonCalendar.CalendarView, context _: Context) {
        uiView.setContent(makeContent())
    }

    private func makeContent() -> CalendarViewContent {
        let calendar = Self.calendar
        return CalendarViewContent(
            calendar: calendar,
            visibleDateRange: selectedDate ... selectedDate,
            monthsLayout: .horizontal(options: .init())
        )
        .interMonthSpacing(24)
        .monthHeaderItemProvider { month in
            var invariantViewProperties = MonthHeaderView.InvariantViewProperties.base
            invariantViewProperties.textColor = AppTheme.UIKit.textColor
            invariantViewProperties.font = .boldSystemFont(ofSize: 24)
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
            invariantViewProperties.font = .boldSystemFont(ofSize: 16)
            switch weekdayIndex {
            case 0:
                invariantViewProperties.textColor = UIColor(red: 0.93, green: 0.33, blue: 0.27, alpha: 1.0)
            case 6:
                invariantViewProperties.textColor = UIColor(red: 0.50, green: 0.82, blue: 0.98, alpha: 1.0)
            default:
                invariantViewProperties.textColor = AppTheme.UIKit.textColor
            }
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
                invariantViewProperties.backgroundShapeDrawingConfig.borderColor = color.withAlphaComponent(0.5)
                invariantViewProperties.backgroundShapeDrawingConfig.borderWidth = 2
            }
            invariantViewProperties.textColor = AppTheme.UIKit.textColor
            return CalendarItemModel<DayView>(
                invariantViewProperties: invariantViewProperties,
                viewModel: .init(
                    dayText: "\(day.day)",
                    accessibilityLabel: date.map { Self.dayDateFormatter.string(from: $0) },
                    accessibilityHint: nil
                )
            )
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack(alignment: .top) {
                Color.gray
                VStack {
                    Spacer(minLength: 16)
                    HStack {
                        Spacer(minLength: 16)
                        CalendarView(selectedDate: Date(timeIntervalSince1970: 1_659_193_200))
                        Spacer(minLength: 16)
                    }
                }
                .frame(width: 360)
            }
            .frame(height: 360)
            HStack(alignment: .top) {
                Color.gray
                    .frame(width: 400)
                VStack {
                    Color.gray
                    Color.gray
                }
            }
        }
        .shadow(color: AppTheme.shadowColor, radius: 8, x: 2, y: 4)
        .padding(AppTheme.screenPadding)

    }
}
