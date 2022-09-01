import CoreBluetooth
import Foundation

protocol SensorData: Sendable {
    static var serviceID: String { get }
    static func parse(advertisementData: [String: Any]) -> Self?
}

struct ThermometerSensorData: SensorData, CustomStringConvertible {
    static let serviceID = "cba20d00-224d-11e6-9fb8-0002a5d5c51b"
    static let deviceType = 0x54
    static let dataLength = 6

    private let packet: Data

    var isTemperatureHighAlert: Bool {
        packet[3] & 0b1000_0000 > 0
    }

    var isTemperatureLowAlert: Bool {
        packet[3] & 0b0100_0000 > 0
    }

    var isHumidityHighAlert: Bool {
        packet[3] & 0b0010_0000 > 0
    }

    var isHumidityLowAlert: Bool {
        packet[3] & 0b0001_0000 > 0
    }

    var isTemperatureAboveFreezing: Bool {
        packet[4] & 0b1000_0000 > 0
    }

    var isTemperatureUnitF: Bool {
        packet[5] & 0b1000_0000 > 0
    }

    var battery: Int {
        Int(packet[2] & 0b0111_1111)
    }

    private var t2: Int {
        Int(packet[3] & 0b0000_1111)
    }

    private var t1: Int {
        Int(packet[4] & 0b0111_1111)
    }

    var humidity: Int {
        Int(packet[5] & 0b0111_1111)
    }

    var temperature: Double {
        let abstractTemp = Double(t1) + Double(t2) / 10.0
        return isTemperatureAboveFreezing ? abstractTemp : -abstractTemp
    }

    var description: String {
        "[Thermometer] temperature: \(temperature), humidity: \(humidity)%, battery: \(battery)%"
    }

    static func parse(advertisementData: [String : Any]) -> Self? {
        if let serviceData = advertisementData[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data],
           let packet = serviceData[CBUUID(string: "0d00")],
           packet.count == Self.dataLength, (packet[0] & 0b0111_1111) == Self.deviceType {
            return Self(packet: packet)
        }
        return nil
    }
}

struct CO2SensorData: SensorData, CustomStringConvertible {
    static let serviceID = "3bd23d60-7bcc-44a6-9d15-0294c025af4c"
    static let dataLength = 6

    private let packet: Data

    private var sequence: Int {
        Int(packet[2])
    }

    private var temperature: Int {
        Int(packet[3])
    }

    var co2: Int {
        Int(packet[4]) + (Int(packet[5]) << 8)
    }

    var description: String {
        "[CO2] temperature: \(temperature), co2: \(co2)ppm"
    }

    static func parse(advertisementData: [String : Any]) -> Self? {
        if let packet = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data, packet.count == Self.dataLength {
            return Self(packet: packet)
        }
        return nil
    }
}

enum BLEAdvertisementScannerError: Error, Equatable {
    case AbortScanSensors
    case CouldNotParseSensorValue
    case TimeOut
}

final class BLEAdvertisementScanner: NSObject, @unchecked Sendable {
    private var scanContinuation: CheckedContinuation<[String: SensorData], Error>?
    private var centralManager: CBCentralManager?
    private var sensors: [String: SensorData.Type] = [:]
    private var currentSensorValues: [String: SensorData] = [:]

    func start(queue: DispatchQueue?) {
        if centralManager != nil {
            return
        }
        centralManager = CBCentralManager(delegate: self, queue: queue)
    }

    func registerSensor(peripheralIdentifier: String, sensorDataType: SensorData.Type) {
        sensors[peripheralIdentifier] = sensorDataType
    }

    func clearSensors() {
        sensors.removeAll()
    }

    func scanSensorValues() async throws -> [String: SensorData] {
//        let timeoutSeconds = 30
        let timeoutSeconds = 3

        return try await withThrowingTaskGroup(of: [String: SensorData].self) { group in
            group.addTask {
                return try await self.scanSensorValuesWithoutTimeout()
            }

            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeoutSeconds * 1_000_000_000))
                try Task.checkCancellation()
//                throw BLEAdvertisementScannerError.TimeOut
                return [:]
            }

            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }

    private func scanSensorValuesWithoutTimeout() async throws -> [String: SensorData] {
        try await withCheckedThrowingContinuation { continuation in
            if let recentScanContinuation = scanContinuation {
                recentScanContinuation.resume(throwing: BLEAdvertisementScannerError.AbortScanSensors)
                centralManager?.stopScan()
            }

            currentSensorValues = [:]
            scanContinuation = continuation

            let services = sensors.values
                .map { $0.serviceID }
                .uniqued()
                .map { CBUUID(string: $0) }
            centralManager?.scanForPeripherals(withServices: services, options: nil)
        }
    }

    private func parse(peripheralIdentifier: String, advertisementData: [String: Any]) {
        guard let dataType = sensors[peripheralIdentifier], let data = dataType.parse(advertisementData: advertisementData) else {
            scanContinuation?.resume(throwing: BLEAdvertisementScannerError.CouldNotParseSensorValue)
            centralManager?.stopScan()
            return
        }
        currentSensorValues[peripheralIdentifier] = data

        if Set(currentSensorValues.keys) == Set(sensors.keys) {
            scanContinuation?.resume(returning: currentSensorValues)
            centralManager?.stopScan()
        }
    }
}

extension BLEAdvertisementScanner: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let state: String
        switch central.state {
        case .unknown:
            state = "unknown"
        case .resetting:
            state = "resetting"
        case .unsupported:
            state = "unsupported"
        case .unauthorized:
            state = "unauthorized"
        case .poweredOff:
            state = "poweredOff"
        case .poweredOn:
            state = "poweredOn"
        @unknown default:
            state = "unknown"
        }

        print("central manager did update state [\(state)]")
    }

    func centralManager(_: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi _: NSNumber) {
        parse(peripheralIdentifier: peripheral.identifier.uuidString, advertisementData: advertisementData)
    }
}
