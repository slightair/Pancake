import ComposableArchitecture
import Foundation
import SwiftUI

struct EventState: Equatable, Identifiable {
    let id = UUID()
    var date = Date()
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
    var body: some View {
        VStack {
            Text("4/12 10:00")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("散歩")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct EventListView: View {
    var body: some View {
        VStack {
            ForEach(0..<5) { _ in
                EventListItemView()
            }
        }
    }
}

struct EventView: View {
    let store: Store<EventState, EventAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            GeometryReader { geometry in
                let baseWidth = geometry.size.width / 3
                HStack(alignment: .top) {
                    EventListView()
                        .frame(width: baseWidth * 2)
                    CalendarView(selectedDate: viewStore.date)
                        .frame(width: baseWidth)
                }
            }
            .frame(maxHeight: 280)
        }
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(
            store: Store(
                initialState: EventState(),
                reducer: eventReducer,
                environment: EventEnvironment()
            )
        )
    }
}
