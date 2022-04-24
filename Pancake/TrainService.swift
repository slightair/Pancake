import ComposableArchitecture
import Foundation
import SwiftUI

struct TrainRoute: Equatable, Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    let status: String
}

struct TrainServiceState: Equatable, Identifiable {
    let id = UUID()
    let routes: [TrainRoute] = [
        TrainRoute(name: "総武線", color: .red, status: "平常運転"),
        TrainRoute(name: "山手線", color: .red, status: "平常運転"),
        TrainRoute(name: "中央線", color: .red, status: "平常運転"),
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
                ForEach(viewStore.routes) { route in
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
}

struct TrainServiceView_Previews: PreviewProvider {
    static var previews: some View {
        TrainServiceView(
            store: Store(
                initialState: TrainServiceState(),
                reducer: trainServiceReducer,
                environment: TrainServiceEnvironment()
            )
        )
    }
}
