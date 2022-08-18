import Charts
import SwiftUI

struct TemperatureAndHumidityChartView: UIViewRepresentable {
    var chartData: LineChartData

    func makeUIView(context _: Context) -> LineChartView {
        let view = LineChartView()
        let textColor = AppTheme.UIKit.textColor
        view.noDataTextColor = textColor
        view.xAxis.enabled = false
        view.leftAxis.drawAxisLineEnabled = false
        view.leftAxis.labelTextColor = textColor
        view.leftAxis.drawGridLinesEnabled = false
        view.rightAxis.drawAxisLineEnabled = false
        view.rightAxis.labelTextColor = textColor
        view.rightAxis.drawGridLinesEnabled = false
        view.legend.enabled = false
        view.doubleTapToZoomEnabled = false
        view.pinchZoomEnabled = false
        view.highlightPerTapEnabled = false
        view.highlightPerDragEnabled = false
        view.dragEnabled = false
        return view
    }

    func updateUIView(_ uiView: LineChartView, context _: Context) {
        uiView.data = chartData
    }
}

struct CO2ChartView: UIViewRepresentable {
    var chartData: LineChartData

    func makeUIView(context _: Context) -> LineChartView {
        let view = LineChartView()
        let textColor = AppTheme.UIKit.textColor
        view.noDataTextColor = textColor
        view.xAxis.enabled = false
        view.leftAxis.drawAxisLineEnabled = false
        view.leftAxis.labelTextColor = textColor
        view.leftAxis.drawGridLinesEnabled = false
        view.rightAxis.enabled = false
        view.legend.enabled = false
        view.doubleTapToZoomEnabled = false
        view.pinchZoomEnabled = false
        view.highlightPerTapEnabled = false
        view.highlightPerDragEnabled = false
        view.dragEnabled = false
        return view
    }

    func updateUIView(_ uiView: LineChartView, context _: Context) {
        uiView.data = chartData
    }
}

struct DiscomfortIndexView: View {
    let discomfortIndex: Double

    var discomfortIndexText: String {
        switch discomfortIndex {
        case 0 ..< 50:
            return "寒くてたまらない"
        case 50 ..< 55:
            return "寒い"
        case 55 ..< 60:
            return "肌寒い"
        case 60 ..< 65:
            return "何も感じない"
        case 65 ..< 70:
            return "快適"
        case 70 ..< 75:
            return "暑くない"
        case 75 ..< 80:
            return "やや暑い"
        case 80 ..< 85:
            return "暑くて汗が出る"
        case 85 ..< 100:
            return "暑くてたまらない"
        default:
            return "---"
        }
    }

    var symbolColor: Color {
        let hue: Double
        switch discomfortIndex {
        case 0 ..< 50:
            hue = 0.6
        case 50 ..< 85:
            hue = (1.0 - (discomfortIndex - 50) / 35.0) * 0.6
        case 85 ..< 100:
            hue = 0.0
        default:
            hue = 0.0
            return .white
        }
        return Color(hue: hue, saturation: 1.0, brightness: 0.8)
    }

    var symbolName: String {
        switch discomfortIndex {
        case 0 ..< 50:
            return "di1"
        case 50 ..< 55:
            return "di2"
        case 55 ..< 60:
            return "di3"
        case 60 ..< 65:
            return "di4"
        case 65 ..< 70:
            return "di5"
        case 70 ..< 75:
            return "di6"
        case 75 ..< 80:
            return "di7"
        case 80 ..< 85:
            return "di8"
        case 85 ..< 100:
            return "di9"
        default:
            return "di9"
        }
    }

    var body: some View {
        HStack(alignment: .top) {
            Text("\(discomfortIndex, specifier: "%.f") - \(discomfortIndexText)")
                .foregroundColor(AppTheme.textColor)
                .font(AppTheme.textFont)
            Spacer()
            Image(symbolName)
                .renderingMode(.template)
                .resizable()
                .frame(width: 44, height: 44)
                .foregroundColor(symbolColor)
            Spacer()
                .frame(width: 4)
        }
    }
}

struct RoomSummaryView: View {
    let history: RoomSensorsHistory

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Image(systemName: "house.fill")
                Text(history.room.name)
            }
            .foregroundColor(AppTheme.headerColor)
            .font(.headline)
            Divider().background(Color.white)
            if let current = history.records.last {
                VStack(alignment: .center, spacing: 6) {
                    HStack(alignment: .top) {
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Image(systemName: "person.fill.questionmark")
                            Text("不快指数")
                        }
                        .foregroundColor(AppTheme.headerColor)
                        .font(AppTheme.headerFont)
                        Spacer()
                    }
                    DiscomfortIndexView(discomfortIndex: current.discomfortIndex)
                }
            }
            Spacer()
        }
        .padding(AppTheme.panelPadding)
        .background {
            AppTheme.backgroundColor
        }
        .cornerRadius(AppTheme.cornerRadius)
    }
}

struct RoomStatusView: View {
    enum Content {
        case temperatureAndHumidity
        case co2

        var title: String {
            switch self {
            case .temperatureAndHumidity:
                return "温度/湿度"
            case .co2:
                return "CO2"
            }
        }
    }

    let history: RoomSensorsHistory
    let content: Content

    private func makeMetricsHistoryDataSet(_ keyPath: KeyPath<SensorsRecord, Double>) -> LineChartDataSet {
        let records = history.records.sorted(by: { $0.date > $1.date }).map { $0[keyPath: keyPath] }
        let dataSet = LineChartDataSet(entries: records.enumerated().map { index, value in
            ChartDataEntry(x: Double(index), y: value)
        })
        return dataSet
    }

    private func makeTemperatureChartData() -> LineChartDataSet {
        let dataSet = makeMetricsHistoryDataSet(\.temperature)
        dataSet.drawValuesEnabled = false
        dataSet.drawCirclesEnabled = false
        dataSet.setColor(UIColor(red: 1.00, green: 0.62, blue: 0.19, alpha: 0.7))
        dataSet.lineWidth = 3
        dataSet.axisDependency = .left
        return dataSet
    }

    private func makeHumidityChartData() -> LineChartDataSet {
        let dataSet = makeMetricsHistoryDataSet(\.humidity)
        dataSet.drawValuesEnabled = false
        dataSet.drawCirclesEnabled = false
        dataSet.setColor(UIColor(red: 0.00, green: 0.53, blue: 0.97, alpha: 0.7))
        dataSet.lineWidth = 3
        dataSet.axisDependency = .right
        return dataSet
    }

    private func makeCO2ChartData() -> LineChartDataSet {
        let dataSet = makeMetricsHistoryDataSet(\.co2)
        dataSet.drawValuesEnabled = false
        dataSet.drawCirclesEnabled = false
        dataSet.setColor(UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.7))
        dataSet.lineWidth = 3
        dataSet.axisDependency = .left
        return dataSet
    }

    private func makeTemperatureAndHumidityChartData() -> LineChartData {
        LineChartData(dataSets: [
            makeTemperatureChartData(),
            makeHumidityChartData(),
        ])
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    switch content {
                    case .temperatureAndHumidity:
                        Image(systemName: "thermometer")
                    case .co2:
                        Image(systemName: "cloud.fill")
                    }
                    Text(content.title)
                }
                .foregroundColor(AppTheme.headerColor)
                .font(AppTheme.headerFont)
                Spacer()
                Group {
                    switch content {
                    case .temperatureAndHumidity:
                        if let current = history.records.last {
                            Text("\(current.temperature, specifier: "%.1f")℃") +
                            Text(" / ") +
                            Text("\(current.humidity, specifier: "%.f")%")
                        }
                    case .co2:
                        if let current = history.records.last {
                            Text("\(current.co2, specifier: "%.f")ppm")
                        }
                    }
                }
                .foregroundColor(AppTheme.textColor)
                .font(AppTheme.textFont)
            }
            switch content {
            case .temperatureAndHumidity:
                TemperatureAndHumidityChartView(chartData: makeTemperatureAndHumidityChartData())
            case .co2:
                CO2ChartView(chartData: LineChartData(dataSet: makeCO2ChartData()))
            }
        }
        .padding(AppTheme.panelPadding)
        .background {
            AppTheme.backgroundColor
        }
        .cornerRadius(AppTheme.cornerRadius)
    }
}

struct RoomBlankView: View {
    var body: some View {
        ZStack {
            Color(.clear)
            Text("N/A")
                .foregroundColor(AppTheme.notAvailableColor)
                .font(AppTheme.headerFont)
        }
        .padding(AppTheme.panelPadding)
        .background {
            AppTheme.backgroundColor
        }
        .cornerRadius(AppTheme.cornerRadius)
    }
}

struct RoomStatusView_Previews: PreviewProvider {
    static let width: CGFloat = 270

    static var previews: some View {
        VStack {
            HStack {
                Group {
                    RoomSummaryView(
                        history: .mockLiving
                    )
                    RoomStatusView(
                        history: .mockLiving,
                        content: .temperatureAndHumidity
                    )
                }
                .aspectRatio(1.6, contentMode: .fit)
                .frame(width: width)
            }
            HStack {
                Group {
                    RoomStatusView(
                        history: .mockLiving,
                        content: .co2
                    )
                    RoomBlankView()
                }
                .aspectRatio(1.6, contentMode: .fit)
                .frame(width: width)
            }
        }
    }
}
