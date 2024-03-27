import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct HeaderFeature {
    @ObservableState
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

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .timeUpdate:
                state.date = date.now
                return .none
            case .dashboardUpdate:
                return .run { send in
                    await send(.dashboardResponse(TaskResult { try await dashboardClient.dashboard(settings.dashboardAPIURL) }))
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
}

struct HeaderView: View {
    let store: StoreOf<HeaderFeature>

    var body: some View {
        VStack(spacing: 16) {
            HStack() {
                Spacer()
                    .frame(width: 4)
                Text(store.dateString)
                    .foregroundColor(AppTheme.textColor)
                    .font(.system(size: 112))
                    .monospacedDigit()
                    .bold()
                Spacer()
                WeatherView(weather: store.dashboard.weather)
                Spacer()
                TrainServiceView(statuses: store.dashboard.trainStatuses)
            }
            HStack(spacing: 2) {
                ForEach(store.dashboard.hourlyForecast) { record in
                    HourlyForecastRecordView(record: record)
                }
            }
        }
        .padding(12)
    }
}

#Preview {
    HeaderView(
        store: Store(initialState: HeaderFeature.State(
            dashboard: .mock
        )) {
            HeaderFeature()
        }
    )
    .previewLayout(PreviewLayout.sizeThatFits)
    .background { Color.black }
}
