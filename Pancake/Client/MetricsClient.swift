import ComposableArchitecture

struct MetricsClient {
    var roomMetricsHistories: () -> Effect<[RoomSensorsHistory], Failure>

    struct Failure: Error, Equatable {}
}

extension MetricsClient {
    static let live = MetricsClient(
        roomMetricsHistories: {
            Effect.task {
//                let settings = NSDictionary(contentsOf: Bundle.main.url(forResource: "Settings", withExtension: "plist")!)!
//                let url = URL(string: settings["DashboardAPIURL"] as! String)!
//
//                let (data, _) = try await URLSession.shared.data(from: url)
//                return try JSONDecoder().decode(Dashboard.self, from: data)
                []
            }
            .mapError { _ in Failure() }
            .eraseToEffect()
        }
    )

    static let mock = MetricsClient(
        roomMetricsHistories: {
            Effect(value: [.mockLiving, .mockBedroom, .mockStudy])
        }
    )
}
