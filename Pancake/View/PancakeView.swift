import ComposableArchitecture
import SwiftUI

struct Pancake: ReducerProtocol, Sendable {
    struct State: Equatable {
        var date = Date()
        var wallpaper: UnsplashPhoto?
        var header = Header.State()
        var eventList = EventList.State()
        var home = Home.State()
        var map = Map.State()
    }

    enum Action {
        case onAppear
        case onDisappear
        case tick
        case historyUpdate
        case recordMetrics
        case header(Header.Action)
        case eventList(EventList.Action)
        case home(Home.Action)
        case map(Map.Action)
    }

    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.date) var date
    @Dependency(\.settings) var settings
    @Dependency(\.unsplashClient) var unsplashClient

    private enum TickTimerID {}
    private enum HistoryUpdateTimerID {}
    private enum RecordMetricsTimerID {}
    private enum MapUpdateTimerID {}

    var body: some ReducerProtocol<State, Action> {
        let startTimers: EffectTask<Action> = .merge([
            EffectTask.timer(id: TickTimerID.self, every: 1, on: mainQueue).map { _ in .tick },
            EffectTask.timer(id: HistoryUpdateTimerID.self, every: 900, on: mainQueue).map { _ in .historyUpdate },
            EffectTask.timer(id: RecordMetricsTimerID.self, every: 900, on: mainQueue).map { _ in .recordMetrics },
            EffectTask.timer(id: MapUpdateTimerID.self, every: 300, on: mainQueue).map { _ in .map(.mapUpdate) },
        ])

        let cancelTimers: EffectTask<Action> = .merge([
            .cancel(id: TickTimerID.self),
            .cancel(id: HistoryUpdateTimerID.self),
            .cancel(id: RecordMetricsTimerID.self),
            .cancel(id: MapUpdateTimerID.self),
        ])

        let startUp: EffectTask<Action> = .merge([
            startTimers,
            EffectTask(value: .historyUpdate),
            EffectTask(value: .map(.mapUpdate)),
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
                    EffectTask(value: .header(.timeUpdate)),
                ])
            case .historyUpdate:
                return .merge([
                    EffectTask(value: .header(.dashboardUpdate)),
                    EffectTask(value: .home(.metricsHistoriesUpdate)),
                    EffectTask(value: .eventList(.eventListUpdate)),
                ])
            case .recordMetrics:
                return EffectTask(value: .home(.recordMetrics))
            default:
                return .none
            }
        }
        Scope(state: \.header, action: /Action.header) {
            Header()
        }
        Scope(state: \.eventList, action: /Action.eventList) {
            EventList()
        }
        Scope(state: \.home, action: /Action.home) {
            Home()
        }
        Scope(state: \.map, action: /Action.map) {
            Map()
        }
    }
}

struct AppTheme {
    static let backgroundColor = Color(uiColor: UIKit.backgroundColor)
    static let headerColor = Color(uiColor: UIKit.headerColor)
    static let textColor = Color(uiColor: UIKit.textColor)
    static let notAvailableColor = Color(uiColor: UIKit.notAvailableColor)
    static let shadowColor = Color(red: 0.1, green: 0.1, blue: 0.1)
    static let headerFont = Font.system(size: 10).monospacedDigit().bold()
    static let textFont = Font.system(.body).monospacedDigit().bold()
    static let screenPadding: CGFloat = 4
    static let panelPadding: CGFloat = 8
    static let cornerRadius: CGFloat = 8

    struct UIKit {
        static let backgroundColor = UIColor(red: 0.109, green: 0.109, blue: 0.117, alpha: 1.0)
        static let headerColor = UIColor.white
        static let textColor = UIColor.white
        static let notAvailableColor = UIColor.clear
    }
}

struct PancakeView: View {
    let store: StoreOf<Pancake>

    var body: some View {
        WithViewStore(store) { viewStore in
            HStack(spacing: AppTheme.screenPadding) {
                VStack(spacing: AppTheme.screenPadding) {
                    HeaderView(store: store.scope(state: \.header, action: Pancake.Action.header))
                        .background {
                            AppTheme.backgroundColor
                                .cornerRadius(8)
                        }
                    ZStack {
                        HomeView(store: store.scope(state: \.home, action: Pancake.Action.home))
                        Grid(horizontalSpacing: AppTheme.screenPadding, verticalSpacing: AppTheme.screenPadding) {
                            GridRow {
                                Color.clear
                                Color.clear
                            }
                            GridRow {
                                Color.clear
                                MapView(store: store.scope(state: \.map, action: Pancake.Action.map))
                            }
                        }
                    }
                }
                VStack(spacing: AppTheme.screenPadding) {
                    CalendarView(selectedDate: viewStore.date, events: viewStore.eventList.events)
                        .padding(.top, 4)
                        .frame(width: 240, height: 288)
                        .background {
                            AppTheme.backgroundColor
                                .cornerRadius(8)
                        }
                    EventView(store: store.scope(state: \.eventList, action: Pancake.Action.eventList), maxEventCount: 12)
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
                 .onAppear { viewStore.send(.onAppear) }
                 .onDisappear { viewStore.send(.onDisappear) }
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        PancakeView(
            store: Store(
                initialState: Pancake.State(),
                reducer: Pancake()
            )
        )
        .previewDevice(PreviewDevice(rawValue: "iPad Pro (10.5-inch)"))
    }
}
