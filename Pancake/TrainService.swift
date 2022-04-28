import ComposableArchitecture
import Foundation
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

struct TrainServiceState: Equatable, Identifiable {
    let id = UUID()
    var statuses: [TrainStatus] = [
        .init(route: .sobu, status: "---"),
        .init(route: .chuo, status: "---"),
        .init(route: .yamanote, status: "---"),
    ]
}

enum TrainServiceAction: Equatable {
    case trainServiceUpdate
}

struct TrainServiceEnvironment {}

let trainServiceReducer = Reducer<TrainServiceState, TrainServiceAction, TrainServiceEnvironment> { state, action, _ in
    switch action {
    case .trainServiceUpdate:
        return .none
    }
}

struct TrainServiceView: View {
    let store: Store<TrainServiceState, TrainServiceAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            HStack {
                ForEach(viewStore.statuses) { status in
                    HStack {
                        Rectangle()
                            .foregroundColor(status.route.color)
                            .frame(width: 8, height: 32)
                        Text("\(status.route.name):\(status.status)")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct TrainServiceView_Previews: PreviewProvider {
    static var previews: some View {
        TrainServiceView(
            store: Store(
                initialState: TrainServiceState(
                    statuses: [
                        .init(route: .sobu, status: "平常運転"),
                        .init(route: .chuo, status: "平常運転"),
                        .init(route: .yamanote, status: "平常運転"),
                    ]
                ),
                reducer: trainServiceReducer,
                environment: TrainServiceEnvironment()
            )
        )
    }
}
