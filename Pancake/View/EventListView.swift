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

    func parseEventName() -> (String?, String) {
        var color: String? = nil
        var name: String = "---"

        if let title = event?.title {
            settings.tags.forEach { tag, tagColor in
                let tagPattern = "[\(tag)]"
                if title.hasPrefix(tagPattern) {
                    if let tagRange = title.range(of: tagPattern) {
                        name = String(title[tagRange.upperBound...])
                        color = tagColor
                    }
                    return
                }
            }
            if color == nil {
                name = title
            }
        }
        return (color, name)
    }

    @ViewBuilder
    func eventName() -> some View {
        let (symbolColor, title) = parseEventName()
        if let symbolColor {
            Image(systemName: "person.fill")
                .foregroundColor(Color(hexString: symbolColor))
        }
        Text(title)
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Image(systemName: "calendar.badge.clock")
                eventName()
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
                    EventListItemView(event: nil)
                }
            }

            if events.count > maxCount {
                let moreEventCounts = events.count - maxCount
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
        EventView(
            store: Store(
                initialState: EventList.State(
                    events: Event.mockEvents
                ),
                reducer: EventList()
            )
        )
        .previewLayout(PreviewLayout.fixed(width: 360, height: 160))
        .background { Color.black }
    }
}
