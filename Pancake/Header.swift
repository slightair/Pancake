import ComposableArchitecture
import Foundation
import SwiftUI

extension Dashboard {
    static let mock = Dashboard(
        trainStatuses: [
            TrainStatus(route: .sobu, status: "平常運転"),
            TrainStatus(route: .chuo, status: "平常運転"),
            TrainStatus(route: .yamanote, status: "平常運転"),
        ],
        weather: Weather(
            tempMin: 3,
            tempMax: 10,
            tempMinDiff: 4,
            tempMaxDiff: -2,
            chanceOfRain: 20,
            iconURL: nil
        )
    )
}

struct HeaderState: Equatable, Identifiable {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    let id = UUID()
    var date = Date()
    var dashboard: Dashboard = .initial

    var dateString: String {
        Self.dateFormatter.string(from: date)
    }
}

extension HeaderState {
    static let mock = HeaderState(
        date: Date(),
        dashboard: .mock
    )
}

enum HeaderAction: Equatable {
    case timeUpdate(Date)
}

struct HeaderEnvironment {}

let headerReducer = Reducer<HeaderState, HeaderAction, HeaderEnvironment> { state, action, _ in
    switch action {
    case let .timeUpdate(date):
        state.date = date
        return .none
    }
}

struct HeaderView: View {
    let store: Store<HeaderState, HeaderAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            HStack(spacing: 16) {
                Text(viewStore.dateString)
                    .foregroundColor(AppTheme.textColor)
                    .font(.system(size: 90))
                    .monospacedDigit()
                    .bold()
                Spacer()
                WeatherView(weather: viewStore.dashboard.weather)
                TrainServiceView(statuses: viewStore.dashboard.trainStatuses)
            }
            .padding(AppTheme.panelPadding)
            .background {
                AppTheme.backgroundColor
            }
            .cornerRadius(AppTheme.cornerRadius)
        }
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(
            store: Store(
                initialState: .mock,
                reducer: headerReducer,
                environment: HeaderEnvironment()
            )
        )
    }
}
