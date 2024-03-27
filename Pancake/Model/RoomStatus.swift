import Foundation

enum RoomStatus: Equatable, Identifiable {
    case summary(RoomSensorsHistory)
    case temperatureAndHumidity(RoomSensorsHistory)
    case co2(RoomSensorsHistory)
    case blank

    var id: String {
        switch self {
        case let .summary(history):
            return "Summary/\(history.id)"
        case let .temperatureAndHumidity(history):
            return "TemperatureAndHumidity/\(history.id)"
        case let .co2(history):
            return "CO2/\(history.id)"
        case .blank:
            return "Blank"
        }
    }
}
