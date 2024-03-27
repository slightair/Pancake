import ComposableArchitecture
import SwiftUI

enum Room: String {
    case living
    case bedroom
    case study

    var name: String {
        switch self {
        case .living:
            return "リビング"
        case .bedroom:
            return "寝室"
        case .study:
            return "書斎"
        }
    }

    var hasCO2Sensor: Bool {
        switch self {
        case .living:
            return true
        case .bedroom:
            return false
        case .study:
            return false
        }
    }
}

enum RoomStatus: Equatable, Identifiable {
    case summary(RoomSensorsHistory)
    case temperatureAndHumidity(RoomSensorsHistory)
    case co2(RoomSensorsHistory)
    case blank

    var id: String {
        switch self {
        case let .summary(history):
            return "Summary/\(history.id)"
        case let .temperatureAndHumidity(history):
            return "TemperatureAndHumidity/\(history.id)"
        case let .co2(history):
            return "CO2/\(history.id)"
        case .blank:
            return "Blank"
        }
    }
}

struct HomeSection: Equatable, Identifiable {
    let room: Room
    let roomStatuses: [RoomStatus]

    var id: String {
        room.rawValue
    }
}

struct Home: ReducerProtocol {
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

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
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

struct HomeView: View {
    let store: StoreOf<Home>

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
        WithViewStore(store, observe: { $0 }) { viewStore in
            if viewStore.sections.count >= 3 {
                let living = viewStore.sections[0]
                let bedroom = viewStore.sections[1]
                let study = viewStore.sections[2]
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
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(
            store: Store(initialState: Home.State(
                roomMetricsHistories: mockHistories
            )) {
                Home()
            }
        )
        .previewLayout(PreviewLayout.fixed(width: 540, height: 504))
        .background { Color.black }
    }
}

private let mockHistories : [RoomSensorsHistory] = [
    .mockLiving,
    .mockBedroom,
    .mockStudy,
]
