import SwiftUI

struct TrainRoute: Identifiable {
    var id: String {
        name
    }

    let name: String
    let color: Color
    let status: String
}

struct DashboardTrainInfo: View {
    let routes: [TrainRoute] = [
        TrainRoute(name: "総武線", color: .red, status: "平常運転"),
        TrainRoute(name: "山手線", color: .red, status: "平常運転"),
        TrainRoute(name: "中央線", color: .red, status: "平常運転"),
    ]

    var body: some View {
        HStack {
            ForEach(routes) { route in
                HStack {
                    Rectangle()
                        .foregroundColor(route.color)
                        .frame(width: 8, height: 32)
                    Text("\(route.name):\(route.status)")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct DashboardTrainInfo_Previews: PreviewProvider {
    static var previews: some View {
        DashboardTrainInfo()
    }
}
