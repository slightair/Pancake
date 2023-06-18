import ComposableArchitecture
import EventKit

struct Event: Identifiable, Equatable {
    struct Tag: Equatable {
        let name: String
        let colorCode: String
    }

    var id: String
    let date: Date
    let title: String
    let tag: Tag?
}

extension Event {
    static let mockEvents: [Event] = [
        Event(id: UUID().uuidString, date: Date(timeIntervalSince1970: 1656979947), title: "散歩1", tag: Tag(name:"Bob", colorCode: "#6699ff")),
        Event(id: UUID().uuidString, date: Date(timeIntervalSince1970: 1657151510), title: "散歩2", tag: Tag(name: "Alice", colorCode: "#ff9966")),
        Event(id: UUID().uuidString, date: Date(timeIntervalSince1970: 1657422530), title: "散歩3", tag: nil),
        Event(id: UUID().uuidString, date: Date(timeIntervalSince1970: 1657453591), title: "散歩4", tag: nil),
        Event(id: UUID().uuidString, date: Date(timeIntervalSince1970: 1657455861), title: "散歩5", tag: nil),
        Event(id: UUID().uuidString, date: Date(timeIntervalSince1970: 1657680762), title: "散歩6", tag: nil),
        Event(id: UUID().uuidString, date: Date(timeIntervalSince1970: 1657894558), title: "散歩7", tag: nil),
        Event(id: UUID().uuidString, date: Date(timeIntervalSince1970: 1657989718), title: "散歩8", tag: nil),
        Event(id: UUID().uuidString, date: Date(timeIntervalSince1970: 1658201017), title: "散歩9", tag: nil),
        Event(id: UUID().uuidString, date: Date(timeIntervalSince1970: 1659043194), title: "散歩10", tag: nil),
        Event(id: UUID().uuidString, date: Date(timeIntervalSince1970: 1666979947), title: "散歩11", tag: Tag(name:"Bob", colorCode: "#6699ff")),
        Event(id: UUID().uuidString, date: Date(timeIntervalSince1970: 1667151510), title: "散歩12", tag: Tag(name: "Alice", colorCode: "#ff9966")),
        Event(id: UUID().uuidString, date: Date(timeIntervalSince1970: 1667422530), title: "散歩13", tag: nil),
        Event(id: UUID().uuidString, date: Date(timeIntervalSince1970: 1667453591), title: "散歩14", tag: nil),
        Event(id: UUID().uuidString, date: Date(timeIntervalSince1970: 1667455861), title: "散歩15", tag: nil),
        Event(id: UUID().uuidString, date: Date(timeIntervalSince1970: 1667680762), title: "散歩16", tag: nil),
        Event(id: UUID().uuidString, date: Date(timeIntervalSince1970: 1667894558), title: "散歩17", tag: nil),
        Event(id: UUID().uuidString, date: Date(timeIntervalSince1970: 1667989718), title: "散歩18", tag: nil),
        Event(id: UUID().uuidString, date: Date(timeIntervalSince1970: 1668201017), title: "散歩19", tag: nil),
        Event(id: UUID().uuidString, date: Date(timeIntervalSince1970: 1669043194), title: "散歩110", tag: nil),
    ]
}

enum EventError: LocalizedError {
    case unauthorized
    case failedToReadReminders
}

struct EventClient {
    var events: @Sendable ([String: String]) async throws -> [Event]
}

extension EventClient {
    static let live = EventClient(
        events: { decorateTags in
            let eventStore = EKEventStore()
            let type: EKEntityType = .reminder
            let accessToEvent: Bool

            if EKEventStore.authorizationStatus(for: type) != .authorized {
                accessToEvent = try await eventStore.requestAccess(to: type)
            } else {
                accessToEvent = true
            }

            if !accessToEvent { throw EventError.unauthorized }

            let predicate = eventStore.predicateForReminders(in: nil)
            let reminders = try await eventStore.fetchReminders(matching: predicate)

            func parseEventTags(baseTitle: String) -> (String, Event.Tag?) {
                var title: String = baseTitle
                var tag: Event.Tag? = nil

                decorateTags.forEach { tagName, colorCode in
                    let tagPattern = "[\(tagName)]"
                    if baseTitle.hasPrefix(tagPattern) {
                        if let tagRange = baseTitle.range(of: tagPattern) {
                            title = String(baseTitle[tagRange.upperBound...])
                            tag = Event.Tag(name: tagName, colorCode: colorCode)
                        }
                        return
                    }
                }
                return (title, tag)
            }

            return reminders.filter { !$0.isCompleted }
                .compactMap { reminder in
                    reminder.dueDateComponents?.date.map {
                        let (title, tag) = parseEventTags(baseTitle: reminder.title)
                        return Event(
                            id: reminder.calendarItemIdentifier,
                            date: $0,
                            title: title,
                            tag: tag
                        )
                    }
                }
        }
    )

    static let mock = EventClient(
        events: { _ in
            Event.mockEvents
        }
    )
}

extension EKEventStore {
    func fetchReminders(matching predicate: NSPredicate) async throws -> [EKReminder] {
        try await withCheckedThrowingContinuation { continuation in
            fetchReminders(matching: predicate) { reminders in
                if let reminders = reminders {
                    continuation.resume(returning: reminders)
                } else {
                    continuation.resume(throwing: EventError.failedToReadReminders)
                }
            }
        }
    }
}

private enum EventClientKey: DependencyKey {
    static let liveValue = EventClient.live
    static let previewValue = EventClient.mock
}

extension DependencyValues {
    var eventClient: EventClient {
        get { self[EventClientKey.self] }
        set { self[EventClientKey.self] = newValue }
    }
}
