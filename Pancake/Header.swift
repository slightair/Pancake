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
        ),
        hourlyForecast: [
            HourlyForecastRecord(time: 10, temp: 18, weather: "晴れ", chanceOfRain: 0, iconURL: nil),
            HourlyForecastRecord(time: 11, temp: 20, weather: "晴れ", chanceOfRain: 10, iconURL: nil),
            HourlyForecastRecord(time: 12, temp: 21, weather: "晴れ", chanceOfRain: 0, iconURL: nil),
            HourlyForecastRecord(time: 13, temp: 22, weather: "晴れ", chanceOfRain: 10, iconURL: nil),
            HourlyForecastRecord(time: 14, temp: 21, weather: "晴れ", chanceOfRain: 20, iconURL: nil),
            HourlyForecastRecord(time: 15, temp: 19, weather: "晴れ", chanceOfRain: 0, iconURL: nil),
            HourlyForecastRecord(time: 16, temp: 21, weather: "晴れ", chanceOfRain: 20, iconURL: nil),
            HourlyForecastRecord(time: 17, temp: 19, weather: "晴れ", chanceOfRain: 0, iconURL: nil),
        ]
    )
}

struct HeaderState: Equatable, Identifiable {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
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
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    Text(viewStore.dateString)
                        .foregroundColor(AppTheme.textColor)
                        .font(.system(size: 100))
                        .monospacedDigit()
                        .bold()
                    Spacer()
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
                        initialState: .mock,
                        reducer: headerReducer,
                        environment: HeaderEnvironment()
                    )
                )
                .frame(maxHeight: .infinity)
                .gridCellColumns(2)
                .background {
                    Color(red: 0.9, green: 0.9, blue: 0.9)
                }
                Color.gray
            }
            .frame(height: 360)
        }
        .padding(AppTheme.screenPadding)
    }
}
