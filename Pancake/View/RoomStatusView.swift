import SwiftUI
import Charts

struct TemperatureAndHumidityChartView: UIViewRepresentable {
    var chartData: LineChartData

    func makeUIView(context: Context) -> LineChartView {
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

    func updateUIView(_ uiView: LineChartView, context: Context) {
        uiView.data = chartData
    }
}

struct CO2ChartView: UIViewRepresentable {
    var chartData: LineChartData

    func makeUIView(context: Context) -> LineChartView {
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

    func updateUIView(_ uiView: LineChartView, context: Context) {
        uiView.data = chartData
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

    let history: RoomMetricsHistory
    let content: Content

    private func makeMetricsHistoryDataSet(_ keyPath: KeyPath<MetricsHistoryRecord, Double>) -> LineChartDataSet {
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
            Text(content.title)
                .foregroundColor(AppTheme.textColor)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
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

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            Group {
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
    }
}
