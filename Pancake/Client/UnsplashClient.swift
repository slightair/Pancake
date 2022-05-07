import ComposableArchitecture

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
    var topicPhotos: (String, Int) -> Effect<[UnsplashPhoto], Failure>
    var wallpaper: () -> Effect<UnsplashPhoto, Failure> {
        {
            topicPhotos("textures-patterns", 10)
                .map { photos in
                    photos.randomElement()!
                }
        }
    }

    struct Failure: Error, Equatable {}
}

extension UnsplashClient {
    static let live = UnsplashClient(
        topicPhotos: { topic, numberOfPhotos in
            Effect.task {
                let settings = NSDictionary(contentsOf: Bundle.main.url(forResource: "Settings", withExtension: "plist")!)!
                let accessKey = settings["UnsplashAccessKey"] as! String
                var urlComponents = URLComponents(string: "https://api.unsplash.com/topics/\(topic)/photos")!
                urlComponents.queryItems = [
                    .init(name: "per_page", value: "\(numberOfPhotos)"),
                    .init(name: "orientation", value: "portrait"),
                    .init(name: "client_id", value: accessKey),
                ]
                let url = urlComponents.url!

                let (data, _) = try await URLSession.shared.data(from: url)
                return try JSONDecoder().decode([UnsplashPhoto].self, from: data)
            }
            .mapError { _ in Failure() }
            .eraseToEffect()
        }
    )
}
