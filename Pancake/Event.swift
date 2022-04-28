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
                .foregroundColor(AppTheme.textColor)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("散歩")
                .foregroundColor(AppTheme.textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(8)
        .background {
            AppTheme.backgroundColor
        }
        .cornerRadius(AppTheme.cornerRadius)
    }
}

struct EventListView: View {
    var body: some View {
        VStack(spacing: AppTheme.panelPadding) {
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
                let baseWidth = (geometry.size.width - AppTheme.panelPadding) / 3
                HStack(alignment: .top, spacing: AppTheme.panelPadding) {
                    EventListView()
                        .frame(width: baseWidth * 2)
                    CalendarView(selectedDate: viewStore.date)
                        .cornerRadius(AppTheme.cornerRadius)
                        .frame(width: baseWidth)
                }
            }
            .frame(maxHeight: 301)
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
