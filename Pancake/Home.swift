import ComposableArchitecture
import Foundation
import SwiftUI

struct RoomSensor: Equatable, Identifiable {
    let id = UUID()
    let name: String
}

struct Room: Equatable, Identifiable {
    let id = UUID()
    let name: String
    let sensors: [RoomSensor]
}

struct HomeState: Equatable, Identifiable {
    let id = UUID()
    let rooms: [Room] = [
        Room(
            name: "リビング",
            sensors: [
                RoomSensor(name: "不快指数"),
                RoomSensor(name: "温度"),
                RoomSensor(name: "湿度"),
                RoomSensor(name: "CO2"),
            ]
        ),
        Room(
            name: "書斎",
            sensors: [
                RoomSensor(name: "不快指数"),
                RoomSensor(name: "温度"),
                RoomSensor(name: "湿度"),
            ]
        ),
        Room(
            name: "寝室",
            sensors: [
                RoomSensor(name: "不快指数"),
                RoomSensor(name: "温度"),
                RoomSensor(name: "湿度"),
            ]
        ),
    ]
}

enum HomeAction: Equatable {
    case homeUpdate
}

struct HomeEnvironment {}

let homeReducer = Reducer<HomeState, HomeAction, HomeEnvironment> { state, action, _ in
    switch action {
    case .homeUpdate:
        return .none
    }
}

struct RoomSensorView: View {
    let sensor: RoomSensor

    var body: some View {
        Rectangle()
            .foregroundColor(Color(white: 0.9))
            .aspectRatio(1.6, contentMode: .fit)
    }
}

struct HomeView: View {
    let store: Store<HomeState, HomeAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 4), pinnedViews: .sectionHeaders) {
                    ForEach(viewStore.rooms) { room in
                        Section(header: Text(room.name).frame(maxWidth: .infinity, alignment: .leading)) {
                            ForEach(room.sensors) { sensor in
                                RoomSensorView(sensor: sensor)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(
            store: Store(
                initialState: HomeState(),
                reducer: homeReducer,
                environment: HomeEnvironment()
            )
        )
    }
}
