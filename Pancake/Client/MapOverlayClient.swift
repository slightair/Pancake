import ComposableArchitecture
import UIKit

struct KeyTime: CustomStringConvertible, Equatable {
    private static let dateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmm"
        return formatter
    }()

    private static let unit: TimeInterval = 60 * 5

    var key: String {
        Self.dateFormatter.string(from: date)
    }

    var prev: KeyTime {
        KeyTime(date: date.advanced(by: -Self.unit))
    }

    var description: String { key }

    let date: Date

    init(date: Date) {
        let unixTime = date.timeIntervalSince1970
        self.date = Date(timeIntervalSince1970: unixTime - unixTime.truncatingRemainder(dividingBy: Self.unit))
    }
}

struct MapOverlayClient {
    var overlayImage: @Sendable (String, Date) async throws -> (UIImage, KeyTime)
}

enum MapOverlayClientError: Error, Equatable {
    case failedToFetchImage
}

extension MapOverlayClient {
    static let live = MapOverlayClient(
        overlayImage: { imageProviderURLTemplate, date in
            func fetchOverlayImage(keyTime: KeyTime) async throws -> UIImage {
                let url = URL(string: imageProviderURLTemplate.replacingOccurrences(of: "{timeKey}", with: keyTime.key))!
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let image = UIImage(data: data) else {
                    throw MapOverlayClientError.failedToFetchImage
                }
                return image
            }

            let keyTime = KeyTime(date: date)
            if let image = try? await fetchOverlayImage(keyTime: keyTime) {
                return (image, keyTime)
            } else {
                let retryTime = keyTime.prev
                return try await (fetchOverlayImage(keyTime: retryTime), retryTime)
            }
        }
    )

    static let mock = MapOverlayClient(
        overlayImage: { _, _ in
            throw MapOverlayClientError.failedToFetchImage
        }
    )
}

private enum MapOverlayClientKey: DependencyKey {
    static let liveValue = MapOverlayClient.live
    static let previewValue = MapOverlayClient.mock
}

extension DependencyValues {
    var mapOverlayClient: MapOverlayClient {
        get { self[MapOverlayClientKey.self] }
        set { self[MapOverlayClientKey.self] = newValue }
    }
}
