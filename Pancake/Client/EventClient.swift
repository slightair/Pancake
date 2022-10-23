import ComposableArchitecture
import EventKit

struct Event: Identifiable, Equatable {
    var id: String
    let date: Date
    let title: String
}

extension Event {
    static let mockEvents: [Event] = [
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
}

enum EventError: LocalizedError {
    case unauthorized
    case failedToReadReminders
}

struct EventClient {
    var events: @Sendable () async throws -> [Event]
}

extension EventClient {
    static let live = EventClient(
        events: {
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

            return reminders.filter { !$0.isCompleted }
                .compactMap { reminder in
                    reminder.dueDateComponents?.date.map {
                        Event(
                            id: reminder.calendarItemIdentifier,
                            date: $0,
                            title: reminder.title
                        )
                    }
                }
        }
    )

    static let mock = EventClient(
        events: {
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
