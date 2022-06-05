import Foundation

struct SensorsRecord: Equatable {
    let date: Date
    let temperature: Double
    let humidity: Double
    let co2: Double

    var discomfortIndex: Double {
        0.81 * temperature + 0.01 * humidity * (0.99 * temperature - 14.3) + 46.3
    }

    var discomfortIndexText: String {
        switch discomfortIndex {
        case 0 ..< 55:
            return "寒い"
        case 55 ..< 60:
            return "肌寒い"
        case 60 ..< 65:
            return "何も感じない"
        case 65 ..< 70:
            return "快適"
        case 70 ..< 75:
            return "暑くない"
        case 75 ..< 80:
            return "やや暑い"
        case 80 ..< 85:
            return "暑くて汗が出る"
        case 85 ..< 100:
            return "暑くてたまらない"
        default:
            return "---"
        }
    }
}
