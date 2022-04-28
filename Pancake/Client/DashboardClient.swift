import ComposableArchitecture

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

struct Dashboard: Equatable, Decodable {
    let trainStatuses: [TrainStatus]
    let weather: Weather
}

struct DashboardClient {
    var dashboard: () -> Effect<Dashboard, Failure>

    struct Failure: Error, Equatable {}
}

extension DashboardClient {
    static let live = DashboardClient(
        dashboard: {
            Effect.task {
                let settings = NSDictionary(contentsOf: Bundle.main.url(forResource: "Settings", withExtension: "plist")!)!
                let url = URL(string: settings["DashboardAPIURL"] as! String)!

                let (data, _) = try await URLSession.shared.data(from: url)
                return try JSONDecoder().decode(Dashboard.self, from: data)
            }
            .mapError { _ in Failure() }
            .eraseToEffect()
        }
    )
}
