import ComposableArchitecture
import Foundation
import SwiftUI

struct EventState: Equatable, Identifiable {
    var id: TimeInterval {
        date.timeIntervalSince1970
    }

    var date = Date()
    var events: [Event] = []
}

extension EventState {
    static let mock = EventState(
        date: Date(timeIntervalSince1970: 1659279600),
        events: [
            Event(id: UUID().uuidString, date: Date(timeIntervalSince1970: 1660057200), title: "散歩1"),
            Event(id: UUID().uuidString, date: Date(timeIntervalSince1970: 1660143600), title: "散歩2"),
            Event(id: UUID().uuidString, date: Date(timeIntervalSince1970: 1660230000), title: "散歩3"),
            Event(id: UUID().uuidString, date: Date(timeIntervalSince1970: 1660316400), title: "散歩4"),
            Event(id: UUID().uuidString, date: Date(timeIntervalSince1970: 1660402800), title: "散歩5"),
            Event(id: UUID().uuidString, date: Date(timeIntervalSince1970: 1660489200), title: "散歩6"),
            Event(id: UUID().uuidString, date: Date(timeIntervalSince1970: 1660575600), title: "散歩7"),
            Event(id: UUID().uuidString, date: Date(timeIntervalSince1970: 1660662000), title: "散歩8"),
            Event(id: UUID().uuidString, date: Date(timeIntervalSince1970: 1660748400), title: "散歩9"),
            Event(id: UUID().uuidString, date: Date(timeIntervalSince1970: 1660834800), title: "散歩10"),
        ]
    )
}

enum EventAction: Equatable {
    case eventListUpdate(Date)
}

struct EventEnvironment {}

let eventReducer = Reducer<EventState, EventAction, EventEnvironment> { state, action, _ in
    switch action {
    case let .eventListUpdate(date):
        state.date = date
        return .none
    }
}

struct EventListItemView: View {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter
    }()

    let event: Event

    var eventTime: String {
        Self.dateFormatter.string(from: event.date)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(event.title)
                .foregroundColor(AppTheme.textColor)
                .font(AppTheme.textFont)
            Text(eventTime)
                .monospacedDigit()
                .foregroundColor(AppTheme.headerColor)
                .font(AppTheme.headerFont)
        }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(AppTheme.textColor)
            .padding(AppTheme.panelPadding)
            .background {
                AppTheme.backgroundColor
            }
            .cornerRadius(AppTheme.cornerRadius)
    }
}

struct EventListItemEmptyView: View {
    var body: some View {
        ZStack {
            Color(.clear)
            Text("N/A")
                .foregroundColor(AppTheme.notAvailableColor)
                .font(AppTheme.headerFont)
        }
        .padding(AppTheme.panelPadding)
        .background {
            AppTheme.backgroundColor
        }
        .cornerRadius(AppTheme.cornerRadius)
    }
}

struct EventListView: View {
    let events: [Event]
    let maxCount = 6

    var body: some View {
        VStack(spacing: AppTheme.screenPadding) {
            ForEach(events.prefix(maxCount)) { event in
                EventListItemView(event: event)
            }

            if events.count < maxCount {
                let numPadding = maxCount - events.count
                ForEach(0 ..< numPadding, id: \.self) { index in
                    EventListItemEmptyView()
                }
            }
        }
    }
}

struct EventView: View {
    let store: Store<EventState, EventAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            GeometryReader { geometry in
                let baseWidth = (geometry.size.width - AppTheme.screenPadding * 2) / 3
                HStack(alignment: .top, spacing: AppTheme.screenPadding) {
                    CalendarView(selectedDate: viewStore.date)
                        .cornerRadius(AppTheme.cornerRadius)
                        .frame(width: baseWidth)
                    EventListView(events: viewStore.events)
                        .frame(width: baseWidth * 2 + AppTheme.screenPadding)
                }
            }
            .frame(maxHeight: 311)
        }
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(
            store: Store(
                initialState: .mock,
                reducer: eventReducer,
                environment: EventEnvironment()
            )
        )
    }
}
