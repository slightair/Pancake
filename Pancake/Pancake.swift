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
    case recordMetrics
    case dashboardResponse(Result<Dashboard, DashboardClient.Failure>)
    case wallpaperResponse(Result<UnsplashPhoto, UnsplashClient.Failure>)
    case roomMetricsHistoriesResponse(Result<[RoomSensorsHistory], MetricsClient.Failure>)
    case saveRoomMetricsResponse(Result<MetricsClient.Success, MetricsClient.Failure>)
    case eventListResponse(Result<[Event], EventClient.Failure>)
    case bleAdvertisementResponse(Result<[Room: SensorsRecord], BLEAdvertisementClient.Failure>)
    case header(HeaderAction)
    case event(EventAction)
    case home(HomeAction)
}

struct AppEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var uuid: () -> UUID
    var dashboardClient: DashboardClient
    var unsplashClient: UnsplashClient
    var metricsClient: MetricsClient
    var eventClient: EventClient
    var bleAdvertisementScanner: BLEAdvertisementScanner
    var bleAdvertisementClient: BLEAdvertisementClient
    var settings: Settings

    static let live = Self(
        mainQueue: .main,
        uuid: UUID.init,
        dashboardClient: .live,
        unsplashClient: .live,
        metricsClient: .live,
        eventClient: .live,
        bleAdvertisementScanner: .live,
        bleAdvertisementClient: .live,
        settings: .live
    )

    static let dev = Self(
        mainQueue: .main,
        uuid: UUID.init,
        dashboardClient: .live,
        unsplashClient: .live,
        metricsClient: .dev,
        eventClient: .live,
        bleAdvertisementScanner: .watch,
        bleAdvertisementClient: .dev,
        settings: .live
    )

    static let watch = Self(
        mainQueue: .main,
        uuid: UUID.init,
        dashboardClient: .live,
        unsplashClient: .live,
        metricsClient: .dev,
        eventClient: .live,
        bleAdvertisementScanner: .watch,
        bleAdvertisementClient: .watch,
        settings: .live
    )
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    .init { state, action, environment in
        struct TickTimerID: Hashable {}
        struct HistoryUpdateTimerID: Hashable {}
        struct RecordMetricsTimerID: Hashable {}

        let startTimers: Effect<AppAction, Never> = .merge([
            Effect.timer(id: TickTimerID(), every: 1, tolerance: 0, on: environment.mainQueue)
                .map { _ in .tick }
                .eraseToEffect(),
            Effect.timer(id: HistoryUpdateTimerID(), every: 600, tolerance: 0, on: environment.mainQueue)
                .map { _ in .historyUpdate }
                .eraseToEffect(),
            Effect.timer(id: RecordMetricsTimerID(), every: 600, tolerance: 0, on: environment.mainQueue)
                .map { _ in .recordMetrics }
                .eraseToEffect(),
        ])

        let cancelTimers: Effect<AppAction, Never> = .merge([
            .cancel(id: TickTimerID()),
            .cancel(id: HistoryUpdateTimerID()),
            .cancel(id: RecordMetricsTimerID()),
        ])

        let startUp: Effect<AppAction, Never> = .merge([
            startTimers,
            Effect(value: AppAction.historyUpdate),
            Effect(value: AppAction.recordMetrics),
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
                environment.dashboardClient.dashboard(environment.settings.api.dashboardAPIURL)
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map(AppAction.dashboardResponse),
                environment.unsplashClient.wallpaper(environment.settings.api.unsplashAccessKey)
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map(AppAction.wallpaperResponse),
                environment.metricsClient.roomSensorsHistories()
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map(AppAction.roomMetricsHistoriesResponse),
                environment.eventClient.events()
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map(AppAction.eventListResponse),
            ])
        case .recordMetrics:
            return environment.bleAdvertisementClient.sensors(environment.bleAdvertisementScanner, environment.settings.sensor)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(AppAction.bleAdvertisementResponse)
        case let .dashboardResponse(.success(dashboard)):
            state.header.dashboard = dashboard
            return .none
        case let .dashboardResponse(.failure(error)):
            print(error)
            return .none
        case let .wallpaperResponse(.success(wallpaper)):
            state.wallpaper = wallpaper
            return .none
        case let .wallpaperResponse(.failure(error)):
            print(error)
            return .none
        case let .roomMetricsHistoriesResponse(.success(roomMetricsHistories)):
            state.home.roomMetricsHistories = roomMetricsHistories
            return .none
        case let .roomMetricsHistoriesResponse(.failure(error)):
            print(error)
            return .none
        case .saveRoomMetricsResponse(.success):
            return .none
        case let .saveRoomMetricsResponse(.failure(error)):
            print(error)
            return .none
        case let .eventListResponse(.success(eventList)):
            state.event.events = eventList
            return .none
        case let .eventListResponse(.failure(error)):
            print(error)
            return .none
        case let .bleAdvertisementResponse(.success(sensorsRecord)):
            return environment.metricsClient.saveRoomSensorRecords(sensorsRecord)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(AppAction.saveRoomMetricsResponse)
        case let .bleAdvertisementResponse(.failure(error)):
            print(error)
            return .none
        default:
            return .none
        }
    },
    headerReducer
        .pullback(
            state: \.header,
            action: CasePath(AppAction.header),
            environment: { _ in .init() }
        ),
    eventReducer
        .pullback(
            state: \.event,
            action: CasePath(AppAction.event),
            environment: { _ in .init() }
        ),
    homeReducer
        .pullback(
            state: \.home,
            action: CasePath(AppAction.home),
            environment: { _ in .init() }
        )
)

struct AppTheme {
    static let backgroundColor = Color(uiColor: UIKit.backgroundColor)
    static let headerColor = Color(uiColor: UIKit.headerColor)
    static let textColor = Color(uiColor: UIKit.textColor)
    static let notAvailableColor = Color(uiColor: UIKit.notAvailableColor)
    static let headerFont = Font.system(size: 10).monospacedDigit().bold()
    static let textFont = Font.system(.body).monospacedDigit().bold()
    static let screenPadding: CGFloat = 4
    static let panelPadding: CGFloat = 8
    static let cornerRadius: CGFloat = 8

    struct UIKit {
        static let backgroundColor = UIColor(red: 0.109, green: 0.109, blue: 0.117, alpha: 0.6)
        static let headerColor = UIColor(white: 0.8, alpha: 1.0)
        static let textColor = UIColor.white
        static let notAvailableColor = UIColor(white: 0.5, alpha: 1.0)
    }
}

struct AppView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: AppTheme.screenPadding) {
                HeaderView(store: store.scope(state: \.header, action: AppAction.header))
                EventView(store: store.scope(state: \.event, action: AppAction.event))
                HomeView(store: store.scope(state: \.home, action: AppAction.home))
                Spacer(minLength: 0)
            }
            .padding(AppTheme.screenPadding)
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
                    event: .mock,
                    home: .mock
                ),
                reducer: Reducer<AppState, AppAction, AppEnvironment> { _, _, _ in .none },
                environment: .live
            )
        )
    }
}
