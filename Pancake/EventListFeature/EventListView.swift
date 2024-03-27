import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct EventListFeature {
    @ObservableState
    struct State: Equatable {
        var events: [Event] = []
    }

    enum Action {
        case eventListUpdate
        case eventListResponse(TaskResult<[Event]>)
    }

    @Dependency(\.eventClient) var eventClient
    @Dependency(\.settings.tags) var decorateTags

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .eventListUpdate:
                return .run { send in
                    await send(.eventListResponse(TaskResult { try await eventClient.events(decorateTags) }))
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
}

struct EventListItemView: View {
    @Dependency(\.settings) var settings

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd(E) HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()

    let event: Event?

    var eventTime: String {
        if let event {
            return Self.dateFormatter.string(from: event.date)
        } else {
            return "---"
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Image(systemName: "calendar.badge.clock")
                if let event {
                    if let tag = event.tag {
                        Image(systemName: "person.fill")
                            .foregroundColor(Color(hexString: tag.colorCode))
                    }
                    Text(event.title)
                } else {
                    Text("---")
                }
            }
                .font(AppTheme.textFont)
            Text(eventTime)
                .font(AppTheme.headerFont)
        }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(event != nil ? AppTheme.textColor : AppTheme.notAvailableColor)
    }
}

struct EventListView: View {
    let store: StoreOf<EventListFeature>
    let maxEventCount: Int

    var body: some View {
        VStack(spacing: AppTheme.screenPadding) {
            VStack(spacing: 8) {
                ForEach(store.events.sorted { $0.date < $1.date }.prefix(maxEventCount)) { event in
                    EventListItemView(event: event)
                }
            }

            if store.events.count < maxEventCount {
                let numPadding = maxEventCount - store.events.count
                ForEach(0 ..< numPadding, id: \.self) { index in
                    EventListItemView(event: nil)
                }
            }

            Spacer()

            if store.events.isEmpty {
                Text("no events")
                    .foregroundColor(AppTheme.headerColor)
                    .font(AppTheme.headerFont)
            } else if store.events.count > maxEventCount {
                let moreEventCounts = store.events.count - maxEventCount
                Text("+\(moreEventCounts) event\(moreEventCounts > 1 ? "s" : "")")
                    .foregroundColor(AppTheme.headerColor)
                    .font(AppTheme.headerFont)
            } else {
                Text("---")
                    .foregroundColor(AppTheme.notAvailableColor)
                    .font(AppTheme.headerFont)
            }
        }
        .padding([.top], AppTheme.screenPadding)
    }
}

#Preview {
    EventListView(
        store: Store(initialState: EventListFeature.State(
            events: Event.mockEvents
        )) {
            EventListFeature()
        },
        maxEventCount: 4
    )
    .previewLayout(PreviewLayout.fixed(width: 360, height: 360))
    .background { Color.black }
}
