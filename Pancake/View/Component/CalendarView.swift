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
            let firstDateInMonth = calendar.firstDate(of: month)
            let monthText = Self.monthHeaderDateFormatter.string(from: firstDateInMonth)
            return MonthHeaderView2(monthText: monthText).calendarItemModel
        }
        .dayOfWeekItemProvider { _, dayOfWeek in
            let dayOfWeekText = Self.monthHeaderDateFormatter.veryShortStandaloneWeekdaySymbols[dayOfWeek]
            return DayOfWeekView(dayOfWeek: dayOfWeek, dayOfWeekText: dayOfWeekText).calendarItemModel
        }
        .dayItemProvider { day in
            let date = calendar.date(from: day.components)
            let isSelected = calendar.date(selectedDate, matchesComponents: day.components)
            return DayView(dayNumber: day.day, isSelected: isSelected).calendarItemModel
        }
    }
}

struct MonthHeaderView2: View {
    let monthText: String

    var body: some View {
        HStack {
            Text(monthText)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppTheme.textColor)
            Spacer()
        }
    }
}

struct DayOfWeekView: View {
    let dayOfWeek: Int
    let dayOfWeekText: String

    var textColor: Color {
        switch dayOfWeek {
        case 0:
            return Color(red: 0.93, green: 0.33, blue: 0.27)
        case 6:
            return Color(red: 0.50, green: 0.82, blue: 0.98)
        default:
            return AppTheme.textColor
        }
    }

    var body: some View {
        Text(dayOfWeekText)
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(textColor)
    }
}

struct DayView: View {
    let dayNumber: Int
    let isSelected: Bool

    var body: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(isSelected ? AppTheme.textColor.opacity(0.5) : .clear, lineWidth: 2)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(isSelected ? AppTheme.textColor.opacity(0.2) : .clear)
                }
            Text("\(dayNumber)")
                .foregroundColor(AppTheme.textColor)
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(selectedDate: Date(timeIntervalSince1970: 1_659_193_200))
            .padding([.leading, .trailing, .top], 24)
            .previewLayout(PreviewLayout.fixed(width: 360, height: 360))
            .previewDisplayName("CalendarView")
            .background { Color.black }

        ZStack {
            Color.black
            DayView(dayNumber: 31, isSelected: true)
                .frame(width: 48, height: 48)
        }
            .previewDisplayName("DayView")
            .previewLayout(PreviewLayout.fixed(width: 360, height: 360))
    }
}
