import ComposableArchitecture
import FirebaseFirestore
import FirebaseFirestoreSwift

struct MetricsClient {
    var roomSensorsHistories: () -> Effect<[RoomSensorsHistory], Failure>
    var saveRoomSensorRecord: (Room, SensorsRecord) -> Effect<Void, Failure>

    struct Failure: Error, Equatable {}
}

extension MetricsClient {
    static let live = MetricsClient(
        roomSensorsHistories: {
            Effect.task {
                let db = Firestore.firestore()
                @Sendable func roomSensorsHistory(of room: Room) async throws -> RoomSensorsHistory {
                    RoomSensorsHistory(
                        room: room,
                        records: try await db.collection("rooms").document(room.rawValue).collection("metrics").getDocuments().documents.map { doc in
                            try Firestore.Decoder().decode(SensorsRecord.self, from: doc.data())
                        }
                    )
                }

                return try await [
                    roomSensorsHistory(of: .living),
                    roomSensorsHistory(of: .bedroom),
                    roomSensorsHistory(of: .study),
                ]
            }
            .mapError { _ in Failure() }
            .eraseToEffect()
        },
        saveRoomSensorRecord: { room, record in
            Effect.task {
                let db = Firestore.firestore()
                _ = try db.collection("rooms").document(room.rawValue).collection("metrics").addDocument(from: record)
            }
            .mapError { _ in Failure() }
            .eraseToEffect()
        }
    )

    static let mock = MetricsClient(
        roomSensorsHistories: {
            Effect(value: [.mockLiving, .mockBedroom, .mockStudy])
        },
        saveRoomSensorRecord: { room, record in
            Effect(value: ())
        }
    )
}
