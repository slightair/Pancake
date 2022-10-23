import ComposableArchitecture
import Foundation

enum Route: String, Hashable, Decodable {
    case sobu
    case chuo
    case yamanote

    var name: String {
        switch self {
        case .sobu:
            return "総武線"
        case .chuo:
            return "中央線"
        case .yamanote:
            return "山手線"
        }
    }
}

struct TrainStatus: Equatable, Identifiable, Decodable {
    var id: String {
        route.rawValue
    }

    let route: Route
    let status: String
}

struct Weather: Hashable, Decodable {
    let tempMin: Int
    let tempMax: Int
    let tempMinDiff: Int
    let tempMaxDiff: Int
    let chanceOfRain: Int
    let iconURL: URL?

    enum CodingKeys: String, CodingKey {
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case tempMinDiff = "temp_min_diff"
        case tempMaxDiff = "temp_max_diff"
        case chanceOfRain = "chance_of_rain"
        case iconURL = "icon_url"
    }

    static let unknown = Weather(
        tempMin: 0,
        tempMax: 0,
        tempMinDiff: 0,
        tempMaxDiff: 0,
        chanceOfRain: 0,
        iconURL: nil
    )
}

struct HourlyForecastRecord: Equatable, Identifiable, Decodable {
    var id: Int {
        time
    }

    let time: Int
    let temp: Int
    let weather: String
    let chanceOfRain: Int
    let iconURL: URL?

    enum CodingKeys: String, CodingKey {
        case time
        case temp
        case weather
        case chanceOfRain = "rain"
        case iconURL = "icon"
    }
}

struct Dashboard: Equatable, Decodable {
    let trainStatuses: [TrainStatus]
    let weather: Weather
    let hourlyForecast: [HourlyForecastRecord]
}

extension Dashboard {
    static let initial = Dashboard(
        trainStatuses: [
            TrainStatus(route: .sobu, status: "----"),
            TrainStatus(route: .chuo, status: "----"),
            TrainStatus(route: .yamanote, status: "----"),
        ],
        weather: .unknown,
        hourlyForecast: []
    )

    static let mock = Dashboard(
        trainStatuses: [
            TrainStatus(route: .sobu, status: "平常運転"),
            TrainStatus(route: .chuo, status: "平常運転"),
            TrainStatus(route: .yamanote, status: "平常運転"),
        ],
        weather: Weather(
            tempMin: 3,
            tempMax: 10,
            tempMinDiff: 4,
            tempMaxDiff: -2,
            chanceOfRain: 20,
            iconURL: nil
        ),
        hourlyForecast: [
            HourlyForecastRecord(time: 10, temp: 18, weather: "晴れ", chanceOfRain: 0, iconURL: nil),
            HourlyForecastRecord(time: 11, temp: 20, weather: "晴れ", chanceOfRain: 10, iconURL: nil),
            HourlyForecastRecord(time: 12, temp: 21, weather: "晴れ", chanceOfRain: 0, iconURL: nil),
            HourlyForecastRecord(time: 13, temp: 22, weather: "晴れ", chanceOfRain: 10, iconURL: nil),
            HourlyForecastRecord(time: 14, temp: 21, weather: "晴れ", chanceOfRain: 20, iconURL: nil),
            HourlyForecastRecord(time: 15, temp: 19, weather: "晴れ", chanceOfRain: 0, iconURL: nil),
            HourlyForecastRecord(time: 16, temp: 21, weather: "晴れ", chanceOfRain: 20, iconURL: nil),
            HourlyForecastRecord(time: 17, temp: 19, weather: "晴れ", chanceOfRain: 0, iconURL: nil),
        ]
    )
}

struct DashboardClient {
    var dashboard: @Sendable (URL) async throws -> Dashboard
}

extension DashboardClient {
    static let live = DashboardClient(
        dashboard: { apiURL in
            let (data, _) = try await URLSession.shared.data(from: apiURL)
            return try JSONDecoder().decode(Dashboard.self, from: data)
        }
    )

    static let mock = DashboardClient(
        dashboard: { _ in .mock }
    )
}

private enum DashboardClientKey: DependencyKey {
    static let liveValue = DashboardClient.live
    static let previewValue = DashboardClient.mock
}

extension DependencyValues {
    var dashboardClient: DashboardClient {
        get { self[DashboardClientKey.self] }
        set { self[DashboardClientKey.self] = newValue }
    }
}
