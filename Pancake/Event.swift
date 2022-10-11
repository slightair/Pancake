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
        formatter.dateFormat = "yyyy/MM/dd(E) HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()

    let event: Event

    var eventTime: String {
        Self.dateFormatter.string(from: event.date)
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Image(systemName: "calendar.badge.clock")
                Text(event.title)
            }
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
    }
}

struct EventListView: View {
    let events: [Event]
    let maxCount = 8

    var body: some View {
        VStack(spacing: AppTheme.screenPadding) {
            ForEach(events.sorted { $0.date < $1.date }.prefix(maxCount)) { event in
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
            EventListView(events: viewStore.events)
        }
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        Grid {
            GridRow {
                Color.gray.gridCellColumns(2)
                EventView(
                    store: Store(
                        initialState: .mock,
                        reducer: eventReducer,
                        environment: EventEnvironment()
                    )
                )
            }
        }
        .padding(AppTheme.screenPadding)
    }
}
