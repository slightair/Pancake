import ComposableArchitecture
import CoreStore

struct RoomMetricsHistory: Equatable, Identifiable {
    let id = UUID()
    let room: Room
    let records: [MetricsHistoryRecord]
}

extension RoomMetricsHistory {
    static let mockLiving = RoomMetricsHistory(room: .living, records: mockRecords)
    static let mockBedroom = RoomMetricsHistory(room: .bedroom, records: mockRecords)
    static let mockStudy = RoomMetricsHistory(room: .study, records: mockRecords)
}

struct MetricsHistoryRecord: Equatable {
    let date: Date
    let temperature: Double
    let humidity: Double
    let co2: Double
}

struct LocalDBClient {
    var roomMetricsHistories: () -> Effect<[RoomMetricsHistory], Failure>

    struct Failure: Error, Equatable {}
}

extension LocalDBClient {
    static let live = LocalDBClient(
        roomMetricsHistories: {
            Effect.task {
//                let settings = NSDictionary(contentsOf: Bundle.main.url(forResource: "Settings", withExtension: "plist")!)!
//                let url = URL(string: settings["DashboardAPIURL"] as! String)!
//
//                let (data, _) = try await URLSession.shared.data(from: url)
//                return try JSONDecoder().decode(Dashboard.self, from: data)
                return []
            }
            .mapError { _ in Failure() }
            .eraseToEffect()
        }
    )

    static let mock = LocalDBClient(
        roomMetricsHistories: {
            Effect(value: [.mockLiving, .mockBedroom, .mockStudy])
        }
    )
}

private let mockRecords = [
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651727895), temperature: 23.9, humidity: 43.0, co2: 545.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651727295), temperature: 23.9, humidity: 43.0, co2: 534.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651726695), temperature: 23.9, humidity: 43.0, co2: 539.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651726095), temperature: 23.9, humidity: 43.0, co2: 531.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651725495), temperature: 23.9, humidity: 43.0, co2: 565.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651724895), temperature: 24.0, humidity: 44.0, co2: 601.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651724295), temperature: 24.0, humidity: 45.0, co2: 629.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651723695), temperature: 24.1, humidity: 45.0, co2: 621.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651723095), temperature: 24.0, humidity: 45.0, co2: 601.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651722495), temperature: 24.1, humidity: 45.0, co2: 601.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651721895), temperature: 24.0, humidity: 45.0, co2: 622.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651721295), temperature: 24.0, humidity: 45.0, co2: 624.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651720695), temperature: 24.0, humidity: 46.0, co2: 680.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651720095), temperature: 23.8, humidity: 48.0, co2: 665.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651719495), temperature: 23.8, humidity: 48.0, co2: 629.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651718895), temperature: 23.4, humidity: 45.0, co2: 686.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651718295), temperature: 23.2, humidity: 47.0, co2: 771.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651717695), temperature: 23.1, humidity: 47.0, co2: 744.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651717095), temperature: 22.9, humidity: 47.0, co2: 747.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651716495), temperature: 22.9, humidity: 48.0, co2: 785.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651715895), temperature: 22.8, humidity: 49.0, co2: 793.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651715295), temperature: 22.7, humidity: 48.0, co2: 772.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651714695), temperature: 22.6, humidity: 47.0, co2: 752.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651714095), temperature: 22.5, humidity: 48.0, co2: 758.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651713495), temperature: 22.5, humidity: 49.0, co2: 816.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651712895), temperature: 22.5, humidity: 49.0, co2: 854.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651712295), temperature: 22.4, humidity: 50.0, co2: 860.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651711695), temperature: 22.3, humidity: 49.0, co2: 871.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651711095), temperature: 22.2, humidity: 49.0, co2: 913.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651710495), temperature: 22.1, humidity: 50.0, co2: 903.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651709895), temperature: 21.9, humidity: 49.0, co2: 851.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651709295), temperature: 21.8, humidity: 48.0, co2: 950.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651708695), temperature: 21.8, humidity: 49.0, co2: 903.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651708095), temperature: 21.7, humidity: 49.0, co2: 778.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651707495), temperature: 21.5, humidity: 49.0, co2: 476.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651706895), temperature: 21.5, humidity: 48.0, co2: 472.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651706295), temperature: 21.5, humidity: 48.0, co2: 472.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651705695), temperature: 21.5, humidity: 49.0, co2: 485.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651705095), temperature: 21.5, humidity: 49.0, co2: 466.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651704495), temperature: 21.5, humidity: 49.0, co2: 476.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651703895), temperature: 21.4, humidity: 49.0, co2: 477.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651703295), temperature: 21.5, humidity: 49.0, co2: 487.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651702694), temperature: 21.4, humidity: 49.0, co2: 481.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651702094), temperature: 21.4, humidity: 49.0, co2: 479.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651701494), temperature: 21.5, humidity: 49.0, co2: 474.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651700894), temperature: 21.4, humidity: 49.0, co2: 476.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651700294), temperature: 21.4, humidity: 49.0, co2: 473.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651699694), temperature: 21.5, humidity: 49.0, co2: 467.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651699094), temperature: 21.5, humidity: 48.0, co2: 472.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651698497), temperature: 21.5, humidity: 48.0, co2: 483.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651697894), temperature: 21.5, humidity: 48.0, co2: 480.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651697294), temperature: 21.5, humidity: 48.0, co2: 478.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651696694), temperature: 21.5, humidity: 48.0, co2: 489.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651696094), temperature: 21.5, humidity: 48.0, co2: 488.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651695494), temperature: 21.6, humidity: 48.0, co2: 495.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651694894), temperature: 21.6, humidity: 48.0, co2: 487.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651694294), temperature: 21.6, humidity: 48.0, co2: 491.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651693694), temperature: 21.7, humidity: 48.0, co2: 493.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651693094), temperature: 21.7, humidity: 48.0, co2: 479.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651692494), temperature: 21.7, humidity: 48.0, co2: 495.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651691894), temperature: 21.8, humidity: 49.0, co2: 504.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651691294), temperature: 21.8, humidity: 49.0, co2: 497.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651690694), temperature: 21.8, humidity: 49.0, co2: 517.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651690094), temperature: 21.9, humidity: 49.0, co2: 513.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651689494), temperature: 21.9, humidity: 49.0, co2: 521.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651688894), temperature: 21.9, humidity: 49.0, co2: 523.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651688294), temperature: 21.9, humidity: 49.0, co2: 530.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651687694), temperature: 22.0, humidity: 49.0, co2: 534.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651687094), temperature: 22.0, humidity: 49.0, co2: 544.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651686494), temperature: 22.1, humidity: 49.0, co2: 560.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651685894), temperature: 22.1, humidity: 49.0, co2: 568.0),
    MetricsHistoryRecord(date: Date(timeIntervalSince1970: 1651685294), temperature: 22.2, humidity: 49.0, co2: 562.0),
]
