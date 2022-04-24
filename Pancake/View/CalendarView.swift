import SwiftUI
import HorizonCalendar

struct CalendarView: UIViewRepresentable {
    static var calendar = Calendar.current
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
        HorizonCalendar.CalendarView(initialContent: makeContent())
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
            .dayItemProvider { day in
                var invariantViewProperties = DayView.InvariantViewProperties.baseInteractive
                invariantViewProperties.shape = .rectangle(cornerRadius: 8)
                invariantViewProperties.interaction = .disabled
                let date = calendar.date(from: day.components)
                if calendar.date(selectedDate, matchesComponents: day.components) {
                    let color: UIColor = .systemGray
                    invariantViewProperties.backgroundShapeDrawingConfig.borderColor = color
                    invariantViewProperties.backgroundShapeDrawingConfig.fillColor = color.withAlphaComponent(0.15)
                }
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
        CalendarView(selectedDate: Date())
    }
}
