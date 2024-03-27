import Foundation

enum Room: String {
    case living
    case bedroom
    case study

    var name: String {
        switch self {
        case .living:
            return "リビング"
        case .bedroom:
            return "寝室"
        case .study:
            return "書斎"
        }
    }

    var hasCO2Sensor: Bool {
        switch self {
        case .living:
            return true
        case .bedroom:
            return false
        case .study:
            return false
        }
    }
}
