import ComposableArchitecture
import Foundation

struct BLEAdvertisementClient {
    var sensors: () -> Effect<[Room: SensorsRecord], Failure>

    struct Failure: Error, Equatable {}
}

extension BLEAdvertisementClient {
    static let live = BLEAdvertisementClient(
        sensors: {
            Effect.task {
                // Not implemented Yet
                throw Failure()
            }
            .mapError { _ in Failure() }
            .eraseToEffect()
        }
    )

    static let dev = BLEAdvertisementClient(
        sensors: {
            Effect(value: {
                let date = Date()
                return [
                    .living: .makeTestData(date: date),
                    .bedroom: .makeTestData(date: date),
                    .study: .makeTestData(date: date),
                ]
            }())
        }
    )
}

extension SensorsRecord {
    static func makeTestData(date: Date) -> Self {
        SensorsRecord(date: date, temperature: Double.random(in: 24..<28), humidity: .random(in: 50..<80), co2: .random(in: 450..<1000))
    }
}
