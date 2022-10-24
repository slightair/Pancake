import ComposableArchitecture
import Foundation
import SwiftUI

struct Header: ReducerProtocol {
    struct State: Equatable {
        private static let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            formatter.locale = Locale(identifier: "ja_JP")
            return formatter
        }()

        var date = Date()
        var dashboard: Dashboard = .initial

        var dateString: String {
            Self.dateFormatter.string(from: date)
        }
    }

    enum Action {
        case timeUpdate
        case dashboardUpdate
        case dashboardResponse(TaskResult<Dashboard>)
    }

    @Dependency(\.date) var date
    @Dependency(\.settings.api) var settings
    @Dependency(\.dashboardClient) var dashboardClient

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .timeUpdate:
            state.date = date.now
            return .none
        case .dashboardUpdate:
            return .task {
                await .dashboardResponse(TaskResult { try await dashboardClient.dashboard(settings.dashboardAPIURL) })
            }
        case let .dashboardResponse(.success(dashboard)):
            state.dashboard = dashboard
            return .none
        case let .dashboardResponse(.failure(error)):
            print(error)
            return .none
        }
    }
}

struct HeaderView: View {
    let store: StoreOf<Header>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 16) {
                HStack() {
                    Spacer()
                        .frame(width: 4)
                    Text(viewStore.dateString)
                        .foregroundColor(AppTheme.textColor)
                        .font(.system(size: 112))
                        .monospacedDigit()
                        .bold()
                    Spacer()
                        .frame(width: 16)
                    WeatherView(weather: viewStore.dashboard.weather)
                    TrainServiceView(statuses: viewStore.dashboard.trainStatuses)
                }
                HStack(spacing: 2) {
                    ForEach(viewStore.dashboard.hourlyForecast) { record in
                        HourlyForecastRecordView(record: record)
                    }
                }
                Spacer()
            }
            .padding(12)
        }
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        Grid {
            GridRow {
                HeaderView(
                    store: Store(
                        initialState: Header.State(
                            dashboard: .mock
                        ),
                        reducer: Header()
                    )
                )
                .frame(maxHeight: .infinity)
                .gridCellColumns(2)
                Color.gray
            }
            .frame(height: 360)
        }
        .padding(AppTheme.screenPadding)
    }
}