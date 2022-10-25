import ComposableArchitecture
import Foundation
import SwiftUI

struct EventList: ReducerProtocol {
    struct State: Equatable {
        var events: [Event] = []
    }

    enum Action {
        case eventListUpdate
        case eventListResponse(TaskResult<[Event]>)
    }

    @Dependency(\.eventClient) var eventClient

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .eventListUpdate:
            return .task {
                await .eventListResponse(TaskResult { try await eventClient.events() })
            }
        case let .eventListResponse(.success(eventList)):
            state.events = eventList
            return .none
        case let .eventListResponse(.failure(error)):
            print(error)
            return .none
        }
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
    let maxCount = 4

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

            if events.count > maxCount {
                let moreEventCounts = events.count - maxCount
                Text("+ \(moreEventCounts) events")
                    .foregroundColor(AppTheme.headerColor)
                    .font(AppTheme.headerFont)
            }
        }
        .padding([.top], AppTheme.screenPadding)
    }
}

struct EventView: View {
    let store: StoreOf<EventList>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            EventListView(events: viewStore.events)
        }
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack(alignment: .top) {
                Color.gray
                Color.gray
                    .frame(width: 360)
            }
            .frame(height: 360)
            HStack(alignment: .top) {
                Color.gray
                    .frame(width: 400)
                VStack {
                    EventView(
                        store: Store(
                            initialState: EventList.State(
                                events: Event.mockEvents
                            ),
                            reducer: EventList()
                        )
                    )
                    Color.gray
                }
            }
        }
        .shadow(color: AppTheme.shadowColor, radius: 8, x: 2, y: 4)
        .padding(AppTheme.screenPadding)
    }
}
