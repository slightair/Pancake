import SwiftUI

struct Dashboard: View {
    let date = Date()

    var body: some View {
        VStack {
            DashboardHeader(date: date)
            GeometryReader { geometry in
                let baseWidth = geometry.size.width / 3
                HStack(alignment: .top) {
                    DashboardEventList()
                        .frame(width: baseWidth * 2)
                    DashboardCalendar(selectedDate: date)
                        .frame(width: baseWidth)
                }
            }
                .frame(maxHeight: 280)
            DashboardRoomList()
            DashboardTrainInfo()
            Spacer()
        }
    }
}

struct Dashboard_Previews: PreviewProvider {
    static var previews: some View {
        Dashboard()
    }
}
