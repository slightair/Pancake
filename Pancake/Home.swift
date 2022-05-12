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
    case summary(RoomMetricsHistory)
    case temperatureAndHumidity(RoomMetricsHistory)
    case co2(RoomMetricsHistory)

    var id: String {
        switch self {
        case let .summary(history):
            return "Summary/\(history.id)"
        case let .temperatureAndHumidity(history):
            return "TemperatureAndHumidity/\(history.id)"
        case let .co2(history):
            return "CO2/\(history.id)"
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

struct HomeState: Equatable, Identifiable {
    let id = UUID()
    var roomMetricsHistories: [RoomMetricsHistory] = []

    var sections: [HomeSection] {
        roomMetricsHistories.map { history in
            HomeSection(
                room: history.room,
                roomStatuses: [
                    RoomStatus.summary(history),
                    RoomStatus.temperatureAndHumidity(history),
                    RoomStatus.co2(history),
                ].compactMap { status in
                    if !history.room.hasCO2Sensor, case .co2 = status {
                        return nil
                    } else {
                        return status
                    }
                }
            )
        }
    }
}

extension HomeState {
    static let mock = HomeState(
        roomMetricsHistories: [
            .mockLiving,
            .mockBedroom,
            .mockStudy,
        ]
    )
}

enum HomeAction: Equatable {
    case homeUpdate
}

struct HomeEnvironment {}

let homeReducer = Reducer<HomeState, HomeAction, HomeEnvironment> { state, action, _ in
    switch action {
    case .homeUpdate:
        return .none
    }
}

struct HomeView: View {
    let store: Store<HomeState, HomeAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(.flexible(),spacing: AppTheme.screenPadding),
                        count: 3
                    ),
                    spacing: AppTheme.screenPadding
                ) {
                    ForEach(viewStore.sections) { section in
                        Section {
                            ForEach(section.roomStatuses) { status in
                                switch status {
                                case let .summary(history):
                                    RoomSummaryView(history: history)
                                case let .temperatureAndHumidity(history):
                                    RoomStatusView(history: history, content: .temperatureAndHumidity)
                                case let .co2(history):
                                    RoomStatusView(history: history, content: .co2)
                                }
                            }
                            .aspectRatio(1.6, contentMode: .fit)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(
            store: Store(
                initialState: .mock,
                reducer: homeReducer,
                environment: HomeEnvironment()
            )
        )
    }
}
