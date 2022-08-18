import ComposableArchitecture
import EventKit

struct Event: Identifiable, Equatable {
    var id: String
    let date: Date
    let title: String
}

struct EventClient {
    var events: () -> Effect<[Event], Failure>

    struct Failure: Error, Equatable {}
}

extension EventClient {
    static let live = EventClient(
        events: {
            Effect.task {
                let eventStore = EKEventStore()
                let type: EKEntityType = .reminder
                let accessToEvent: Bool

                if EKEventStore.authorizationStatus(for: type) != .authorized {
                    accessToEvent = try await eventStore.requestAccess(to: type)
                } else {
                    accessToEvent = true
                }

                if !accessToEvent {
                    throw Failure()
                }

                let predicate = eventStore.predicateForReminders(in: nil)
                let reminders = try await eventStore.fetchReminders(matching: predicate)

                return reminders.filter { !$0.isCompleted }
                    .compactMap { reminder in
                        if let dueDate = reminder.dueDateComponents?.date {
                            return Event(id: reminder.calendarItemIdentifier, date: dueDate, title: reminder.title)
                        }
                        return nil
                    }
            }
            .mapError { _ in Failure() }
            .eraseToEffect()
        }
    )
}

enum EventError: LocalizedError {
    case failedToReadReminders
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
