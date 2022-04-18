import SwiftUI

struct DashboardHeader: View {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    var date: Date

    var body: some View {
        ZStack(alignment: .topLeading) {
//            AsyncImage(url: URL(string: "https://via.placeholder.com/834x469"))
            Rectangle()
                .foregroundColor(Color(white: 0.9))
                .aspectRatio(3 / 1, contentMode: .fit)
            HStack(alignment: .top) {
                Text(Self.dateFormatter.string(from: date))
                Spacer()
            }
        }
    }
}

struct DashboardHeader_Previews: PreviewProvider {
    static var previews: some View {
        DashboardHeader(date: Date())
    }
}
