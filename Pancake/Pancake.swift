import ComposableArchitecture
import SwiftUI

struct AppState: Equatable {
    var wallpaper: UnsplashPhoto?
    var header = HeaderState()
    var event = EventState()
    var home = HomeState()
}

enum AppAction: Equatable {
    case onAppear
    case onDisappear
    case tick
    case historyUpdate
    case dashboardResponse(Result<Dashboard, DashboardClient.Failure>)
    case wallpaperResponse(Result<UnsplashPhoto, UnsplashClient.Failure>)
    case header(HeaderAction)
    case event(EventAction)
    case home(HomeAction)
}

struct AppEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var uuid: () -> UUID
    var dashboardClient: DashboardClient
    var unsplashClient: UnsplashClient

    static let live = Self(
        mainQueue: .main,
        uuid: UUID.init,
        dashboardClient: .live,
        unsplashClient: .live
    )
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    .init { state, action, environment in
        struct TickTimerID: Hashable {}
        struct HistoryUpdateTimerID: Hashable {}

        let startTimers: Effect<AppAction, Never> = .merge([
            Effect.timer(id: TickTimerID(), every: 1, tolerance: 0, on: environment.mainQueue)
                .map { _ in .tick }
                .eraseToEffect(),
            Effect.timer(id: HistoryUpdateTimerID(), every: 600, tolerance: 0, on: environment.mainQueue)
                .map { _ in .historyUpdate }
                .eraseToEffect(),
        ])

        let cancelTimers: Effect<AppAction, Never> = .merge([
            .cancel(id: TickTimerID()),
            .cancel(id: HistoryUpdateTimerID()),
        ])

        let startUp: Effect<AppAction, Never> = .merge([
            startTimers,
            Effect(value: AppAction.historyUpdate),
        ])

        let terminate = cancelTimers

        switch action {
        case .onAppear:
            return startUp
        case .onDisappear:
            return terminate
        case .tick:
            let date = Date()
            return .merge([
                Effect(value: .header(.timeUpdate(date))),
                Effect(value: .event(.eventListUpdate(date))),
            ])
        case .historyUpdate:
            return .merge([
                environment.dashboardClient.dashboard()
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map(AppAction.dashboardResponse),
                environment.unsplashClient.wallpaper()
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map(AppAction.wallpaperResponse),
            ])
        case let .dashboardResponse(.success(dashboard)):
            state.header.dashboard = dashboard
            return .none
        case let .dashboardResponse(.failure(error)):
            print(error)
            return .none
        case let .wallpaperResponse(.success(wallpaper)):
            print(wallpaper)
            state.wallpaper = wallpaper
            return .none
        case let .wallpaperResponse(.failure(error)):
            print(error)
            return .none
        default:
            return .none
        }
    },
    headerReducer
        .pullback(
            state: \.header,
            action: /AppAction.header,
            environment: { _ in .init() }
        ),
    eventReducer
        .pullback(
            state: \.event,
            action: /AppAction.event,
            environment: { _ in .init() }
        ),
    homeReducer
        .pullback(
            state: \.home,
            action: /AppAction.home,
            environment: { _ in .init() }
        )
)

struct AppTheme {
    static let backgroundColor = Color(uiColor: UIKit.backgroundColor)
    static let textColor = Color(uiColor: UIKit.textColor)
    static let panelPadding: CGFloat = 4
    static let cornerRadius: CGFloat = 8

    struct UIKit {
        static let backgroundColor = UIColor(red: 0.109, green: 0.109, blue: 0.117, alpha: 0.4)
        static let textColor = UIColor.white
    }
}

struct AppView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: AppTheme.panelPadding) {
                HeaderView(store: store.scope(state: \.header, action: AppAction.header))
                EventView(store: store.scope(state: \.event, action: AppAction.event))
                HomeView(store: store.scope(state: \.home, action: AppAction.home))
                Spacer()
            }
            .padding(4)
            .background {
                AsyncImage(url: viewStore.wallpaper?.urls.full) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    AppTheme.backgroundColor
                }
            }
            .onAppear { viewStore.send(.onAppear) }
            .onDisappear { viewStore.send(.onDisappear) }
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(
            store: Store(
                initialState: AppState(
                    wallpaper: .mock,
                    header: .mock,
                    event: EventState(),
                    home: HomeState()
                ),
                reducer: Reducer<AppState, AppAction, AppEnvironment> { _, _, _ in .none },
                environment: .live
            )
        )
    }
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
