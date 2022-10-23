import ComposableArchitecture
import FirebaseFirestore
import FirebaseFirestoreSwift

struct MetricsClient {
    var roomSensorsHistories: @Sendable () async throws -> [RoomSensorsHistory]
    var saveRoomSensorRecords: @Sendable ([Room: SensorsRecord]) async throws -> Success

    struct Success: Equatable {}
}

extension MetricsClient {
    static let live = MetricsClient(
        roomSensorsHistories: {
            let db = Firestore.firestore()
            @Sendable func roomSensorsHistory(of room: Room) async throws -> RoomSensorsHistory {
                RoomSensorsHistory(
                    room: room,
                    records: try await db.collection("rooms").document(room.rawValue).collection("metrics")
                        .whereField("time", isGreaterThan: Date().addingTimeInterval(-3600 * 24))
                        .getDocuments().documents.map { doc in
                            try Firestore.Decoder().decode(SensorsRecord.self, from: doc.data())
                        }
                )
            }

            return try await [
                roomSensorsHistory(of: .living),
                roomSensorsHistory(of: .bedroom),
                roomSensorsHistory(of: .study),
            ]
        },
        saveRoomSensorRecords: { records in
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
    )

    static let saveDryRun = Self(
        roomSensorsHistories: live.roomSensorsHistories,
        saveRoomSensorRecords: { _ in
            print("[dry run] saved!")
            return Success()
        }
    )

    static let mock = MetricsClient(
        roomSensorsHistories: {
            [.mockLiving, .mockBedroom, .mockStudy]
        },
        saveRoomSensorRecords: { _ in Success() }
    )
}

private enum MetricsClientKey: DependencyKey {
    static let liveValue = MetricsClient.live
    static let previewValue = MetricsClient.mock
}

extension DependencyValues {
    var metricsClient: MetricsClient {
        get { self[MetricsClientKey.self] }
        set { self[MetricsClientKey.self] = newValue }
    }
}
