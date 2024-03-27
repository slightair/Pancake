import ComposableArchitecture
import SwiftUI

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var date = Date()
        var header = HeaderFeature.State()
        var eventList = EventListFeature.State()
        var home = HomeFeature.State()
        var map = MapFeature.State()
    }

    enum Action {
        case onAppear
        case onDisappear
        case tick
        case historyUpdate
        case recordMetrics
        case header(HeaderFeature.Action)
        case eventList(EventListFeature.Action)
        case home(HomeFeature.Action)
        case map(MapFeature.Action)
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.date) var date
    @Dependency(\.settings) var settings

    private enum CancelID {
        case tick
        case historyUpdate
        case recordMetrics
        case mapUpdate
    }

    var body: some ReducerOf<Self> {
        let startTimers: Effect<Action> = .merge([
            .run { send in
                for await _ in self.clock.timer(interval: .seconds(1)) {
                    await send(.tick)
                }
            }.cancellable(id: CancelID.tick),
            .run { send in
                for await _ in self.clock.timer(interval: .seconds(900)) {
                    await send(.historyUpdate)
                }
            }.cancellable(id: CancelID.historyUpdate),
            .run { send in
                for await _ in self.clock.timer(interval: .seconds(900)) {
                    await send(.recordMetrics)
                }
            }.cancellable(id: CancelID.recordMetrics),
            .run { send in
                for await _ in self.clock.timer(interval: .seconds(300)) {
                    await send(.map(.mapUpdate))
                }
            }.cancellable(id: CancelID.mapUpdate),
        ])

        let cancelTimers: Effect<Action> = .merge([
            .cancel(id: CancelID.tick),
            .cancel(id: CancelID.historyUpdate),
            .cancel(id: CancelID.recordMetrics),
            .cancel(id: CancelID.mapUpdate),
        ])

        let startUp: Effect<Action> = .merge([
            startTimers,
            .send(.historyUpdate),
            .send(.map(.mapUpdate)),
        ])

        let terminate = cancelTimers

        Reduce { state, action in
            switch action {
            case .onAppear:
                return startUp
            case .onDisappear:
                return terminate
            case .tick:
                state.date = date.now
                return .merge([
                    .send(.header(.timeUpdate)),
                ])
            case .historyUpdate:
                return .merge([
                    .send(.header(.dashboardUpdate)),
                    .send(.home(.metricsHistoriesUpdate)),
                    .send(.eventList(.eventListUpdate)),
                ])
            case .recordMetrics:
                return .send(.home(.recordMetrics))
            default:
                return .none
            }
        }
        Scope(state: \.header, action: \.header) {
            HeaderFeature()
        }
        Scope(state: \.eventList, action: \.eventList) {
            EventListFeature()
        }
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }
        Scope(state: \.map, action: \.map) {
            MapFeature()
        }
    }
}

struct AppView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        HStack(spacing: AppTheme.screenPadding) {
            VStack(spacing: AppTheme.screenPadding) {
                HeaderView(store: store.scope(state: \.header, action: \.header))
                    .background {
                        AppTheme.backgroundColor
                            .cornerRadius(8)
                    }
                ZStack {
                    HomeView(store: store.scope(state: \.home, action: \.home))
                    Grid(horizontalSpacing: AppTheme.screenPadding, verticalSpacing: AppTheme.screenPadding) {
                        GridRow {
                            Color.clear
                            Color.clear
                        }
                        GridRow {
                            Color.clear
                            MapView(store: store.scope(state: \.map, action: \.map))
                        }
                    }
                }
            }
            VStack(spacing: AppTheme.screenPadding) {
                CalendarView(selectedDate: store.date, events: store.eventList.events)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .frame(width: 240, height: 288)
                    .background {
                        AppTheme.backgroundColor
                            .cornerRadius(8)
                    }
                EventListView(store: store.scope(state: \.eventList, action: \.eventList), maxEventCount: 12)
                    .padding(8)
                    .background {
                        AppTheme.backgroundColor
                            .cornerRadius(8)
                    }
            }
            .frame(width: 240)
        }
        .padding(AppTheme.screenPadding)
        .background { Color.black }
        .onAppear { store.send(.onAppear) }
        .onDisappear { store.send(.onDisappear) }
    }
}

#Preview {
    AppView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
    .previewDevice(PreviewDevice(rawValue: "iPad Pro (10.5-inch)"))
}
