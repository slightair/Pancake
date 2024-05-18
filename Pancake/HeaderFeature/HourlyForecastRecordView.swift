import SwiftUI

struct HourlyForecastRecordView: View {
    let record: HourlyForecastRecord

    var body: some View {
        VStack(spacing: 2) {
            Text("\(record.time)")
                .foregroundColor(AppTheme.textColor)
                .font(.system(size: 12))
                .monospacedDigit()
            AsyncImage(url: record.weatherIconURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 33, height: 30)
            } placeholder: {
                Image(systemName: "questionmark")
                    .foregroundColor(AppTheme.textColor)
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .frame(width: 33, height: 30)
            }
            .padding(8)
            .background {
                Color(.white)
                    .frame(width: 48, height: 48)
            }
            .mask {
                Circle()
                    .frame(width: 44)
            }
            Text(record.weather)
                .foregroundColor(AppTheme.textColor)
                .font(.system(size: 14))
                .monospacedDigit()
                .bold()
            VStack(spacing: 0) {
                Text("\(record.temp)℃")
                    .foregroundColor(AppTheme.textColor)
                    .font(.system(size: 12))
                    .monospacedDigit()
                    .bold()
                Text("\(record.chanceOfRain)%")
                    .foregroundColor(AppTheme.textColor)
                    .font(.system(size: 12))
                    .monospacedDigit()
                    .bold()
            }
            AsyncImage(url: record.pressureIconURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 33, height: 35)
            } placeholder: {
                Image(systemName: "questionmark")
                    .foregroundColor(AppTheme.textColor)
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .frame(width: 33, height: 35)
            }
        }
        .padding(8)
    }
}

struct HourlyForecastRecordView_Previews: PreviewProvider {
    static var previews: some View {
        HourlyForecastRecordView(record: Dashboard.mock.hourlyForecast.first!)
            .previewLayout(PreviewLayout.sizeThatFits)
            .background { Color.black }
    }
}
