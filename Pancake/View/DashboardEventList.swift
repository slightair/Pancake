import SwiftUI

struct DashboardEventListItem: View {
    var body: some View {
        VStack {
            Text("4/12 10:00")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("散歩")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct DashboardEventList: View {
    var body: some View {
        VStack {
            ForEach(0..<5) { _ in
                DashboardEventListItem()
            }
        }
    }
}

struct DashboardEvent_Previews: PreviewProvider {
    static var previews: some View {
        DashboardEventList()
    }
}
