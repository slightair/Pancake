import ComposableArchitecture
import SwiftUI

struct AppState: Equatable {
    var header = HeaderState()
    var event = EventState()
    var home = HomeState()
    var trainService = TrainServiceState()
}

enum AppAction: Equatable {
    case onAppear
    case onDisappear
    case tick
    case historyUpdate
    case dashboardResponse(Result<Dashboard, DashboardClient.Failure>)
    case header(HeaderAction)
    case event(EventAction)
    case home(HomeAction)
    case trainService(TrainServiceAction)
}

struct AppEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var uuid: () -> UUID
    var dashboardClient: DashboardClient

    static let live = Self(
        mainQueue: .main,
        uuid: UUID.init,
        dashboardClient: .live
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
            return environment.dashboardClient.dashboard()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(AppAction.dashboardResponse)
        case let .dashboardResponse(.success(dashboard)):
            state.header.weather = dashboard.weather
            state.trainService.statuses = dashboard.trainStatuses
            return .none
        case let .dashboardResponse(.failure(error)):
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
        ),
    trainServiceReducer
        .pullback(
            state: \.trainService,
            action: /AppAction.trainService,
            environment: { _ in .init() }
        )
)

struct AppView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(store.stateless) { viewStore in
            VStack {
                HeaderView(store: store.scope(state: \.header, action: AppAction.header))
                EventView(store: store.scope(state: \.event, action: AppAction.event))
                HomeView(store: store.scope(state: \.home, action: AppAction.home))
                TrainServiceView(store: store.scope(state: \.trainService, action: AppAction.trainService))
                Spacer()
            }
            .onAppear { viewStore.send(.onAppear) }
            .onDisappear { viewStore.send(.onDisappear) }
        }
    }
}
