import ComposableArchitecture
import SwiftUI

@Reducer
struct HomeFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var roomMetricsHistories: [RoomSensorsHistory] = []

        var sections: [HomeSection] {
            roomMetricsHistories.map { history in
                HomeSection(
                    room: history.room,
                    roomStatuses: [
                        RoomStatus.summary(history),
                        RoomStatus.temperatureAndHumidity(history),
                    ]
                )
            }
        }
    }

    enum Action {
        case metricsHistoriesUpdate
        case recordMetrics
        case roomMetricsHistoriesResponse(TaskResult<[RoomSensorsHistory]>)
        case bleAdvertisementResponse(TaskResult<[Room: SensorsRecord]>)
        case saveRoomMetricsResponse(TaskResult<MetricsClient.Success>)
  }

    @Dependency(\.settings) var settings
    @Dependency(\.metricsClient) var metricsClient
    @Dependency(\.bleAdvertisementScanner) var bleAdvertisementScanner
    @Dependency(\.bleAdvertisementClient) var bleAdvertisementClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .metricsHistoriesUpdate:
                return .run { send in
                    await send(.roomMetricsHistoriesResponse(TaskResult { try await metricsClient.roomSensorsHistories() }))
                }
            case .recordMetrics:
                return .run { send in
                    await send(.bleAdvertisementResponse(TaskResult { try await bleAdvertisementClient.sensors(bleAdvertisementScanner, settings.sensor) }))
                }
            case let .roomMetricsHistoriesResponse(.success(roomMetricsHistories)):
                state.roomMetricsHistories = roomMetricsHistories
                return .none
            case let .roomMetricsHistoriesResponse(.failure(error)):
                print(error)
                return .none
            case let .bleAdvertisementResponse(.success(sensorsRecord)):
                return .run { send in
                    await send(.saveRoomMetricsResponse(TaskResult { try await metricsClient.saveRoomSensorRecords(sensorsRecord) }))
                }
            case let .bleAdvertisementResponse(.failure(error)):
                print(error)
                return .none
            case .saveRoomMetricsResponse(.success):
                return .none
            case let .saveRoomMetricsResponse(.failure(error)):
                print(error)
                return .none
            }
        }
    }
}

struct HomeView: View {
    let store: StoreOf<HomeFeature>

    private func roomView(_ section: HomeSection) -> some View {
        VStack {
            ForEach(section.roomStatuses) { status in
                switch status {
                case let .summary(history):
                    RoomSummaryView(history: history)
                case let .temperatureAndHumidity(history):
                    RoomStatusView(history: history, content: .temperatureAndHumidity)
                case let .co2(history):
                    RoomStatusView(history: history, content: .co2)
                case .blank:
                    RoomBlankView()
                }
            }
        }
        .background {
            AppTheme.backgroundColor
                .cornerRadius(8)
        }
    }

    var body: some View {
        if store.sections.count >= 3 {
            let living = store.sections[0]
            let bedroom = store.sections[1]
            let study = store.sections[2]
            Grid(horizontalSpacing: AppTheme.screenPadding, verticalSpacing: AppTheme.screenPadding) {
                GridRow {
                    roomView(living)
                    roomView(bedroom)
                }
                GridRow {
                    roomView(study)
                    Color.clear
                }
            }
        } else {
            EmptyView()
        }
    }
}

#Preview {
    HomeView(
        store: Store(initialState: HomeFeature.State(
            roomMetricsHistories: RoomSensorsHistory.mockHistories
        )) {
            HomeFeature()
        }
    )
    .previewLayout(PreviewLayout.fixed(width: 540, height: 504))
    .background { Color.black }
}
