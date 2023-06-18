import SwiftUI

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
            .foregroundColor(AppTheme.textColor)
            .monospacedDigit()
            .bold()
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
                    .foregroundColor(AppTheme.headerColor)
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .frame(width: 94, height: 60)
            }
            .padding()
            tempView()
        }
    }
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView(
            weather: Dashboard.mock.weather
        )
        .previewLayout(PreviewLayout.sizeThatFits)
        .background { Color.black }
    }
}
