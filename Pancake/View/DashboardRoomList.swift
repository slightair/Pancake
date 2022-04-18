import SwiftUI

struct RoomSensor: Identifiable {
    var id: String {
        name
    }

    let name: String
}

struct RoomMetrics: Identifiable {
    var id: String {
        name
    }

    let name: String
    let sensors: [RoomSensor]
}

struct DashboardRoomSensor: View {
    let sensor: RoomSensor

    var body: some View {
        Rectangle()
            .foregroundColor(Color(white: 0.9))
            .aspectRatio(1.6, contentMode: .fit)
    }
}

struct DashboardRoomList: View {
    let roomMetricsList: [RoomMetrics] = [
        RoomMetrics(name: "リビング",
                    sensors: [
                        RoomSensor(name: "不快指数"),
                        RoomSensor(name: "温度"),
                        RoomSensor(name: "湿度"),
                        RoomSensor(name: "CO2"),
                    ]),
        RoomMetrics(name: "寝室",
                    sensors: [
                        RoomSensor(name: "不快指数"),
                        RoomSensor(name: "温度"),
                        RoomSensor(name: "湿度"),
                    ]),
    ]

    var body: some View {
        VStack {
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 4), pinnedViews: .sectionHeaders) {
                ForEach(roomMetricsList) { metrics in
                    Section(header: Text(metrics.name).frame(maxWidth: .infinity, alignment: .leading)) {
                        ForEach(metrics.sensors) { sensor in
                            DashboardRoomSensor(sensor: sensor)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct DashboardRoom_Previews: PreviewProvider {
    static var previews: some View {
        DashboardRoomList()
    }
}
