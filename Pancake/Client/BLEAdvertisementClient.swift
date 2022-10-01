import ComposableArchitecture
import Foundation

struct BLEAdvertisementClient {
    var sensors: (BLEAdvertisementScanner, Settings.Sensor) -> Effect<[Room: SensorsRecord], Failure>

    struct Failure: Error, Equatable {}
}

extension BLEAdvertisementClient {
    static let live = BLEAdvertisementClient(
        sensors: { scanner, settings in
            Effect.task {
                let sensorValues = try await scanner.scanSensorValues(
                    sensors: [
                        settings.livingThermometerPeripheralID: ThermometerSensorData.self,
                        settings.livingCO2PeripheralID: CO2SensorData.self,
                        settings.bedroomThermometerPeripheralID: ThermometerSensorData.self,
                        settings.studyThermometerPeripheralID: ThermometerSensorData.self,
                    ],
                    timeoutSeconds: 300
                )
                let date = Date()
                let livingThermometer = sensorValues[settings.livingThermometerPeripheralID] as! ThermometerSensorData
                let livingCO2 = sensorValues[settings.livingCO2PeripheralID] as! CO2SensorData
                let bedroomThermometer = sensorValues[settings.bedroomThermometerPeripheralID] as! ThermometerSensorData
                let studyThermometer = sensorValues[settings.studyThermometerPeripheralID] as! ThermometerSensorData

                return [
                    .living: SensorsRecord(date: date, temperature: livingThermometer.temperature, humidity: Double(livingThermometer.humidity), co2: Double(livingCO2.co2)),
                    .bedroom: SensorsRecord(date: date, temperature: bedroomThermometer.temperature, humidity: Double(bedroomThermometer.humidity), co2: 0),
                    .study: SensorsRecord(date: date, temperature: studyThermometer.temperature, humidity: Double(studyThermometer.humidity), co2: 0),
                ]
            }
            .mapError { _ in Failure() }
            .eraseToEffect()
        }
    )

    static let watch = BLEAdvertisementClient(
        sensors: { scanner, _ in
            Effect.task {
                _ = try await scanner.scanSensorValues(sensors: [:], timeoutSeconds: 600)
                return [:]
            }
            .mapError { _ in Failure() }
            .eraseToEffect()
        }
    )

    static let dev = BLEAdvertisementClient(
        sensors: { _, _ in
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
