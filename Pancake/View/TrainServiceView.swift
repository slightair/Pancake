import SwiftUI

extension Route {
    var color: Color {
        switch self {
        case .sobu:
            return Color(red: 0.98, green: 0.83, blue: 0.28)
        case .chuo:
            return Color(red: 0.88, green: 0.39, blue: 0.21)
        case .yamanote:
            return Color(red: 0.56, green: 0.75, blue: 0.34)
        }
    }
}

struct TrainServiceView: View {
    let statuses: [TrainStatus]

    var body: some View {
        VStack(spacing: 4) {
            ForEach(statuses) { status in
                HStack {
                    Rectangle()
                        .foregroundColor(status.route.color)
                        .frame(width: 8, height: 32)
                    Text("\(status.route.name):\(status.status)")
                        .foregroundColor(AppTheme.textColor)
                        .font(.system(size: 24))
                        .bold()
                }
            }
        }
    }
}

struct TrainServiceView_Previews: PreviewProvider {
    static var previews: some View {
        TrainServiceView(
            statuses: Dashboard.mock.trainStatuses
        )
    }
}
