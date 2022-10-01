import Foundation

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
}
