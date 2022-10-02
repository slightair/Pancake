import ComposableArchitecture
import FirebaseFirestore
import FirebaseFirestoreSwift

struct MetricsClient {
    var roomSensorsHistories: () -> Effect<[RoomSensorsHistory], Failure>
    var saveRoomSensorRecords: ([Room: SensorsRecord]) -> Effect<Success, Failure>

    struct Success: Equatable {}
    struct Failure: Error, Equatable {
        let message: String
    }
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
            .mapError { error in Failure(message: error.localizedDescription) }
            .eraseToEffect()
        },
        saveRoomSensorRecords: { records in
            Effect.task {
                let db = Firestore.firestore()
                @Sendable func saveRoomSensorRecord(room: Room) async throws {
                    _ = try db.collection("rooms").document(room.rawValue).collection("metrics").addDocument(from: records[room])
                }

                async let saveLiving: Void = saveRoomSensorRecord(room: .living)
                async let saveBedroom: Void = saveRoomSensorRecord(room: .bedroom)
                async let saveStudy: Void = saveRoomSensorRecord(room: .study)

                _ = try await [saveLiving, saveBedroom, saveStudy]
                return Success()
            }
            .mapError { error in Failure(message: error.localizedDescription) }
            .eraseToEffect()
        }
    )

    static let dev = MetricsClient(
        roomSensorsHistories: live.roomSensorsHistories,
        saveRoomSensorRecords: { records in
            Effect(value: Success())
        }
    )

    static let mock = MetricsClient(
        roomSensorsHistories: {
            Effect(value: [.mockLiving, .mockBedroom, .mockStudy])
        },
        saveRoomSensorRecords: { records in
            Effect(value: Success())
        }
    )
}
