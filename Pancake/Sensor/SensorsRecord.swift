import Foundation

struct SensorsRecord: Equatable, Codable {
    let date: Date
    let temperature: Double
    let humidity: Double
    let co2: Double

    var discomfortIndex: Double {
        0.81 * temperature + 0.01 * humidity * (0.99 * temperature - 14.3) + 46.3
    }

    enum CodingKeys: String, CodingKey {
        case date = "time"
        case temperature
        case humidity
        case co2
    }
}
