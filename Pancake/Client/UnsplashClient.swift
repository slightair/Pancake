import ComposableArchitecture
import Foundation

struct UnsplashPhoto: Equatable, Decodable {
    struct URLs: Equatable, Decodable {
        let raw: URL
        let full: URL
        let regular: URL
    }

    let id: String
    let width: Int
    let height: Int
    let urls: URLs
}

extension UnsplashPhoto {
    static let mock = UnsplashPhoto(
        id: "mock",
        width: 768,
        height: 1024,
        urls: .init(
            raw: URL(string: "https://picsum.photos/id/866/768/1024.jpg?grayscale")!,
            full: URL(string: "https://picsum.photos/id/866/768/1024.jpg?grayscale")!,
            regular: URL(string: "https://picsum.photos/id/866/768/1024.jpg?grayscale")!
        )
    )
}

struct UnsplashClient {
    var topicPhotos: @Sendable (String, String, Int) async throws -> [UnsplashPhoto]
    var wallpaper: @Sendable (String) async throws -> UnsplashPhoto {
        { accessKey in
            try await topicPhotos(accessKey, "textures-patterns", 10).randomElement()!
        }
    }
}

extension UnsplashClient {
    static let live = UnsplashClient(
        topicPhotos: { accessKey, topic, numberOfPhotos in
            var urlComponents = URLComponents(string: "https://api.unsplash.com/topics/\(topic)/photos")!
            urlComponents.queryItems = [
                .init(name: "per_page", value: "\(numberOfPhotos)"),
                .init(name: "orientation", value: "landscape"),
                .init(name: "client_id", value: accessKey),
            ]
            let url = urlComponents.url!

            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode([UnsplashPhoto].self, from: data)
        }
    )

    static let mock = UnsplashClient(
        topicPhotos: { _, _, _ in
            [.mock]
        }
    )
}

private enum UnsplashClientKey: DependencyKey {
    static let liveValue = UnsplashClient.live
    static let previewValue = UnsplashClient.mock
}

extension DependencyValues {
    var unsplashClient: UnsplashClient {
        get { self[UnsplashClientKey.self] }
        set { self[UnsplashClientKey.self] = newValue }
    }
}
