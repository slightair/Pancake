import ComposableArchitecture
import Foundation
import SwiftUI

struct HeaderState: Equatable, Identifiable {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    let id = UUID()
    var date = Date()
    var weather: Weather = .unknown

    var dateString: String {
        Self.dateFormatter.string(from: date)
    }
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

struct WeatherView: View {
    let weather: Weather

    let tempMaxColor = Color(red: 0.93, green: 0.33, blue: 0.27)
    let tempMinColor = Color(red: 0.50, green: 0.82, blue: 0.98)
    let miniFont = Font.system(size: 12).bold()

    private let tempDiffNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.positivePrefix = "▲"
        formatter.negativePrefix = "▼"

        return formatter
    }()

    func tempView() -> some View {
        guard let tempMaxDiff = tempDiffNumberFormatter.string(from: NSNumber(value: weather.tempMaxDiff)),
              let tempMinDiff = tempDiffNumberFormatter.string(from: NSNumber(value: weather.tempMinDiff)) else {
            fatalError("Could not format numbers")
        }

        return [
            Text("\(weather.tempMax)").foregroundColor(tempMaxColor),
            Text("[\(tempMaxDiff)]").foregroundColor(tempMaxColor).font(miniFont),
            Text(" / "),
            Text("\(weather.tempMin)").foregroundColor(tempMinColor),
            Text("[\(tempMinDiff)]").foregroundColor(tempMinColor).font(miniFont),
        ].reduce(Text("")) { $0 + $1 }

    }

    var body: some View {
        VStack {
            AsyncImage(url: weather.iconURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 94, height: 60)
            } placeholder: {
                Image(systemName: "questionmark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .frame(width: 94, height: 60)
            }
            tempView()
            Text("\(weather.chanceOfRain)%")
        }
    }
}

struct HeaderView: View {
    let store: Store<HeaderState, HeaderAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack(alignment: .topLeading) {
//                AsyncImage(url: URL(string: "https://via.placeholder.com/834x469"))
//                AsyncImage(url: URL(string: "https://drscdn.500px.org/photo/1047170708/q%3D80_m%3D2000/v2?sig=9a6cbb90ec8e42f1c34cc870488f44c00c491a687820a81601296bf91454213f"))
//                    .frame(width: .infinity, height: 400)
//                    .aspectRatio(3 / 1, contentMode: .fit)
                Rectangle()
                    .foregroundColor(Color(white: 0.9))
                    .aspectRatio(3 / 1, contentMode: .fit)
                HStack(alignment: .top) {
                    Text(viewStore.dateString)
                    Spacer()
                    WeatherView(weather: viewStore.weather)
                }
            }
        }
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(
            store: Store(
                initialState: HeaderState(
                    date: Date(),
                    weather: Weather(
                        tempMin: 3,
                        tempMax: 10,
                        tempMinDiff: 4,
                        tempMaxDiff: -2,
                        chanceOfRain: 20,
                        iconURL: nil
                    )
                ),
                reducer: headerReducer,
                environment: HeaderEnvironment()
            )
        )
    }
}
