import ComposableArchitecture
import SwiftUI

struct Pancake: ReducerProtocol, Sendable {
    struct State: Equatable {
        var date = Date()
        var wallpaper: UnsplashPhoto?
        var header = Header.State()
        var eventList = EventList.State()
        var home = Home.State()
    }

    enum Action {
        case onAppear
        case onDisappear
        case tick
        case historyUpdate
        case wallpaperUpdate
        case wallpaperResponse(TaskResult<UnsplashPhoto>)
        case recordMetrics
        case header(Header.Action)
        case eventList(EventList.Action)
        case home(Home.Action)
    }

    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.date) var date
    @Dependency(\.settings) var settings
    @Dependency(\.unsplashClient) var unsplashClient

    private enum TickTimerID {}
    private enum HistoryUpdateTimerID {}
    private enum WallpaperUpdateTimerID {}
    private enum RecordMetricsTimerID {}

    var body: some ReducerProtocol<State, Action> {
        let startTimers: EffectTask<Action> = .merge([
            EffectTask.timer(id: TickTimerID.self, every: 1, on: mainQueue).map { _ in .tick },
            EffectTask.timer(id: HistoryUpdateTimerID.self, every: 900, on: mainQueue).map { _ in .historyUpdate },
            EffectTask.timer(id: WallpaperUpdateTimerID.self, every: 600, on: mainQueue).map { _ in .wallpaperUpdate },
            EffectTask.timer(id: RecordMetricsTimerID.self, every: 900, on: mainQueue).map { _ in .recordMetrics },
        ])

        let cancelTimers: EffectTask<Action> = .merge([
            .cancel(id: TickTimerID.self),
            .cancel(id: HistoryUpdateTimerID.self),
            .cancel(id: RecordMetricsTimerID.self),
            .cancel(id: WallpaperUpdateTimerID.self),
        ])

        let startUp: EffectTask<Action> = .merge([
            startTimers,
            EffectTask(value: .historyUpdate),
            EffectTask(value: .wallpaperUpdate),
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
            case .wallpaperUpdate:
                return .task {
                    await .wallpaperResponse(TaskResult { try await unsplashClient.wallpaper(settings.api.unsplashAccessKey) })
                }
            case let .wallpaperResponse(.success(wallpaper)):
                state.wallpaper = wallpaper
                return .none
            case let .wallpaperResponse(.failure(error)):
                print(error)
                return .none
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
    }
}

struct AppTheme {
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
        static let headerColor = UIColor.white
        static let textColor = UIColor.white
        static let notAvailableColor = UIColor.clear
    }
}

struct PancakeView: View {
    let store: StoreOf<Pancake>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                HStack(alignment: .top) {
                    VStack {
                        Spacer(minLength: 24)
                        HeaderView(store: store.scope(state: \.header, action: Pancake.Action.header))
                    }
                    Spacer()
                    VStack {
                        Spacer(minLength: 16)
                        HStack {
                            Spacer(minLength: 16)
                            CalendarView(selectedDate: viewStore.date)
                            Spacer(minLength: 16)
                        }
                    }
                    .frame(width: 360)
                }
                .frame(height: 360)

                HStack(alignment: .top) {
                    HomeView(store: store.scope(state: \.home, action: Pancake.Action.home))
                        .frame(width: 500)
                    VStack {
                        EventView(store: store.scope(state: \.eventList, action: Pancake.Action.eventList))
                        Color.clear
                    }
                }
            }
                 .shadow(color: AppTheme.shadowColor, radius: 8, x: 2, y: 4)
                 .padding(AppTheme.screenPadding)
                 .background {
                     AsyncImage(url: viewStore.wallpaper?.urls.full, transaction: Transaction(animation: .easeIn(duration: 1.0))) { phase in
                         switch phase {
                         case let .success(image):
                             image
                                 .resizable()
                                 .aspectRatio(contentMode: .fill)
                         default:
                             Color.black
                         }
                     }
                 }
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
    }
}
