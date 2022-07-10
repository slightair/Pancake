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

struct DiscomfortIndexGaugeView: View {
    private let cornerRadius: CGFloat = 24
    private let height: CGFloat = 4

    let discomfortIndex: Double

    var gaugeValue: Double {
        if discomfortIndex <= 55 {
            return 0.0
        } else if discomfortIndex >= 85 {
            return 1.0
        } else {
            return (discomfortIndex - 55) / 30
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                LinearGradient(
                    gradient: Gradient(
                        stops: [
                            Gradient.Stop(color: .blue, location: 0.0),
                            Gradient.Stop(color: .cyan, location: 0.17),
                            Gradient.Stop(color: .green, location: 0.42),
                            Gradient.Stop(color: .yellow, location: 0.67),
                            Gradient.Stop(color: .orange, location: 0.83),
                            Gradient.Stop(color: .red, location: 1.0),
                        ]
                    ),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: height)
                .cornerRadius(cornerRadius)
                Circle()
                    .stroke()
                    .foregroundColor(.gray)
                    .background(.white)
                    .frame(width: height, height: height)
                    .offset(x: (geometry.size.width - height) * gaugeValue, y: 0)
            }
            .frame(height: height)
            .clipped()
        }
        .frame(height: height)
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
                    HStack(alignment: .top) {
                        Text("\(current.discomfortIndex, specifier: "%.f") - \(current.discomfortIndexText)")
                            .foregroundColor(AppTheme.textColor)
                            .font(AppTheme.textFont)
                        Spacer()
                    }
                    DiscomfortIndexGaugeView(discomfortIndex: current.discomfortIndex)
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
                .foregroundColor(AppTheme.headerColor)
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
                    RoomStatusView(
                        history: .mockLiving,
                        content: .co2
                    )
                }
                .aspectRatio(1.6, contentMode: .fit)
                .frame(width: 240)
            }
            HStack {
                Group {
                    RoomBlankView()
                        .aspectRatio(1.6, contentMode: .fit)
                        .frame(width: 240)
                }
            }
        }
    }
}
