import Foundation
import ComposableArchitecture

struct Settings: Decodable {
    struct API: Decodable {
        let dashboardAPI: String
        let unsplashAccessKey: String

        var dashboardAPIURL: URL {
            URL(string: dashboardAPI)!
        }
    }

    struct Sensor: Decodable {
        let livingThermometerPeripheralID: String
        let livingCO2PeripheralID: String
        let bedroomThermometerPeripheralID: String
        let studyThermometerPeripheralID: String
    }

    let api: API
    let sensor: Sensor
}

extension Settings {
    static let live: Settings = {
        let path = Bundle.main.url(forResource: "Settings", withExtension: "plist")!
        return try! PropertyListDecoder().decode(Settings.self, from: Data(contentsOf: path))
    }()

    static let mock = Settings(
        api: API(
            dashboardAPI: "https://example.com",
            unsplashAccessKey: "access key"
        ),
        sensor: Sensor(
            livingThermometerPeripheralID: "living thermometer",
            livingCO2PeripheralID: "living co2",
            bedroomThermometerPeripheralID: "bedroom thermometer",
            studyThermometerPeripheralID: "study thermometer"
        )
    )
}

private enum SettingsKey: DependencyKey {
    static let liveValue = Settings.live
    static let previewValue = Settings.mock
}

extension DependencyValues {
    var settings: Settings {
        get { self[SettingsKey.self] }
        set { self[SettingsKey.self] = newValue }
    }
}
